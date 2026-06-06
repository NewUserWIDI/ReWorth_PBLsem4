import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _OrderTab { active, completed, cancelled }

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final SupabaseClient _client = Supabase.instance.client;
  final Set<int> _expandedOrderIds = <int>{};

  bool _isLoading = true;
  String? _error;
  _OrderTab _selectedTab = _OrderTab.active;
  List<_OrderHistoryItem> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error =
            'Sesi Anda berakhir. Silakan login ulang untuk melihat pesanan.';
      });
      return;
    }

    try {
      final orderRows = List<Map<String, dynamic>>.from(
        await _client
                .from('pesanan')
                .select()
                .eq('id_masyarakat', userId)
                .order('created_at', ascending: false)
                .timeout(const Duration(seconds: 10))
            as List,
      );

      if (orderRows.isEmpty) {
        setState(() {
          _orders = const [];
          _isLoading = false;
        });
        return;
      }

      final orderIds = orderRows
          .map((row) => row['id_pesanan'])
          .whereType<num>()
          .map((value) => value.toInt())
          .toList();
      final addressIds = orderRows
          .map((row) => row['id_alamat'])
          .whereType<num>()
          .map((value) => value.toInt())
          .toSet()
          .toList();

      final detailRows = orderIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('detail_pesanan')
                      .select()
                      .inFilter('id_pesanan', orderIds)
                      .order('id_detail_pesanan')
                      .timeout(const Duration(seconds: 10))
                  as List,
            );

      final paymentRows = orderIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('pembayaran')
                      .select()
                      .inFilter('id_pesanan', orderIds)
                      .timeout(const Duration(seconds: 10))
                  as List,
            );

      final addressRows = addressIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('alamat')
                      .select()
                      .inFilter('id_alamat', addressIds)
                      .timeout(const Duration(seconds: 10))
                  as List,
            );

      final productIds = detailRows
          .map((row) => row['id_produk'])
          .whereType<num>()
          .map((value) => value.toInt())
          .toSet()
          .toList();

      final productRows = productIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('produk')
                      .select('id_produk,nama_produk')
                      .inFilter('id_produk', productIds)
                      .timeout(const Duration(seconds: 10))
                  as List,
            );

      final imageRows = productIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('gambar_produk')
                      .select('id_produk,public_url,is_primary,created_at')
                      .inFilter('id_produk', productIds)
                      .order('is_primary', ascending: false)
                      .order('created_at', ascending: true)
                      .timeout(const Duration(seconds: 10))
                  as List,
            );

      final paymentByOrder = <int, Map<String, dynamic>>{};
      for (final row in paymentRows) {
        final orderId = (row['id_pesanan'] as num?)?.toInt();
        if (orderId != null && !paymentByOrder.containsKey(orderId)) {
          paymentByOrder[orderId] = row;
        }
      }

      final addressById = <int, Map<String, dynamic>>{};
      for (final row in addressRows) {
        final id = (row['id_alamat'] as num?)?.toInt();
        if (id != null) {
          addressById[id] = row;
        }
      }

      final productNameMap = <int, String>{};
      for (final row in productRows) {
        final id = (row['id_produk'] as num?)?.toInt();
        if (id != null) {
          productNameMap[id] = (row['nama_produk'] ?? 'Produk ReWorth')
              .toString();
        }
      }

      final imageMap = <int, String>{};
      for (final row in imageRows) {
        final id = (row['id_produk'] as num?)?.toInt();
        if (id == null || imageMap.containsKey(id)) {
          continue;
        }
        final url = (row['public_url'] ?? '').toString();
        if (url.isNotEmpty) {
          imageMap[id] = url;
        }
      }

      final detailsByOrder = <int, List<_OrderLine>>{};
      for (final row in detailRows) {
        final orderId = (row['id_pesanan'] as num?)?.toInt();
        final productId = (row['id_produk'] as num?)?.toInt();
        if (orderId == null) {
          continue;
        }

        detailsByOrder
            .putIfAbsent(orderId, () => [])
            .add(
              _OrderLine(
                productId: productId ?? 0,
                productName: productNameMap[productId ?? 0] ?? 'Produk ReWorth',
                imageUrl: imageMap[productId ?? 0] ?? '',
                quantity: ((row['jumlah'] as num?) ?? 0).toInt(),
                price: ((row['harga_satuan'] as num?) ?? 0).toDouble(),
                subtotal: ((row['subtotal'] as num?) ?? 0).toDouble(),
                sellerNet: ((row['pendapatan_seller'] as num?) ?? 0).toDouble(),
              ),
            );
      }

      final mappedOrders = orderRows.map((row) {
        final orderId = (row['id_pesanan'] as num?)?.toInt() ?? 0;
        final payment = paymentByOrder[orderId] ?? const <String, dynamic>{};
        final lines = detailsByOrder[orderId] ?? const <_OrderLine>[];
        final addressId = (row['id_alamat'] as num?)?.toInt();
        final address = addressById[addressId ?? -1];
        final totalItems = lines.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        return _OrderHistoryItem(
          id: orderId,
          code: (row['kode_pesanan'] ?? 'ORD-$orderId').toString(),
          orderStatus: (row['status_pesanan'] ?? '').toString(),
          paymentStatus: (payment['status_pembayaran'] ?? '').toString(),
          createdAt: _parseDate(
            (row['tanggal_pesanan'] ?? row['created_at'] ?? '').toString(),
          ),
          subtotal:
              ((row['subtotal_produk'] as num?) ??
                      (row['subtotal'] as num?) ??
                      0)
                  .toDouble(),
          feePlatform:
              ((row['fee_platform'] as num?) ?? (row['pajak'] as num?) ?? 0)
                  .toDouble(),
          shippingFee: ((row['biaya_pengiriman'] as num?) ?? 0).toDouble(),
          serviceFee: ((row['biaya_layanan'] as num?) ?? 0).toDouble(),
          total: ((row['total_bayar'] as num?) ?? 0).toDouble(),
          addressText: _formatAddress(address),
          proofUrl: (payment['bukti_pembayaran_url'] ?? '').toString(),
          totalItems: totalItems,
          lines: lines,
        );
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _orders = mappedOrders;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Riwayat pesanan belum bisa dimuat: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _OrderBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _OrderHeader(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 8),
                _OrderTabBar(
                  selectedTab: _selectedTab,
                  onChanged: (tab) => setState(() => _selectedTab = tab),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF5F9E6D),
                          backgroundColor: const Color(0xFF0A1E19),
                          onRefresh: _loadOrders,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            children: [
                              if (_error != null)
                                _HistoryMessageCard(
                                  title: 'Riwayat pesanan',
                                  description: _error!,
                                  icon: Icons.info_outline_rounded,
                                  isError: true,
                                ),
                              if (_error == null && filteredOrders.isEmpty)
                                _HistoryMessageCard(
                                  title: _tabTitle(_selectedTab),
                                  description: _emptyDescription(_selectedTab),
                                  icon: Icons.receipt_long_rounded,
                                ),
                              if (_error == null)
                                ...filteredOrders.map(
                                  (order) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _OrderCard(
                                      order: order,
                                      isExpanded: _expandedOrderIds.contains(
                                        order.id,
                                      ),
                                      onToggle: () {
                                        setState(() {
                                          if (_expandedOrderIds.contains(
                                            order.id,
                                          )) {
                                            _expandedOrderIds.remove(order.id);
                                          } else {
                                            _expandedOrderIds.add(order.id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_OrderHistoryItem> _filteredOrders() {
    switch (_selectedTab) {
      case _OrderTab.completed:
        return _orders.where((order) => order.isCompleted).toList();
      case _OrderTab.cancelled:
        return _orders.where((order) => order.isCancelled).toList();
      case _OrderTab.active:
        return _orders
            .where((order) => !order.isCompleted && !order.isCancelled)
            .toList();
    }
  }
}

class _OrderBackdrop extends StatelessWidget {
  const _OrderBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradien utama background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF003B2F), // hijau tua bagian atas
                Color(0xFF002D24), // hijau tengah
                Color(0xFF001F1A), // hijau paling gelap bawah
              ],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        // Efek blur / glow tambahan
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 135, sigmaY: 135),
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

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
              'Riwayat Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 28,
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

class _OrderTabBar extends StatelessWidget {
  const _OrderTabBar({required this.selectedTab, required this.onChanged});

  final _OrderTab selectedTab;
  final ValueChanged<_OrderTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Aktif',
              selected: selectedTab == _OrderTab.active,
              onTap: () => onChanged(_OrderTab.active),
            ),
            _TabButton(
              label: 'Selesai',
              selected: selectedTab == _OrderTab.completed,
              onTap: () => onChanged(_OrderTab.completed),
            ),
            _TabButton(
              label: 'Dibatalkan',
              selected: selectedTab == _OrderTab.cancelled,
              onTap: () => onChanged(_OrderTab.cancelled),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                  )
                : null,
            color: selected ? null : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFF082018)
                  : Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryMessageCard extends StatelessWidget {
  const _HistoryMessageCard({
    required this.title,
    required this.description,
    required this.icon,
    this.isError = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFF5A2222).withValues(alpha: 0.76)
            : const Color(0xFF0A1E19).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  final _OrderHistoryItem order;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final meta = _orderMeta(order.orderStatus, order.paymentStatus);
    final firstLine = order.lines.isEmpty ? null : order.lines.first;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isExpanded
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: firstLine == null || firstLine.imageUrl.isEmpty
                      ? Container(
                          color: Colors.white.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white70,
                          ),
                        )
                      : Image.network(
                          firstLine.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.white.withValues(alpha: 0.08),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white70,
                            ),
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
                      firstLine?.productName ?? 'Pesanan ReWorth',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.totalItems} item • ${order.code}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InlineBadge(
                          label: meta.label,
                          background: meta.background,
                          foreground: meta.foreground,
                        ),
                        _InlineBadge(
                          label: _paymentLabel(order.paymentStatus),
                          background: Colors.white.withValues(alpha: 0.08),
                          foreground: Colors.white.withValues(alpha: 0.82),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressStepper(
            currentStep: _progressIndex(order.orderStatus, order.paymentStatus),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(order.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.64),
                  ),
                ),
              ),
              Text(
                _rupiah(order.total),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'Sembunyikan Detail' : 'Lihat Detail Lengkap',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF082018),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Color(0xFF082018),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ExpandedOrderDetail(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedOrderDetail extends StatelessWidget {
  const _ExpandedOrderDetail({required this.order});

  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
        const SizedBox(height: 14),
        if (order.addressText.isNotEmpty) ...[
          _DetailTextBlock(title: 'Alamat Pengiriman', body: order.addressText),
          const SizedBox(height: 12),
        ],
        _DetailTextBlock(
          title: 'Ringkasan Pembayaran',
          body:
              'Subtotal produk ${_rupiah(order.subtotal)}\nBiaya pengiriman ${_rupiah(order.shippingFee)}\nFee platform ${_rupiah(order.feePlatform)}\nBiaya layanan ${_rupiah(order.serviceFee)}',
        ),
        const SizedBox(height: 14),
        Text(
          'Daftar Produk',
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ...order.lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: line.imageUrl.isEmpty
                          ? Container(
                              color: Colors.white.withValues(alpha: 0.08),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.white70,
                              ),
                            )
                          : Image.network(
                              line.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.white.withValues(alpha: 0.08),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.white70,
                                ),
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
                          line.productName,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty ${line.quantity} • ${_rupiah(line.price)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rupiah(line.subtotal),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (order.proofUrl.isNotEmpty) ...[
          const SizedBox(height: 4),
          _DetailTextBlock(
            title: 'Bukti Pembayaran',
            body:
                'Bukti pembayaran sudah diunggah dan sedang diproses sesuai status pesanan Anda.',
          ),
        ],
      ],
    );
  }
}

class _DetailTextBlock extends StatelessWidget {
  const _DetailTextBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.currentStep});

  final int currentStep;

  static const _steps = <String>[
    'Bayar',
    'Verifikasi',
    'Dikemas',
    'Dikirim',
    'Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_steps.length, (index) {
          final reached = index <= currentStep;
          final active = index == currentStep;

          return Row(
            children: [
              if (index > 0)
                Container(
                  width: 26,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: reached
                      ? const Color(0xFF8DCB94)
                      : Colors.white.withValues(alpha: 0.16),
                ),
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reached
                          ? const Color(0xFF8DCB94)
                          : Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: active ? Colors.white : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      reached ? Icons.check_rounded : Icons.circle_outlined,
                      color: reached
                          ? const Color(0xFF082018)
                          : Colors.white.withValues(alpha: 0.46),
                      size: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _steps[index],
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: reached
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.48),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OrderHistoryItem {
  const _OrderHistoryItem({
    required this.id,
    required this.code,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
    required this.subtotal,
    required this.feePlatform,
    required this.shippingFee,
    required this.serviceFee,
    required this.total,
    required this.addressText,
    required this.proofUrl,
    required this.totalItems,
    required this.lines,
  });

  final int id;
  final String code;
  final String orderStatus;
  final String paymentStatus;
  final DateTime? createdAt;
  final double subtotal;
  final double feePlatform;
  final double shippingFee;
  final double serviceFee;
  final double total;
  final String addressText;
  final String proofUrl;
  final int totalItems;
  final List<_OrderLine> lines;

  bool get isCompleted => orderStatus.trim().toLowerCase() == 'selesai';
  bool get isCancelled =>
      orderStatus.trim().toLowerCase() == 'dibatalkan' ||
      paymentStatus.trim().toLowerCase().contains('ditolak');
}

class _OrderLine {
  const _OrderLine({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.sellerNet,
  });

  final int productId;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double price;
  final double subtotal;
  final double sellerNet;
}

class _OrderVisualMeta {
  const _OrderVisualMeta({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_OrderVisualMeta _orderMeta(String orderStatus, String paymentStatus) {
  final order = orderStatus.trim().toLowerCase();
  final payment = paymentStatus.trim().toLowerCase();

  if (payment.contains('ditolak') || order == 'dibatalkan') {
    return const _OrderVisualMeta(
      label: 'Dibatalkan',
      background: Color(0x33E06A6A),
      foreground: Color(0xFFFFC2C2),
    );
  }
  if (order == 'selesai') {
    return const _OrderVisualMeta(
      label: 'Selesai',
      background: Color(0x334CBF6B),
      foreground: Color(0xFFB8F3C4),
    );
  }
  if (order == 'dikirim') {
    return const _OrderVisualMeta(
      label: 'Dalam Pengiriman',
      background: Color(0x3343A7B6),
      foreground: Color(0xFFBEEAF3),
    );
  }
  if (order == 'dikemas') {
    return const _OrderVisualMeta(
      label: 'Sedang Dikemas',
      background: Color(0x33E3C36E),
      foreground: Color(0xFFFFE5AE),
    );
  }
  if (payment.contains('terverifikasi') || order == 'diproses') {
    return const _OrderVisualMeta(
      label: 'Diproses Seller',
      background: Color(0x338DCB94),
      foreground: Color(0xFFD7F6DC),
    );
  }
  if (payment.contains('menunggu verifikasi') ||
      order.contains('menunggu verifikasi')) {
    return const _OrderVisualMeta(
      label: 'Menunggu Verifikasi',
      background: Color(0x33E3C36E),
      foreground: Color(0xFFFFE5AE),
    );
  }

  return const _OrderVisualMeta(
    label: 'Menunggu Pembayaran',
    background: Color(0x33E3C36E),
    foreground: Color(0xFFFFE5AE),
  );
}

String _paymentLabel(String paymentStatus) {
  final normalized = paymentStatus.trim().toLowerCase();
  if (normalized.contains('terverifikasi')) {
    return 'Pembayaran terverifikasi';
  }
  if (normalized.contains('ditolak')) {
    return 'Bukti ditolak';
  }
  if (normalized.contains('menunggu verifikasi')) {
    return 'Bukti sedang diverifikasi';
  }
  return 'Belum menyelesaikan pembayaran';
}

int _progressIndex(String orderStatus, String paymentStatus) {
  final order = orderStatus.trim().toLowerCase();
  final payment = paymentStatus.trim().toLowerCase();

  if (payment.contains('ditolak') || order == 'dibatalkan') {
    return 0;
  }
  if (order == 'selesai') {
    return 4;
  }
  if (order == 'dikirim') {
    return 3;
  }
  if (order == 'dikemas') {
    return 2;
  }
  if (payment.contains('terverifikasi') || order == 'diproses') {
    return 1;
  }
  if (payment.contains('menunggu verifikasi')) {
    return 1;
  }
  return 0;
}

String _tabTitle(_OrderTab tab) {
  switch (tab) {
    case _OrderTab.active:
      return 'Pesanan Aktif';
    case _OrderTab.completed:
      return 'Pesanan Selesai';
    case _OrderTab.cancelled:
      return 'Pesanan Dibatalkan';
  }
}

String _emptyDescription(_OrderTab tab) {
  switch (tab) {
    case _OrderTab.active:
      return 'Pesanan yang sedang menunggu pembayaran, verifikasi, diproses, atau dikirim akan muncul di sini.';
    case _OrderTab.completed:
      return 'Belum ada pesanan yang selesai. Setelah transaksi tuntas, riwayatnya akan tersimpan di sini.';
    case _OrderTab.cancelled:
      return 'Belum ada pesanan yang dibatalkan atau ditolak.';
  }
}

DateTime? _parseDate(String raw) {
  if (raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Waktu belum tersedia';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}

String _formatAddress(Map<String, dynamic>? address) {
  if (address == null) {
    return '';
  }

  final parts = [
    (address['jalan'] ?? '').toString().trim(),
    (address['kelurahan'] ?? '').toString().trim(),
    (address['kecamatan'] ?? '').toString().trim(),
    (address['kota'] ?? '').toString().trim(),
    (address['provinsi'] ?? '').toString().trim(),
    (address['kode_pos'] ?? '').toString().trim(),
  ].where((value) => value.isNotEmpty).toList();

  final text = parts.join(', ');
  final landmark = (address['patokan'] ?? '').toString().trim();
  if (landmark.isEmpty) {
    return text;
  }
  return text.isEmpty ? 'Patokan: $landmark' : '$text\nPatokan: $landmark';
}

String _rupiah(double value) {
  final raw = value.round().toString();
  final chars = raw.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(chars[i]);
  }
  return 'Rp ${buffer.toString().split('').reversed.join()}';
}
