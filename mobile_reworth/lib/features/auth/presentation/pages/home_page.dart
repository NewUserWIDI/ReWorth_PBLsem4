import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';

const _pagePadding = 20.0;

const _headerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.45, 1.0],
  colors: [
    Color(0xFF111411),
    Color(0xFF1A2A16),
    Color(0xFF2E7D32),
  ],
);

const _premiumCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
  colors: [
    Color(0xFF163018),
    Color(0xFF1F5E23),
    Color(0xFF4FAF3D),
  ],
);

const _featureCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.45, 1.0],
  colors: [
    Color(0xFF163018),
    Color(0xFF1F5E23),
    Color(0xFF3A8B34),
  ],
);

const _streakGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  stops: [0.0, 0.17, 0.50, 1.0],
  colors: [
    Color(0xFF163B1D),
    Color(0xFF245C2B),
    Color(0xFF3F9B3A),
    Color(0xFF79D84C),
  ],
);

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
      backgroundColor: const Color(0xFF10130F),
      body: Container(
        color: const Color(0xFF10130F),
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
                      _HeaderSection(name: _firstName(userName)),
                      _SearchBar(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      const _HomeBanner(),
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      decoration: const BoxDecoration(gradient: _headerGradient),
      child: Stack(
        children: [
          const _HeaderGlow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(_pagePadding, 24, _pagePadding, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'selamat datang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: Colors.white.withValues(alpha: 0.92),
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

class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -42,
      right: -54,
      child: Opacity(
        opacity: 0.10,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
          child: Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFB7F164), Colors.transparent],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: Color(0x807A7A7A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 15,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                    color: Color(0x6B111111),
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
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: Image.asset(
              'assets/images/banner_home.png',
              fit: BoxFit.cover,
            ),
          ),
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
          borderRadius: BorderRadius.circular(24),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: Color(0xD1FFFFFF),
                    ),
                  ),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 44,
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 118,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: _featureCardGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -7,
              bottom: -8,
              child: _DecorativeEllipse(size: 96),
            ),
            Positioned(
              right: 12,
              bottom: -8,
              child: Opacity(opacity: 0.88, child: _InnerEllipse(size: 72)),
            ),
            Positioned(
              right: 6,
              bottom: 0,
              child: Image.asset(
                imageAsset,
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.05,
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
          color: Colors.white.withValues(alpha: 0.14),
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
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activity.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        activity.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(24),
          gradient: _streakGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -18,
              child: _DecorativeEllipse(size: 120),
            ),
            Positioned(
              right: 8,
              bottom: -8,
              child: Opacity(opacity: 0.88, child: _InnerEllipse(size: 96)),
            ),
            Positioned(
              right: 30,
              bottom: 26,
              child: Image.asset(
                'assets/images/gift.png',
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
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
