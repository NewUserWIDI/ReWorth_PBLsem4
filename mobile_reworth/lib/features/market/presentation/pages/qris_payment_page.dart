import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/cart_controller.dart';
import '../../data/checkout_repository.dart';
import '../../domain/checkout_payment_session.dart';

class QrisPaymentPage extends ConsumerStatefulWidget {
  const QrisPaymentPage({
    super.key,
    required this.session,
  });

  final CheckoutPaymentSession? session;

  @override
  ConsumerState<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends ConsumerState<QrisPaymentPage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isConfirming = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _syncRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _syncRemaining());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncRemaining() {
    final session = widget.session;
    if (session == null) {
      return;
    }

    final remaining = session.kadaluarsaPada.difference(DateTime.now());
    if (!mounted) {
      return;
    }

    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran QRIS')),
        body: Center(
          child: Text(
            'Sesi pembayaran tidak ditemukan.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

    final expired = _remaining == Duration.zero;

    return Scaffold(
      backgroundColor: const Color(0xFF061B18),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Bayar Dengan QRIS Dummy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FBF8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        children: [
                          _PaymentInfoCard(
                            kodePesanan: session.kodePesanan,
                            kodePembayaran: session.kodePembayaran,
                            totalBayar: session.totalBayar,
                            remaining: _remaining,
                            expired: expired,
                          ),
                          const SizedBox(height: 20),
                          const _DummyQrisCard(),
                          const SizedBox(height: 20),
                          Text(
                            'Scan QR ini untuk simulasi pembayaran. Setelah itu tekan tombol konfirmasi di bawah.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.5,
                              color: const Color.fromRGBO(17, 17, 17, 0.62),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF7E7),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan Demo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF204E17),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Ini hanya simulasi tugas akhir. Tidak ada transaksi bank atau QRIS asli yang diproses.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: const Color(0xFF365B2D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: expired || _isConfirming ? null : _confirmPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F5E23),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _isConfirming ? 'Memverifikasi...' : 'Saya Sudah Bayar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isConfirming ? null : () => context.pop(),
                            child: Text(
                              'Kembali ke checkout',
                              style: GoogleFonts.poppins(
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
              ],
            ),
          ),
          if (_showSuccess)
            _PaymentSuccessOverlay(
              onBackToMarket: () => context.go('/market'),
              onOrderHistory: () => context.go('/order-history'),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment() async {
    final session = widget.session;
    if (session == null) {
      return;
    }

    setState(() => _isConfirming = true);
    try {
      await ref.read(checkoutRepositoryProvider).confirmDummyPayment(session);
      ref.read(cartControllerProvider.notifier).clearSelected();
      if (!mounted) {
        return;
      }
      setState(() => _showSuccess = true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Gagal mengonfirmasi pembayaran: $error',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({
    required this.kodePesanan,
    required this.kodePembayaran,
    required this.totalBayar,
    required this.remaining,
    required this.expired,
  });

  final String kodePesanan;
  final String kodePembayaran;
  final double totalBayar;
  final Duration remaining;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Kode Pesanan', kodePesanan),
          const SizedBox(height: 10),
          _infoRow('Kode Pembayaran', kodePembayaran),
          const SizedBox(height: 10),
          _infoRow('Total Bayar', _rupiah(totalBayar)),
          const SizedBox(height: 10),
          _infoRow(
            'Berlaku Sampai',
            expired ? 'Kadaluarsa' : _formatDuration(remaining),
            highlight: !expired,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color.fromRGBO(17, 17, 17, 0.6),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFF1F5E23) : const Color(0xFF111111),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _rupiah(double value) {
    final amount = value.round().toString();
    final chars = amount.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var index = 0; index < chars.length; index++) {
      if (index > 0 && index % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[index]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

class _DummyQrisCard extends StatelessWidget {
  const _DummyQrisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'QRIS ReWorth Demo',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF111111), width: 1.4),
              ),
              child: const _FakeQrPattern(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeQrPattern extends StatelessWidget {
  const _FakeQrPattern();

  @override
  Widget build(BuildContext context) {
    const size = 17;
    final random = math.Random(17);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: size * size,
      itemBuilder: (context, index) {
        final x = index % size;
        final y = index ~/ size;
        final isFinder = _isFinder(x, y, size);
        final isDark = isFinder || random.nextBool();

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  static bool _isFinder(int x, int y, int size) {
    final finderOrigins = [
      const Offset(0, 0),
      Offset(size - 7, 0),
      Offset(0, size - 7),
    ];

    for (final origin in finderOrigins) {
      final startX = origin.dx.toInt();
      final startY = origin.dy.toInt();
      if (x >= startX && x < startX + 7 && y >= startY && y < startY + 7) {
        final localX = x - startX;
        final localY = y - startY;
        final border = localX == 0 ||
            localX == 6 ||
            localY == 0 ||
            localY == 6;
        final center = localX >= 2 && localX <= 4 && localY >= 2 && localY <= 4;
        return border || center;
      }
    }

    return false;
  }
}

class _PaymentSuccessOverlay extends StatefulWidget {
  const _PaymentSuccessOverlay({
    required this.onBackToMarket,
    required this.onOrderHistory,
  });

  final VoidCallback onBackToMarket;
  final VoidCallback onOrderHistory;

  @override
  State<_PaymentSuccessOverlay> createState() => _PaymentSuccessOverlayState();
}

class _PaymentSuccessOverlayState extends State<_PaymentSuccessOverlay>
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
      color: Colors.black.withValues(alpha: 0.52),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = Curves.easeOutBack.transform(_controller.value);
            return Transform.scale(
              scale: 0.72 + (0.28 * value),
              child: Opacity(
                opacity: _controller.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58B947),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
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
                  'Pesananmu sudah masuk ke sistem dan sedang diteruskan ke seller untuk diproses.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    height: 1.45,
                    color: const Color.fromRGBO(17, 17, 17, 0.6),
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
                        borderRadius: BorderRadius.circular(16),
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
