import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;
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
        _error = 'Silakan login ulang untuk melihat riwayat pesanan.';
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

      final detailRows = orderIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await _client
                      .from('detail_pesanan')
                      .select()
                      .inFilter('id_pesanan', orderIds)
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

      final productNameMap = <int, String>{};
      for (final row in productRows) {
        final id = (row['id_produk'] as num?)?.toInt();
        if (id == null) {
          continue;
        }
        productNameMap[id] = (row['nama_produk'] ?? 'Produk ReWorth')
            .toString();
      }

      final productImageMap = <int, String>{};
      for (final row in imageRows) {
        final id = (row['id_produk'] as num?)?.toInt();
        if (id == null || productImageMap.containsKey(id)) {
          continue;
        }
        final url = (row['public_url'] ?? '').toString();
        if (url.isNotEmpty) {
          productImageMap[id] = url;
        }
      }

      final detailsByOrder = <int, List<Map<String, dynamic>>>{};
      for (final row in detailRows) {
        final orderId = (row['id_pesanan'] as num?)?.toInt();
        if (orderId == null) {
          continue;
        }
        detailsByOrder.putIfAbsent(orderId, () => []).add(row);
      }

      final paymentByOrder = <int, Map<String, dynamic>>{};
      for (final row in paymentRows) {
        final orderId = (row['id_pesanan'] as num?)?.toInt();
        if (orderId == null || paymentByOrder.containsKey(orderId)) {
          continue;
        }
        paymentByOrder[orderId] = row;
      }

      final orders = orderRows.map((row) {
        final orderId = (row['id_pesanan'] as num?)?.toInt() ?? 0;
        final details =
            detailsByOrder[orderId] ?? const <Map<String, dynamic>>[];
        final payment = paymentByOrder[orderId] ?? const <String, dynamic>{};

        final firstDetail = details.isNotEmpty ? details.first : null;
        final firstProductId = (firstDetail?['id_produk'] as num?)?.toInt();
        final firstProductName = firstProductId == null
            ? 'Produk ReWorth'
            : (productNameMap[firstProductId] ?? 'Produk ReWorth');
        final firstImage = firstProductId == null
            ? ''
            : (productImageMap[firstProductId] ?? '');
        final totalItems = details.fold<int>(
          0,
          (sum, item) => sum + (((item['jumlah'] as num?) ?? 0).toInt()),
        );

        return _OrderHistoryItem(
          orderId: orderId,
          kodePesanan: (row['kode_pesanan'] ?? 'ORD-$orderId').toString(),
          orderStatus: (row['status_pesanan'] ?? '').toString(),
          paymentStatus: (payment['status_pembayaran'] ?? '').toString(),
          totalBayar: ((row['total_bayar'] as num?) ?? 0).toDouble(),
          subtotalProduk:
              ((row['subtotal_produk'] as num?) ??
                      (row['subtotal'] as num?) ??
                      0)
                  .toDouble(),
          feePlatform:
              ((row['fee_platform'] as num?) ?? (row['pajak'] as num?) ?? 0)
                  .toDouble(),
          biayaLayanan: ((row['biaya_layanan'] as num?) ?? 0).toDouble(),
          createdAt: _parseDate(
            (row['tanggal_pesanan'] ?? row['created_at'] ?? '').toString(),
          ),
          firstProductName: firstProductName,
          firstProductImage: firstImage,
          totalItems: totalItems,
          proofUrl: (payment['bukti_pembayaran_url'] ?? '').toString(),
        );
      }).toList();

      if (!mounted) {
        return;
      }
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat riwayat pesanan: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041B16),
      body: Stack(
        children: [
          const _OrderHistoryBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      _CircleBackButton(
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 14),
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
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF1F5E23),
                          onRefresh: _loadOrders,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            children: [
                              if (_error != null)
                                _OrderErrorCard(message: _error!),
                              if (_error == null && _orders.isEmpty)
                                const _OrderEmptyState(),
                              if (_error == null)
                                ..._orders.map(
                                  (order) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _OrderHistoryCard(order: order),
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
}

class _OrderHistoryBackdrop extends StatelessWidget {
  const _OrderHistoryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A3C2F), Color(0xFF05251D), Color(0xFF041B16)],
              stops: [0, 0.42, 1],
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -20,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(183, 241, 100, 0.18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _OrderErrorCard extends StatelessWidget {
  const _OrderErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C1C1C).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OrderEmptyState extends StatelessWidget {
  const _OrderEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 54,
            color: Colors.white70,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada pesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pesanan Anda dari mini market akan muncul di sini setelah checkout.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});

  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final statusMeta = _statusMeta(order.orderStatus, order.paymentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.kodePesanan,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusMeta.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusMeta.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusMeta.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: order.firstProductImage.isEmpty
                      ? Container(
                          color: Colors.white.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white70,
                          ),
                        )
                      : Image.network(
                          order.firstProductImage,
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
                      order.firstProductName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.totalItems} item | ${_paymentLabel(order.paymentStatus)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.66),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryLine(
            label: 'Subtotal Produk',
            value: _rupiah(order.subtotalProduk),
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Fee Platform',
            value: _rupiah(order.feePlatform),
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Biaya Layanan',
            value: _rupiah(order.biayaLayanan),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
          const SizedBox(height: 12),
          _SummaryLine(
            label: 'Total Bayar',
            value: _rupiah(order.totalBayar),
            bold: true,
          ),
          if (order.proofUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Bukti pembayaran sudah diunggah dan sedang diproses sesuai status di atas.',
              style: GoogleFonts.poppins(
                fontSize: 11.8,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
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

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: bold ? 15.5 : 13.5,
              fontWeight: fontWeight,
              color: Colors.white.withValues(alpha: bold ? 0.94 : 0.68),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: bold ? 16 : 13.5,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _OrderHistoryItem {
  const _OrderHistoryItem({
    required this.orderId,
    required this.kodePesanan,
    required this.orderStatus,
    required this.paymentStatus,
    required this.totalBayar,
    required this.subtotalProduk,
    required this.feePlatform,
    required this.biayaLayanan,
    required this.createdAt,
    required this.firstProductName,
    required this.firstProductImage,
    required this.totalItems,
    required this.proofUrl,
  });

  final int orderId;
  final String kodePesanan;
  final String orderStatus;
  final String paymentStatus;
  final double totalBayar;
  final double subtotalProduk;
  final double feePlatform;
  final double biayaLayanan;
  final DateTime? createdAt;
  final String firstProductName;
  final String firstProductImage;
  final int totalItems;
  final String proofUrl;
}

class _OrderStatusMeta {
  const _OrderStatusMeta({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_OrderStatusMeta _statusMeta(String orderStatus, String paymentStatus) {
  final order = orderStatus.trim().toLowerCase();
  final payment = paymentStatus.trim().toLowerCase();

  if (payment.contains('ditolak') || order == 'dibatalkan') {
    return const _OrderStatusMeta(
      label: 'Ditolak / Batal',
      background: Color(0x33FF6B6B),
      foreground: Color(0xFFFFA5A5),
    );
  }
  if (payment.contains('terverifikasi') && order == 'diproses') {
    return const _OrderStatusMeta(
      label: 'Diproses Seller',
      background: Color(0x331B89FF),
      foreground: Color(0xFF9CC7FF),
    );
  }
  if (order == 'dikemas') {
    return const _OrderStatusMeta(
      label: 'Dikemas',
      background: Color(0x33DDAA35),
      foreground: Color(0xFFFFE39A),
    );
  }
  if (order == 'dikirim') {
    return const _OrderStatusMeta(
      label: 'Dikirim',
      background: Color(0x3328B5A4),
      foreground: Color(0xFF93F3E0),
    );
  }
  if (order == 'selesai') {
    return const _OrderStatusMeta(
      label: 'Selesai',
      background: Color(0x332CBF6B),
      foreground: Color(0xFFA9F3C6),
    );
  }
  if (payment.contains('menunggu verifikasi') ||
      order.contains('menunggu verifikasi')) {
    return const _OrderStatusMeta(
      label: 'Menunggu Verifikasi',
      background: Color(0x33F6C453),
      foreground: Color(0xFFFFE29B),
    );
  }
  return const _OrderStatusMeta(
    label: 'Menunggu Pembayaran',
    background: Color(0x33F6C453),
    foreground: Color(0xFFFFE29B),
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
    return 'Bukti menunggu verifikasi';
  }
  return 'Belum selesai dibayar';
}

DateTime? _parseDate(String raw) {
  if (raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Tanggal tidak tersedia';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
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
