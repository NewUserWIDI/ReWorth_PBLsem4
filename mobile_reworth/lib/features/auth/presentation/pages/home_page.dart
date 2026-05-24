import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';

const _pagePadding = 16.0;

const _headerGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  stops: [0.0, 0.52, 0.72, 1.0],
  colors: [
    Color(0xFF081F12),
    Color(0xFF13321B),
    Color(0xFF15391D),
    Color(0xFF2E7D32),
  ],
);

const _premiumCardGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  stops: [0.0, 0.63, 0.81, 0.97],
  colors: [
    Color(0xFF1B4A22),
    Color(0xFF2E7D32),
    Color(0xFF4FAF3D),
    Color(0xFF8EEA5B),
  ],
);

const _featureCardGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  stops: [0.0, 0.58, 0.82, 1.0],
  colors: [
    Color(0xFF1B4A22),
    Color(0xFF2E7D32),
    Color(0xFF4FAF3D),
    Color(0xFF8EEA5B),
  ],
);

const _streakGradient = _featureCardGradient;

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
      backgroundColor: const Color(0xFF081F12),
      body: Container(
        color: const Color(0xFF081F12),
        child: Stack(
          children: [
            const _BottomAmbientGlow(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopHeroSection(
                        name: _firstName(userName),
                        searchController: _searchController,
                        onSearchChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      _TotalPointCard(points: points),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _pagePadding,
                        ),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: _pagePadding),
                        child: Text(
                          'Aktifitas Terbaru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _pagePadding,
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < activities.length; i++) ...[
                              _ActivityCard(activity: activities[i]),
                              if (i != activities.length - 1)
                                const SizedBox(height: 12),
                            ],
                            if (activities.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Text(
                                  'Aktivitas tidak ditemukan.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StreakRewardCard(activeCount: activeNodes),
                    ],
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

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Fatma';
  final first = trimmed.split(RegExp(r'\s+')).first;
  return first[0].toUpperCase() + first.substring(1).toLowerCase();
}

class _BottomAmbientGlow extends StatelessWidget {
  const _BottomAmbientGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5BBF3D).withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopHeroSection extends StatelessWidget {
  const _TopHeroSection({
    required this.name,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String name;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 18),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF081F12),
        gradient: _headerGradient,
      ),
      child: Stack(
        children: [
          const _HeaderGlow(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'selamat datang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SearchBar(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 14),
              const _HomeBanner(),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -130,
      right: -120,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
        child: Container(
          width: 360,
          height: 360,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFB5FF77).withValues(alpha: 0.95),
                const Color(0xFF6BD544).withValues(alpha: 0.55),
                const Color(0xFF2E7D32).withValues(alpha: 0.25),
                const Color(0xFF2E7D32).withValues(alpha: 0),
              ],
              stops: const [0.0, 0.32, 0.58, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 18,
              color: const Color(0xFF111111).withValues(alpha: 0.45),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111111),
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0x73111111),
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

class _HomeBanner extends StatelessWidget {
  const _HomeBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/images/banner_home.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class _TotalPointCard extends StatelessWidget {
  const _TotalPointCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: Container(
        width: double.infinity,
        height: 112,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _premiumCardGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 18,
              top: 20,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/logo_reworth.png',
                  width: 72,
                  height: 72,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL POIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w900,
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 105,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _featureCardGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -34,
              bottom: -44,
              child: _DecorativeEllipse(size: 124),
            ),
            Positioned(
              right: -18,
              bottom: -30,
              child: _InnerEllipse(size: 92),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  imageAsset,
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeEllipse extends StatelessWidget {
  const _DecorativeEllipse({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.08),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _InnerEllipse extends StatelessWidget {
  const _InnerEllipse({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFFB5FF77), Color(0xFF8EEA5B)],
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
    statusColor: Color(0xFF5BBF3D),
    icon: Icons.monetization_on_rounded,
  ),
  _HomeActivity(
    value: '+ 10',
    description: 'Poin Bertambah dari Lapor Sampah',
    status: 'Berhasil',
    statusColor: Color(0xFF5BBF3D),
    icon: Icons.monetization_on_rounded,
  ),
  _HomeActivity(
    value: '+ 10',
    description: 'Anda telah mengisi formulir pengajuan Seller',
    status: 'Pending',
    statusColor: Color(0xFFF7931A),
    icon: Icons.blur_circular_rounded,
  ),
  _HomeActivity(
    value: 'Ditolak',
    description: 'Pelaporan sampah anda ditolak oleh admin',
    status: 'Ditolak',
    statusColor: Color(0xFFE40000),
    icon: Icons.cancel_outlined,
  ),
];

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final _HomeActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(activity.icon, size: 25, color: const Color(0xFF111111)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xB8111111),
                  ),
                ),
                Text(
                  activity.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(activity: activity),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.activity});

  final _HomeActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: activity.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        activity.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: activity.statusColor,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: Container(
        width: double.infinity,
        height: 145,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _streakGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -42,
              bottom: -52,
              child: _DecorativeEllipse(size: 150),
            ),
            Positioned(
              right: -22,
              bottom: -34,
              child: _InnerEllipse(size: 112),
            ),
            Positioned(
              right: 18,
              bottom: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/gift.png',
                  width: 62,
                  height: 62,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yuk Kumpulkan Poin dan Dapatkan Reward!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _RewardProgress(labels: labels, active: active),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardProgress extends StatelessWidget {
  const _RewardProgress({required this.labels, required this.active});

  final List<String> labels;
  final int active;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const nodeSize = 18.0;
        const lineHeight = 4.0;
        const rightReserved = 106.0;
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
          height: 52,
          child: Stack(
            children: [
              Positioned(
                left: nodeSize / 2,
                right: constraints.maxWidth - usableWidth + nodeSize / 2,
                top: centerY - lineHeight / 2,
                child: Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
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
                      color: const Color(0xFFB5FF77),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                width: usableWidth,
                top: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(labels.length, (index) {
                    final isActive = index < active;
                    return Container(
                      width: nodeSize,
                      height: nodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFFB5FF77)
                            : Colors.white.withValues(alpha: 0.35),
                        border: Border.all(color: Colors.white, width: 1.6),
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                left: 0,
                width: usableWidth,
                              top: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map(
                        (label) => SizedBox(
                          width: 42,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
    );
  }
}
