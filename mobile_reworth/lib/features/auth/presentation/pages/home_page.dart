import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Ganti path sesuai folder project kamu
import '../../application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // --- FIGMA COLORS ---
  static const Color featDark = Color(0xFF1F5E23);
  static const Color featMid = Color(0xFF2E7D32);
  static const Color featLight = Color(0xFF5BBF3D);
  static const Color featGlowColor = Color(0xFFB7F164);
  static const Color greyMilestone = Color(0xFFD9D9D9); // Abu-abu milestone

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
              
              // --- SECTION REWARD STREAK (FIXED GLOW & GIFT) ---
              _buildStreakSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER (Tetap Sama) ---

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
          Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: featLight.withValues(alpha: 0.4), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))]), child: const Icon(Icons.notifications_none_rounded, color: featLight, size: 30)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(height: 56, margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.symmetric(horizontal: 18), decoration: BoxDecoration(color: figmaSearchGrey, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.search_rounded, color: figmaSoftGrey.withValues(alpha: 0.7), size: 24), const SizedBox(width: 12), Text('Cari toko/seller', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: figmaSoftGrey))]));
  }

  Widget _buildTotalPointCard(int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 112,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0.0, 0.45, 1.0],
            colors: [featDark, featMid, featLight],
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 22,
              child: Transform.rotate(
                angle: -11.7 * (pi / 180),
                child: Opacity(
                  opacity: 0.20,
                  child: Image.asset('assets/images/logo_reworth.png', width: 92, height: 92, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL POIN', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.82), letterSpacing: 1.2)),
                  const Spacer(),
                  Text('$points', style: GoogleFonts.poppins(fontSize: 52, height: 0.95, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Expanded(child: _buildFeatureCard(title: "Lapor\nSampah", assetPath: 'assets/images/3d_trash.png', isCart: false)), const SizedBox(width: 16), Expanded(child: _buildFeatureCard(title: "Mini\nMarket", assetPath: 'assets/images/cart_3d.png', isCart: true))]));
  }

  Widget _buildFeatureCard({required String title, required String assetPath, required bool isCart}) {
    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, stops: [0.0, 0.45, 1.0], colors: [featDark, featMid, featLight]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.09)),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 10,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.10), blurRadius: 20)],
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 24,
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(center: Alignment(-0.28, -0.35), colors: [Color(0xFFDFF8B7), Color(0xFFA8EA63)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 82,
              child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.94), height: 1.35)),
            ),
          ),
          Positioned(
            right: isCart ? 28 : 27,
            bottom: isCart ? 27 : 22,
            child: Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8))]),
              child: Image.asset(assetPath, height: isCart ? 68 : 76, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/images/banner_home.png', width: double.infinity, fit: BoxFit.cover)));
  }

  Widget _buildActivitySection() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Aktifitas Terbaru", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 16), _buildActivityCard("+ 10", "Poin Bertambah dari Lapor Sampah", "Berhasil", Colors.green, Icons.add_circle_outline), _buildActivityCard("+ 10", "Poin Bertambah dari Lapor Sampah", "Berhasil", Colors.green, Icons.add_circle_outline), _buildActivityCard("+ 10", "Anda mengisi formulir pengajuan Seller", "Pending", Colors.orange, Icons.schedule_rounded), _buildActivityCard("Ditolak", "Pelaporan sampah anda ditolak admin", "Ditolak", Colors.red, Icons.cancel_outlined)]));
  }

  Widget _buildActivityCard(String val, String desc, String status, Color color, IconData icon) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Icon(icon, size: 24, color: Colors.black87), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)), Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54))])), Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(status, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color))])]));
  }

  // --- REVISI FINAL: REWARD STREAK SESUAI ARAHAN SUPER DETAIL ---
  Widget _buildStreakSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 196,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1F5F24),
              Color(0xFF2E7D32),
              Color(0xFF4FAF3D),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F5F24).withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ambient glow khusus area gift agar depth terasa tanpa membuat card berkabut.
            Positioned(
              right: -54,
              top: -10,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.12),
                  boxShadow: [BoxShadow(color: const Color(0xFFB7F164).withValues(alpha: 0.12), blurRadius: 40)],
                ),
              ),
            ),

            // Outer transparent ring.
            Positioned(
              right: 14,
              top: 42,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.10), blurRadius: 20),
                  ],
                ),
              ),
            ),

            // Inner green circle.
            Positioned(
              right: 26,
              top: 54,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.28, -0.35),
                    radius: 0.95,
                    colors: [
                      Color(0xFFD8FF9D),
                      Color(0xFFA8EA63),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              right: 38,
              top: 70,
              child: Transform.rotate(
                angle: -4 * (pi / 180),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/gift.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 198,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Yuk Kumpulkan Poin dan Dapatkan Reward!",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              height: 1.32,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final trackerWidth = constraints.maxWidth - 126;
                        final segment = (trackerWidth - 18) / 4;
                        final labels = ['5 Poin', '10 Poin', '15 Poin', '20 Poin', '25 Poin'];
                        final activeStates = [true, true, true, false, false];

                        return SizedBox(
                          width: trackerWidth,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 12,
                                left: 9,
                                right: 9,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 9,
                                width: segment * 2,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC6FF7B),
                                    borderRadius: BorderRadius.circular(99),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFC6FF7B).withValues(alpha: 0.18),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              for (var i = 0; i < labels.length; i++)
                                Positioned(
                                  left: i * segment,
                                  top: 3,
                                  child: _buildStreakNode(activeStates[i]),
                                ),
                              for (var i = 0; i < labels.length; i++)
                                Positioned(
                                  left: (i * segment) - 18,
                                  top: 34,
                                  width: 54,
                                  child: Text(
                                    labels[i],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakNode(bool isActive) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? const Color(0xFFC6FF7B) : Colors.white.withValues(alpha: 0.82), width: isActive ? 3 : 2),
      ),
    );
  }
}
