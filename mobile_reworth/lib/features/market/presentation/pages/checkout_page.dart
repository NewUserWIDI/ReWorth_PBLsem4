import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../market/application/cart_controller.dart';
import '../../../market/data/checkout_repository.dart';
import '../../../market/domain/cart_item.dart';
import '../../../market/domain/checkout_pricing.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  List<_AddressOption> _addresses = const [];
  _AddressOption? _selectedAddress;

  List<_ShippingOption> _shippingOptions = const [
    _ShippingOption(
      id: 'standard',
      name: 'Standard',
      estimatedDays: '3-4 hari',
      fee: 0,
    ),
    _ShippingOption(
      id: 'express',
      name: 'Express',
      estimatedDays: '1-2 hari',
      fee: 12000,
    ),
  ];
  _ShippingOption _selectedShipping = const _ShippingOption(
    id: 'standard',
    name: 'Standard',
    estimatedDays: '3-4 hari',
    fee: 0,
  );

  final List<String> _paymentOptions = const ['QRIS'];
  String _selectedPayment = 'QRIS';

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      await Future.wait([_loadAddresses(), _loadShippingMethods()]);
    } catch (e) {
      _loadError = 'Gagal memuat data checkout: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAddresses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _addresses = const [];
      _selectedAddress = null;
      return;
    }

    final rows = await _fetchAddressRows(userId);
    final mapped = rows.map(_AddressOption.fromMap).toList()
      ..sort((a, b) => (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0));

    _addresses = mapped;
    if (mapped.isEmpty) {
      _selectedAddress = null;
      return;
    }

    final currentId = _selectedAddress?.id;
    _selectedAddress = mapped.firstWhere(
      (address) => address.id == currentId,
      orElse: () => mapped.first,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAddressRows(String userId) async {
    final fetchers = [
      () => _client
          .from('alamat')
          .select()
          .eq('id_masyarakat', userId)
          .limit(3)
          .timeout(const Duration(seconds: 8)),
      () => _client
          .from('alamat')
          .select()
          .eq('user_id', userId)
          .limit(3)
          .timeout(const Duration(seconds: 8)),
    ];

    Object? lastError;
    for (final fetch in fetchers) {
      try {
        final raw = await fetch();
        return List<Map<String, dynamic>>.from(raw as List);
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    return const [];
  }

  Future<void> _loadShippingMethods() async {
    try {
      final raw = await _client
          .from('shipping_methods')
          .select('id, shipping_method, estimated_days, shipping_fee')
          .order('shipping_fee', ascending: true)
          .timeout(const Duration(seconds: 8));
      final rows = List<Map<String, dynamic>>.from(raw as List);
      if (rows.isEmpty) {
        return;
      }

      final mapped = rows
          .map(
            (row) => _ShippingOption(
              id: (row['id'] ?? 'standard').toString(),
              name: (row['shipping_method'] ?? 'Standard').toString(),
              estimatedDays: (row['estimated_days'] ?? '3-4 hari').toString(),
              fee: ((row['shipping_fee'] as num?) ?? 0).toDouble(),
            ),
          )
          .toList();

      _shippingOptions = mapped;
      _selectedShipping = mapped.first;
    } catch (_) {
      // Keep fallback shipping options if table is not available yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final selectedItems = cart.selectedItems;
    final pricing = CheckoutPricing.fromItems(
      selectedItems,
      biayaPengiriman: _selectedShipping.fee,
    );

    final canSubmit =
        !_isSubmitting &&
        !_isLoading &&
        selectedItems.isNotEmpty &&
        _selectedAddress != null;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _CheckoutBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _CheckoutHeader(onBack: () => context.pop()),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _CheckoutBody(
                          loadError: _loadError,
                          selectedItems: selectedItems,
                          selectedAddress: _selectedAddress,
                          selectedShipping: _selectedShipping,
                          selectedPayment: _selectedPayment,
                          pricing: pricing,
                          canSubmit: canSubmit,
                          onOpenAddress: _openAddressSheet,
                          onOpenShipping: _openShippingSheet,
                          onOpenPayment: _openPaymentSheet,
                          onConfirm: _confirmCheckout,
                          currency: _rupiah,
                          isSubmitting: _isSubmitting,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCheckout() async {
    final user = _client.auth.currentUser;
    final selectedItems = ref.read(cartControllerProvider).selectedItems;
    final address = _selectedAddress;
    if (user == null || selectedItems.isEmpty || address == null) {
      return;
    }

    final addressId = int.tryParse(address.id);
    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A1C1C),
          content: Text(
            'Alamat belum valid. Silakan pilih ulang alamat Anda.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final session = await ref
          .read(checkoutRepositoryProvider)
          .createPendingCheckout(
            userId: user.id,
            addressId: addressId,
            shippingFee: _selectedShipping.fee,
            items: selectedItems,
          );

      if (!mounted) {
        return;
      }
      await context.push('/checkout/payment', extra: session);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A1C1C),
          content: Text(
            'Checkout gagal: $e',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openAddressSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A1E19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Alamat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (_addresses.isEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Tambah alamat pengiriman',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openAddressPage();
                  },
                )
              else ...[
                for (final address in _addresses)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() => _selectedAddress = address);
                      Navigator.pop(context);
                    },
                    title: Text(
                      address.compact,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: address.receiverName.isEmpty
                        ? null
                        : Text(
                            '${address.receiverName}${address.phone.isEmpty ? '' : ' - ${address.phone}'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.66),
                            ),
                          ),
                    trailing: Icon(
                      _selectedAddress?.id == address.id
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _selectedAddress?.id == address.id
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.48),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addresses.length >= 3
                      ? null
                      : () {
                          Navigator.pop(context);
                          _openAddressPage();
                        },
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.white.withValues(
                      alpha: _addresses.length >= 3 ? 0.40 : 1,
                    ),
                  ),
                  label: Text(
                    _addresses.length >= 3
                        ? 'Maksimal 3 alamat'
                        : 'Tambah alamat pengiriman',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(
                        alpha: _addresses.length >= 3 ? 0.40 : 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openShippingSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A1E19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ..._shippingOptions.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    setState(() => _selectedShipping = option);
                    Navigator.pop(context);
                  },
                  title: Text(
                    option.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${option.estimatedDays} - ${option.fee <= 0 ? 'Free' : _rupiah(option.fee)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.66),
                    ),
                  ),
                  trailing: Icon(
                    _selectedShipping.id == option.id
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _selectedShipping.id == option.id
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPaymentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A1E19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Metode Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ..._paymentOptions.map(
                (method) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    setState(() => _selectedPayment = method);
                    Navigator.pop(context);
                  },
                  title: Text(
                    method,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Scan QR, lalu upload bukti pembayaran untuk diverifikasi admin.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.66),
                    ),
                  ),
                  trailing: Icon(
                    _selectedPayment == method
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _selectedPayment == method
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddressPage() async {
    await context.push('/address');
    await _loadAddresses();
    if (mounted) {
      setState(() {});
    }
  }

  String _rupiah(double value) {
    final asInt = value.round();
    final chars = asInt.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }
}

class _CheckoutBackdrop extends StatelessWidget {
  const _CheckoutBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Konfirmasi Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.loadError,
    required this.selectedItems,
    required this.selectedAddress,
    required this.selectedShipping,
    required this.selectedPayment,
    required this.pricing,
    required this.canSubmit,
    required this.onOpenAddress,
    required this.onOpenShipping,
    required this.onOpenPayment,
    required this.onConfirm,
    required this.currency,
    required this.isSubmitting,
  });

  final String? loadError;
  final List<CartItem> selectedItems;
  final _AddressOption? selectedAddress;
  final _ShippingOption selectedShipping;
  final String selectedPayment;
  final CheckoutPricing pricing;
  final bool canSubmit;
  final VoidCallback onOpenAddress;
  final VoidCallback onOpenShipping;
  final VoidCallback onOpenPayment;
  final VoidCallback onConfirm;
  final String Function(double) currency;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              loadError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD4D4),
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionCard(
                  label: 'Alamat',
                  value: selectedAddress == null
                      ? 'Tambah alamat pengiriman'
                      : selectedAddress!.compact,
                  onTap: onOpenAddress,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  label: 'Pengiriman',
                  value:
                      '${selectedShipping.fee <= 0 ? 'Free' : currency(selectedShipping.fee)}\n'
                      '${selectedShipping.name} | ${selectedShipping.estimatedDays}',
                  onTap: onOpenShipping,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  label: 'Pembayaran',
                  value: '$selectedPayment\nScan QR lalu konfirmasi bayar',
                  onTap: onOpenPayment,
                ),
                const SizedBox(height: 20),
                Text(
                  'Item Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Text(
                      'Pilih item di keranjang dulu untuk checkout.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  )
                else
                  ...selectedItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CheckoutItemCard(item: item, currency: currency),
                    ),
                  ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1E19).withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal Produk (${selectedItems.length})',
                        value: currency(pricing.subtotalProduk),
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Biaya Pengiriman',
                        value: pricing.biayaPengiriman <= 0
                            ? 'Free'
                            : currency(pricing.biayaPengiriman),
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Fee Platform 10%',
                        value: currency(pricing.feePlatform),
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Biaya Layanan',
                        value: currency(pricing.biayaLayanan),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.10),
                          height: 1,
                        ),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: currency(pricing.totalBayar),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF071712),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: canSubmit
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFDCEBD5)],
                      )
                    : null,
                color: canSubmit ? null : Colors.white.withValues(alpha: 0.16),
              ),
              child: TextButton.icon(
                onPressed: canSubmit ? onConfirm : null,
                icon: Icon(
                  Icons.receipt_long_rounded,
                  color: canSubmit
                      ? const Color(0xFF082018)
                      : Colors.white.withValues(alpha: 0.72),
                ),
                label: Text(
                  isSubmitting ? 'Memproses...' : 'Konfirmasi Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canSubmit
                        ? const Color(0xFF082018)
                        : Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1E19).withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 340;
            if (compact) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.52),
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 108,
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.52),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  const _CheckoutItemCard({required this.item, required this.currency});

  final CartItem item;
  final String Function(double) currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.product.gambarUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.namaToko,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.56),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.product.namaProduk,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty ${item.quantity}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.66),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            currency(item.subtotal),
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w700 : FontWeight.w500;
    final size = bold ? 17.0 : 14.5;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: size,
              fontWeight: weight,
              color: Colors.white.withValues(alpha: bold ? 0.98 : 0.72),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: size,
            fontWeight: weight,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AddressOption {
  const _AddressOption({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.street,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.isDefault,
  });

  final String id;
  final String receiverName;
  final String phone;
  final String street;
  final String city;
  final String district;
  final String postalCode;
  final bool isDefault;

  String get compact {
    final parts = [
      street,
      city,
      district,
      postalCode,
    ].where((value) => value.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Alamat belum lengkap' : parts.join(', ');
  }

  factory _AddressOption.fromMap(Map<String, dynamic> map) {
    String first(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) {
          continue;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return '';
    }

    bool firstBool(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) {
          continue;
        }
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value > 0;
        }
        final text = value.toString().toLowerCase();
        if (text == 'true' || text == '1') {
          return true;
        }
      }
      return false;
    }

    return _AddressOption(
      id: first(['id_alamat', 'id', 'address_id']),
      receiverName: first(['nama_penerima', 'receiver_name', 'nama']),
      phone: first(['no_hp', 'nomor_hp', 'phone']),
      street: first(['jalan', 'street', 'alamat_jalan', 'alamat']),
      city: first(['kota', 'city']),
      district: first(['kecamatan', 'district']),
      postalCode: first(['kode_pos', 'postal_code']),
      isDefault: firstBool(['alamat_utama', 'is_default', 'utama']),
    );
  }
}

class _ShippingOption {
  const _ShippingOption({
    required this.id,
    required this.name,
    required this.estimatedDays,
    required this.fee,
  });

  final String id;
  final String name;
  final String estimatedDays;
  final double fee;
}
