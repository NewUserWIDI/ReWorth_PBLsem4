import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Ganti path sesuai folder project kamu
import '../../application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // --- FIGMA COLORS (Sama dengan Fitur) ---
  static const Color featDark = Color(0xFF34600F);
  static const Color featLight = Color(0xFF6BC61F);
  static const Color featGlowColor = Color(0xFFB5FF77);
  static const Color greyMilestone = Color(0xFFD9D9D9); // Abu-abu untuk poin blm capai

  static const Color figmaSoftGrey = Color(0xFF8C8C8C);
  static const Color figmaSearchGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;
    
    final userName = (user?.nama ?? '').trim().isEmpty ? 'Fatma Azzahra Alif H.' : user!.nama;
    final points = user?.poin ?? 181;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildGreetingHeader(userName),
              const SizedBox(height: 28),
              _buildSearchBar(),
              const SizedBox(height: 32), 
              _buildTotalPointCard(points),
              const SizedBox(height: 32),
              _buildFeatureSection(),
              const SizedBox(height: 24),
              _buildBanner(),
              const SizedBox(height: 32),
              _buildActivitySection(),
              const SizedBox(height: 32),
              
              // --- SECTION REWARD STREAK (FIXED GLOW & COIN) ---
              _buildStreakSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Widget Header, Search, Point Card, Fitur, Banner, Activity tetap sama seperti sebelumnya) ...
  // Sertakan di sini agar kode utuh bisa di-copy:

  Widget _buildGreetingHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('selamat datang', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: figmaSoftGrey)),
            const SizedBox(height: 4),
            Text(userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black)),
          ])),
          Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: featLight.withOpacity(0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))]), child: const Icon(Icons.notifications_none_rounded, color: featLight, size: 30)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(height: 56, margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.symmetric(horizontal: 18), decoration: BoxDecoration(color: figmaSearchGrey, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.search_rounded, color: figmaSoftGrey.withOpacity(0.7), size: 24), const SizedBox(width: 12), Text('Cari toko/seller', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: figmaSoftGrey))]));
  }

  Widget _buildTotalPointCard(int points) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(width: double.infinity, height: 145, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, stops: [0.0, 0.50, 0.74, 0.97], colors: [Color(0xFF3B6D11), Color(0xFF498615), Color(0xFF6BC61F), Color(0xFF7ED038)]), boxShadow: [BoxShadow(color: Color(0xFF3B6D11).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))]), child: Stack(children: [Positioned(top: -5, right: -15, child: Transform.rotate(angle: -11.7 * (pi / 180), child: Opacity(opacity: 0.3, child: Image.asset('assets/images/logo_reworth.png', width: 160, fit: BoxFit.contain)))), Padding(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('TOTAL POIN', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85), letterSpacing: 1.1)), const SizedBox(height: 2), Text('$points', style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white))]))])));
  }

  Widget _buildFeatureSection() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Expanded(child: _buildFeatureCard(title: "Lapor\nSampah", assetPath: 'assets/images/3d_trash.png', isCart: false)), const SizedBox(width: 18), Expanded(child: _buildFeatureCard(title: "Mini\nMarket", assetPath: 'assets/images/cart_3d.png', isCart: true))]));
  }

  Widget _buildFeatureCard({required String title, required String assetPath, required bool isCart}) {
    return Container(height: 125, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [featDark, featLight]), boxShadow: [BoxShadow(color: featDark.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]), child: Stack(children: [Positioned(right: -40, bottom: -40, child: Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05), width: 1), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)]))), Positioned(right: -10, bottom: -15, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: featGlowColor.withOpacity(0.7)))), Padding(padding: const EdgeInsets.all(20), child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2))), Positioned(right: isCart ? -5 : 0, bottom: isCart ? -5 : -5, child: Image.asset(assetPath, height: isCart ? 95 : 105, fit: BoxFit.contain))]));
  }

  Widget _buildBanner() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/images/banner_home.png', width: double.infinity, fit: BoxFit.cover)));
  }

  Widget _buildActivitySection() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Aktifitas Terbaru", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 16), _buildActivityCard("+ 10", "Poin Bertambah dari Lapor Sampah", "Berhasil", Colors.green, Icons.add_circle_outline), _buildActivityCard("+ 10", "Poin Bertambah dari Lapor Sampah", "Berhasil", Colors.green, Icons.add_circle_outline), _buildActivityCard("+ 10", "Anda mengisi formulir pengajuan Seller", "Pending", Colors.orange, Icons.schedule_rounded), _buildActivityCard("Ditolak", "Pelaporan sampah anda ditolak admin", "Ditolak", Colors.red, Icons.cancel_outlined)]));
  }

  Widget _buildActivityCard(String val, String desc, String status, Color color, IconData icon) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Icon(icon, size: 24, color: Colors.black87), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)), Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54))])), Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(status, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color))])]));
  }

  // --- REVISI FINAL: REWARD STREAK DENGAN ELIPS GLOW ASLI & COIN ---
  Widget _buildStreakSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // GRADASI SAMA DENGAN FITUR
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [featDark, featLight],
          ),
          boxShadow: [
            BoxShadow(color: featDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // ELIPS 1: GLOW PUTIH BESAR (TEKNIK BOX SHADOW)
            Positioned(
              right: -40, bottom: -40,
              child: Container(
                width: 170, height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 45,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            // ELIPS 2: HIJAU CERAH
            Positioned(
              right: -10, bottom: -15,
              child: Container(
                width: 105, height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: featGlowColor.withOpacity(0.7),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ICON FIRE/STREAK
                      const Icon(Icons.whatshot_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Yuk Kumpulkan Poin dan Dapatkan Reward!",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // TIMELINE PROGRESS
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // GARIS HITAM TEGAS
                      Container(height: 3, width: double.infinity, color: Colors.black.withOpacity(0.8)),
                      // GARIS AKTIF (SAMPAI 15 POIN)
                      LayoutBuilder(builder: (context, constraints) {
                        return Container(height: 3, width: constraints.maxWidth * 0.53, color: featGlowColor);
                      }),
                      // DOTS MILESTONE (3 HIJAU, 2 ABU)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStreakDot("5 Poin", true),
                          _buildStreakDot("10 Poin", true),
                          _buildStreakDot("15 Poin", true),
                          _buildStreakDot("20 Poin", false),
                          _buildStreakDot("25 Poin", false),
                          const SizedBox(width: 45), // Jarak ke koin
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ICON 3D COIN (MEPET GARIS CARD)
            Positioned(
              right: -5,
              bottom: -5,
              child: Image.asset(
                'assets/images/coin.png',
                height: 85,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.monetization_on, color: Colors.orange, size: 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakDot(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 14,
          decoration: BoxDecoration(
            color: isActive ? featLight : greyMilestone,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5), // STROKE PUTIH TEBAL
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}