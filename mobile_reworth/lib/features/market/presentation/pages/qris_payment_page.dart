import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../application/cart_controller.dart';
import '../../data/checkout_repository.dart';
import '../../domain/checkout_payment_session.dart';

class QrisPaymentPage extends ConsumerStatefulWidget {
  const QrisPaymentPage({super.key, required this.session});

  final CheckoutPaymentSession? session;

  @override
  ConsumerState<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends ConsumerState<QrisPaymentPage> {
  final ImagePicker _picker = ImagePicker();

  Timer? _timer;
  Duration _remaining = Duration.zero;
  XFile? _proofFile;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _syncRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncRemaining(),
    );
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
        backgroundColor: const Color(0xFF061B18),
        appBar: AppBar(title: const Text('Pembayaran QRIS')),
        body: Center(
          child: Text(
            'Sesi pembayaran tidak ditemukan.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

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
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Upload Bukti Pembayaran',
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
                          ),
                          const SizedBox(height: 20),
                          const _StoreQrisCard(),
                          const SizedBox(height: 20),
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
                                  'Alur Pembayaran',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF204E17),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '1. Scan QRIS toko/admin di atas.\n2. Selesaikan pembayaran di aplikasi bank/e-wallet Anda.\n3. Upload foto bukti pembayaran.\n4. Admin akan memverifikasi sebelum pesanan diteruskan ke seller.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    height: 1.55,
                                    color: const Color(0xFF365B2D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ProofUploadCard(
                            proofFile: _proofFile,
                            onPickGallery: () =>
                                _pickProof(ImageSource.gallery),
                            onPickCamera: () => _pickProof(ImageSource.camera),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _proofFile == null || _isSubmitting
                                  ? null
                                  : _submitProof,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F5E23),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _isSubmitting
                                    ? 'Mengirim bukti...'
                                    : 'Kirim Bukti Pembayaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => context.pop(),
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

  Future<void> _pickProof(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _proofFile = picked);
  }

  Future<void> _submitProof() async {
    final session = widget.session;
    final proof = _proofFile;
    if (session == null || proof == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final bytes = await proof.readAsBytes();
      final extension = proof.path.contains('.')
          ? proof.path.split('.').last
          : 'jpg';

      await ref
          .read(checkoutRepositoryProvider)
          .submitPaymentProof(
            session: session,
            fileBytes: bytes,
            fileExtension: extension,
          );

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
          backgroundColor: const Color(0xFF7A1C1C),
          content: Text(
            'Gagal mengirim bukti pembayaran: $error',
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
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({
    required this.kodePesanan,
    required this.kodePembayaran,
    required this.totalBayar,
    required this.remaining,
  });

  final String kodePesanan;
  final String kodePembayaran;
  final double totalBayar;
  final Duration remaining;

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
            _formatDuration(remaining),
            highlight: true,
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
            color: highlight
                ? const Color(0xFF1F5E23)
                : const Color(0xFF111111),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return 'Segera upload';
    }
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

class _StoreQrisCard extends StatelessWidget {
  const _StoreQrisCard();

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
            'QRIS Toko / Admin',
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF111111), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/qris_store.jpeg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const _FakeQrisFallback(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jika belum ada file QRIS asli, letakkan gambar QR di assets/images/qris_store.jpeg',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color.fromRGBO(17, 17, 17, 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeQrisFallback extends StatelessWidget {
  const _FakeQrisFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_2_rounded,
            size: 84,
            color: Color(0xFF1F5E23),
          ),
          const SizedBox(height: 12),
          Text(
            'Tempel QRIS asli di sini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F5E23),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofUploadCard extends StatelessWidget {
  const _ProofUploadCard({
    required this.proofFile,
    required this.onPickGallery,
    required this.onPickCamera,
  });

  final XFile? proofFile;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;

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
          Text(
            'Bukti Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          if (proofFile == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFF7F8F3),
                border: Border.all(color: const Color(0xFFE1E7DA)),
              ),
              child: Text(
                'Belum ada foto bukti pembayaran yang dipilih.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color.fromRGBO(17, 17, 17, 0.62),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(proofFile!.path),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    'Galeri',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    'Kamera',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              child: Opacity(opacity: _controller.value, child: child),
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
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Bukti Terkirim',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pesanan telah terbayar dan menunggu verifikasi admin.',
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
                    'Lihat Pesanan',
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
