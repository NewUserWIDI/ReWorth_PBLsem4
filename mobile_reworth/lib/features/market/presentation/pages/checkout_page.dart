import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../market/application/cart_controller.dart';
import '../../../market/domain/cart_item.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showSuccessOverlay = false;
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

  List<String> _paymentOptions = const [];
  String? _selectedPayment;

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
      await Future.wait([
        _loadAddresses(),
        _loadShippingMethods(),
        _loadPaymentMethods(),
      ]);
    } catch (e) {
      setState(() {
        _loadError = 'Gagal memuat data checkout: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    List<Map<String, dynamic>> rows = const [];
    try {
      final raw = await _client
          .from('alamat')
          .select()
          .eq('user_id', userId)
          .limit(3);
      rows = List<Map<String, dynamic>>.from(raw as List);
    } catch (_) {
      try {
        final raw = await _client
            .from('alamat')
            .select()
            .eq('id_masyarakat', userId)
            .limit(3);
        rows = List<Map<String, dynamic>>.from(raw as List);
      } catch (_) {
        try {
          final raw = await _client
              .from('alamat')
              .select()
              .eq('user_id', userId)
              .limit(3);
          rows = List<Map<String, dynamic>>.from(raw as List);
        } catch (_) {
          rows = const [];
        }
      }
    }

    final mapped = rows.map(_AddressOption.fromMap).toList();
    _addresses = mapped;
    _selectedAddress = mapped.isEmpty ? null : mapped.first;
  }

  Future<void> _loadShippingMethods() async {
    try {
      final raw = await _client
          .from('shipping_methods')
          .select('id, shipping_method, estimated_days, shipping_fee')
          .order('shipping_fee', ascending: true);
      final rows = List<Map<String, dynamic>>.from(raw as List);
      if (rows.isEmpty) return;
      final mapped = rows
          .map(
            (r) => _ShippingOption(
              id: (r['id'] ?? 'std').toString(),
              name: (r['shipping_method'] ?? 'Standard').toString(),
              estimatedDays: (r['estimated_days'] ?? '3-4 hari').toString(),
              fee: ((r['shipping_fee'] as num?) ?? 0).toDouble(),
            ),
          )
          .toList();
      _shippingOptions = mapped;
      _selectedShipping = mapped.first;
    } catch (_) {
      // Keep default fallback.
    }
  }

  Future<void> _loadPaymentMethods() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _paymentOptions = const ['COD Dummy'];
      _selectedPayment = _paymentOptions.first;
      return;
    }

    List<Map<String, dynamic>> rows = const [];
    try {
      final raw = await _client
          .from('kartu_pembayaran')
          .select()
          .eq('user_id', userId)
          .limit(3);
      rows = List<Map<String, dynamic>>.from(raw as List);
    } catch (_) {
      try {
        final raw = await _client
            .from('kartu_pembayaran')
            .select()
            .eq('id_masyarakat', userId)
            .limit(3);
        rows = List<Map<String, dynamic>>.from(raw as List);
      } catch (_) {
        rows = const [];
      }
    }

    if (rows.isEmpty) {
      _paymentOptions = const ['COD Dummy'];
      _selectedPayment = _paymentOptions.first;
      return;
    }

    String read(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final options = rows.map((row) {
      final bank = read(row, ['nama_bank', 'bank_name', 'bank']);
      final number = read(row, ['nomor_rekening', 'account_number', 'rekening']);
      final clean = number.replaceAll(RegExp(r'\s+'), '');
      final suffix = clean.length > 4 ? clean.substring(clean.length - 4) : clean;
      return '${bank.isEmpty ? 'Bank' : bank} *$suffix';
    }).toList();

    _paymentOptions = options;
    _selectedPayment = options.first;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final selectedItems = cart.selectedItems;

    final subtotal = selectedItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final shipping = _selectedShipping.fee;
    final tax = 0.0;
    final total = subtotal + shipping + tax;

    final canSubmit = !_isSubmitting &&
        !_isLoading &&
        selectedItems.isNotEmpty &&
        _selectedAddress != null &&
        (_selectedPayment?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _CheckoutBackground(),
          SafeArea(
            child: Column(
              children: [
                _CheckoutHeader(
                  title: 'Konfirmasi Pesanan',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildCheckoutSheet(
                            selectedItems: selectedItems,
                            subtotal: subtotal,
                            shipping: shipping,
                            tax: tax,
                            total: total,
                            canSubmit: canSubmit,
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_showSuccessOverlay)
            _CheckoutSuccessOverlay(
              onBackToMarket: () {
                setState(() => _showSuccessOverlay = false);
                context.go('/market');
              },
              onOrderHistory: () {
                setState(() => _showSuccessOverlay = false);
                context.go('/order-history');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSheet({
    required List<CartItem> selectedItems,
    required double subtotal,
    required double shipping,
    required double tax,
    required double total,
    required bool canSubmit,
  }) {
    return Column(
      children: [
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Text(
              _loadError!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionRow(
                  label: 'Alamat',
                  value: _selectedAddress == null
                      ? 'Tambah alamat pengiriman'
                      : _selectedAddress!.compact,
                  onTap: _openAddressSheet,
                ),
                const SizedBox(height: 18),
                _SectionRow(
                  label: 'Pengiriman',
                  value: '${_selectedShipping.fee <= 0 ? 'Free' : _rupiah(_selectedShipping.fee)}\n'
                      '${_selectedShipping.name} | ${_selectedShipping.estimatedDays}',
                  onTap: _openShippingSheet,
                ),
                const SizedBox(height: 18),
                _SectionRow(
                  label: 'Payment',
                  value: _selectedPayment ?? 'Pilih metode pembayaran',
                  onTap: _openPaymentSheet,
                ),
                const SizedBox(height: 22),
                Text(
                  'Items',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedItems.isEmpty)
                  Text(
                    'Pilih item di keranjang dulu untuk checkout.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color.fromRGBO(17, 17, 17, 0.58),
                    ),
                  )
                else
                  ...selectedItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CheckoutItemCard(item: item),
                      )),
                const SizedBox(height: 20),
                const Divider(color: Color.fromRGBO(0, 0, 0, 0.06), height: 1),
                const SizedBox(height: 20),
                _SummaryRow(label: 'Subtotal (${selectedItems.length})', value: _rupiah(subtotal)),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Biaya Pengiriman',
                  value: shipping <= 0 ? 'Free' : _rupiah(shipping),
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Pajak',
                  value: tax <= 0 ? 'Rp 0' : _rupiah(tax),
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Total',
                  value: _rupiah(total),
                  bold: true,
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: canSubmit
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF1F5E23), Color(0xFF2E7D32)],
                      )
                    : null,
                color: canSubmit ? null : const Color(0xFFB0B0B0),
                boxShadow: canSubmit
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1F5E23).withValues(alpha: 0.24),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: TextButton.icon(
                onPressed: canSubmit ? _confirmCheckout : null,
                icon: Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white.withValues(alpha: canSubmit ? 1 : 0.7),
                  size: 22,
                ),
                label: Text(
                  _isSubmitting ? 'Memproses...' : 'Konfirmasi Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: canSubmit ? 1 : 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCheckout() async {
    final cartController = ref.read(cartControllerProvider.notifier);
    final selectedItems = ref.read(cartControllerProvider).selectedItems;
    final user = _client.auth.currentUser;
    if (user == null || selectedItems.isEmpty || _selectedAddress == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final subtotal = selectedItems.fold<double>(0, (sum, item) => sum + item.subtotal);
      final shipping = _selectedShipping.fee;
      const tax = 0.0;
      final total = subtotal + shipping + tax;

      final orderPayload = {
        'user_id': user.id,
        'address_id': _selectedAddress!.id,
        'shipping_method': _selectedShipping.name,
        'shipping_fee': shipping,
        'estimated_days': _selectedShipping.estimatedDays,
        'payment_method': _selectedPayment,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'status': 'paid',
        'created_at': DateTime.now().toIso8601String(),
      };

      final orderInsert = await _client.from('orders').insert(orderPayload).select().single();
      final orderMap = Map<String, dynamic>.from(orderInsert);
      final orderId = (orderMap['id'] ??
              orderMap['order_id'] ??
              orderMap['id_order'] ??
              orderMap['id_pesanan'])
          ?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Order ID tidak ditemukan setelah insert.');
      }

      final itemPayloads = selectedItems
          .map(
            (item) => {
              'order_id': orderId,
              'product_id': item.product.idProduk,
              'quantity': item.quantity,
              'price': item.product.harga,
              'subtotal': item.subtotal,
              'product_name': item.product.namaProduk,
              'seller_name': item.product.namaToko,
            },
          )
          .toList();
      await _client.from('order_items').insert(itemPayloads);

      cartController.clearSelected();

      if (mounted) {
        setState(() => _showSuccessOverlay = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF7A1C1C),
            content: Text(
              'Checkout gagal: $e',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openAddressSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFCFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (_addresses.isEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Tambah alamat pengiriman',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/address');
                  },
                )
              else ...[
                for (final address in _addresses)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedAddress = address;
                      });
                      Navigator.pop(context);
                    },
                    title: Text(
                      address.compact,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: address.receiverName.isEmpty
                        ? null
                        : Text(
                            '${address.receiverName} ${address.phone.isEmpty ? '' : '• ${address.phone}'}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                    trailing: Icon(
                      _selectedAddress?.id == address.id
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _selectedAddress?.id == address.id
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF9AA0A6),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addresses.length >= 3
                      ? null
                      : () {
                          Navigator.pop(context);
                          context.push('/address');
                        },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    _addresses.length >= 3
                        ? 'Maksimal 3 alamat'
                        : 'Tambah alamat pengiriman',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
      backgroundColor: const Color(0xFFFCFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Pengiriman',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ..._shippingOptions.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setState(() {
                    _selectedShipping = option;
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  option.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${option.estimatedDays} • ${option.fee <= 0 ? 'Free' : _rupiah(option.fee)}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Icon(
                  _selectedShipping.id == option.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _selectedShipping.id == option.id
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF9AA0A6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPaymentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFCFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Metode Pembayaran',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
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
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                trailing: Icon(
                  _selectedPayment == method
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _selectedPayment == method
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF9AA0A6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class _CheckoutBackground extends StatelessWidget {
  const _CheckoutBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF003B2F),
                Color(0xFF002D24),
                Color(0xFF001F1A),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        Positioned(
          top: -30,
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
                  color: const Color(0xFFB7F164).withValues(alpha: 0.16),
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
  const _CheckoutHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(17, 17, 17, 0.72),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E8E)),
          ],
        ),
      ),
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  const _CheckoutItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF2F5EF),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.product.gambarUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF7DA36B),
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
                    color: const Color.fromRGBO(17, 17, 17, 0.45),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.namaProduk,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty ${item.quantity}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color.fromRGBO(17, 17, 17, 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatRupiah(item.subtotal),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double value) {
    final asInt = value.round();
    final chars = asInt.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
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
    final fontWeight = bold ? FontWeight.w700 : FontWeight.w500;
    final fontSize = bold ? 18.0 : 16.0;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: const Color(0xFF111111),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: const Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}

class _CheckoutSuccessOverlay extends StatefulWidget {
  const _CheckoutSuccessOverlay({
    required this.onBackToMarket,
    required this.onOrderHistory,
  });

  final VoidCallback onBackToMarket;
  final VoidCallback onOrderHistory;

  @override
  State<_CheckoutSuccessOverlay> createState() => _CheckoutSuccessOverlayState();
}

class _CheckoutSuccessOverlayState extends State<_CheckoutSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeOutBack.transform(_controller.value);
            return Transform.translate(
              offset: Offset(0, (1 - _controller.value) * 16),
              child: Opacity(
                opacity: _controller.value,
                child: Transform.scale(
                  scale: 0.7 + (0.3 * t),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.86,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5BBF3D),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pembayaran Berhasil',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Terima kasih. Pesananmu berhasil dibuat dan akan segera diproses.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(17, 17, 17, 0.58),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onBackToMarket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E23),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Kembali ke Mini Market',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onOrderHistory,
                  child: Text(
                    'Lihat Riwayat Pesanan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F5E23),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
  });

  final String id;
  final String receiverName;
  final String phone;
  final String street;
  final String city;
  final String district;
  final String postalCode;

  String get compact {
    final parts = [street, city, district, postalCode]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Alamat belum lengkap' : parts.join(', ');
  }

  factory _AddressOption.fromMap(Map<String, dynamic> map) {
    String first(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    return _AddressOption(
      id: first(['id', 'id_alamat', 'address_id']),
      receiverName: first(['nama_penerima', 'receiver_name', 'nama']),
      phone: first(['nomor_hp', 'phone', 'no_hp']),
      street: first(['jalan', 'street', 'alamat_jalan', 'alamat']),
      city: first(['kota', 'city']),
      district: first(['kecamatan', 'district']),
      postalCode: first(['kode_pos', 'postal_code']),
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
