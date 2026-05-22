import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/auth_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.currentUser;

    final userName = (user?.nama.trim().isNotEmpty ?? false)
        ? user!.nama
        : 'Fatma Azzahra Alif H.';
    final points = user?.poin ?? 0;
    final streak = user?.streak ?? 0;
    final activeNodes = streak > 0 ? streak.clamp(0, 5) : 3;
    final query = _searchController.text.trim().toLowerCase();
    final activities = _allActivities.where((activity) {
      if (query.isEmpty) return true;
      return activity.value.toLowerCase().contains(query) ||
          activity.description.toLowerCase().contains(query) ||
          activity.status.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                _GreetingHeader(name: userName),
                const SizedBox(height: 20),
                _SearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _TotalPointCard(points: points),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          title: 'Lapor\nSampah',
                          imageAsset: 'assets/images/3d_trash.png',
                          onTap: () => context.go('/report'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Mini\nMarket',
                          imageAsset: 'assets/images/cart_3d.png',
                          onTap: () => context.go('/market'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/banner_home.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Aktifitas Terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      for (var i = 0; i < activities.length; i++) ...[
                        _ActivityCard(
                          value: activities[i].value,
                          description: activities[i].description,
                          status: activities[i].status,
                          statusColor: activities[i].statusColor,
                          icon: activities[i].icon,
                        ),
                        if (i != activities.length - 1) const SizedBox(height: 10),
                      ],
                      if (activities.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            'Aktivitas tidak ditemukan.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6F6F6F),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _StreakRewardCard(activeCount: activeNodes),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'selamat datang',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8C8C8C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.4),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: Color(0xFF5BBF3D),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 23,
              color: const Color(0xFF8C8C8C).withValues(alpha: 0.75),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111111),
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'Cari aktivitas',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8C8C8C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActivity {
  const _HomeActivity({
    required this.value,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  final String value;
  final String description;
  final String status;
  final Color statusColor;
  final IconData icon;
}

const _allActivities = <_HomeActivity>[
  _HomeActivity(
    value: '+ 10',
    description: 'Poin Bertambah dari Lapor Sampah',
    status: 'Berhasil',
    statusColor: Color(0xFF43A047),
    icon: Icons.add_circle_outline_rounded,
  ),
  _HomeActivity(
    value: '+ 10',
    description: 'Poin Bertambah dari Lapor Sampah',
    status: 'Berhasil',
    statusColor: Color(0xFF43A047),
    icon: Icons.add_circle_outline_rounded,
  ),
  _HomeActivity(
    value: '+ 10',
    description: 'Anda mengisi formulir pengajuan Seller',
    status: 'Pending',
    statusColor: Color(0xFFF57C00),
    icon: Icons.schedule_rounded,
  ),
  _HomeActivity(
    value: 'Ditolak',
    description: 'Pelaporan sampah anda ditolak admin',
    status: 'Ditolak',
    statusColor: Color(0xFFE53935),
    icon: Icons.cancel_outlined,
  ),
];

class _TotalPointCard extends StatelessWidget {
  const _TotalPointCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 112,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0, 0.45, 1],
            colors: [Color(0xFF1F5E23), Color(0xFF2E7D32), Color(0xFF5BBF3D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 14,
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  'assets/images/logo_reworth.png',
                  width: 76,
                  height: 76,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL POIN',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$points',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0, 0.45, 1],
            colors: [Color(0xFF1F5E23), Color(0xFF2E7D32), Color(0xFF5BBF3D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 2,
              top: 12,
              child: Container(
                width: 102,
                height: 102,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.10),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 26,
              child: Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFDFF8B7), Color(0xFFA8EA63)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  imageAsset,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 90,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.94),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.value,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  final String value;
  final String description;
  final String status;
  final Color statusColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 23, color: const Color(0xFF2A2A2A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6F6F6F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakRewardCard extends StatelessWidget {
  const _StreakRewardCard({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    const labels = ['5 Poin', '10 Poin', '15 Poin', '20 Poin', '25 Poin'];
    final active = activeCount.clamp(0, labels.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 162,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0, 0.5, 1],
            colors: [Color(0xFF1F5E23), Color(0xFF2E7D32), Color(0xFF4FAF3D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -34,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB7F164).withValues(alpha: 0.12),
                      const Color(0xFFB7F164).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 14,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.10),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 28,
              bottom: 26,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFD8FF9D), Color(0xFFA8EA63)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 48,
              bottom: 48,
              child: Transform.rotate(
                angle: -0.06,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/gift.png',
                    width: 54,
                    height: 54,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.whatshot_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yuk Kumpulkan Poin dan Dapatkan Reward!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            height: 1.2,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const nodeSize = 18.0;
                      const lineHeight = 4.0;
                      const rightReserved = 132.0;
                      final usableWidth = (constraints.maxWidth - rightReserved)
                          .clamp(120.0, constraints.maxWidth);
                      final centerY = nodeSize / 2;
                      final spacing = labels.length > 1
                          ? (usableWidth - nodeSize) / (labels.length - 1)
                          : 0.0;

                      final progressEnd = active <= 0
                          ? 0.0
                          : (active >= labels.length
                                ? (usableWidth - nodeSize / 2)
                                : (nodeSize / 2 + (active - 1) * spacing));

                      return SizedBox(
                        height: 76,
                        child: Stack(
                          children: [
                            Positioned(
                              left: nodeSize / 2,
                              right:
                                  constraints.maxWidth -
                                  usableWidth +
                                  nodeSize / 2,
                              top: centerY - lineHeight / 2,
                              child: Container(
                                height: lineHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            if (progressEnd > 0)
                              Positioned(
                                left: nodeSize / 2,
                                width: progressEnd,
                                top: centerY - lineHeight / 2,
                                child: Container(
                                  height: lineHeight,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC6FF7B),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFC6FF7B,
                                        ).withValues(alpha: 0.18),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 0,
                              width: usableWidth,
                              top: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(labels.length, (index) {
                                  final isActive = index < active;
                                  return SizedBox(
                                    width: nodeSize,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: nodeSize,
                                          height: nodeSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? Colors.white
                                                : Colors.white.withValues(
                                                    alpha: 0.35,
                                                  ),
                                            border: Border.all(
                                              color: isActive
                                                  ? const Color(0xFFC6FF7B)
                                                  : Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              width: usableWidth,
                              top: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: labels
                                    .map(
                                      (label) => Text(
                                        label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(
                                            alpha: 0.92,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
