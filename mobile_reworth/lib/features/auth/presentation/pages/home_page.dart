import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../market/data/market_repository.dart';
import '../../../market/domain/market_product.dart';
import '../../../profile/application/profile_controller.dart';
import '../../application/auth_controller.dart';

const _pagePadding = 16.0;
const _homeGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
  stops: [0.0, 0.48, 1.0],
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final SupabaseClient _client = Supabase.instance.client;
  final PageController _bannerController = PageController();

  Timer? _bannerTimer;
  int _activeBannerIndex = 0;
  bool _isLoadingHome = true;
  int _todayReportCount = 0;
  List<MarketProduct> _featuredProducts = const [];
  List<_HomeActivityItem> _recentActivities = const [];

  static const _bannerItems = <_BannerItem>[
    _BannerItem(
      title: 'Laporkan Sampah',
      subtitle: 'Bantu menjaga lingkungan dan dapatkan poin setiap hari.',
      imageAsset: 'assets/images/home_banner_lapor_sampah.png',
      backgroundStart: Color(0xFFE6F2CC),
      backgroundEnd: Color(0xFFA8D68B),
      glowColor: Color(0xFF9ED56C),
      textColor: Color(0xFF173427),
      targetRoute: '/report',
      ctaLabel: 'Mulai Sekarang',
    ),
    _BannerItem(
      title: 'Mini Market',
      subtitle: 'Temukan produk daur ulang pilihan dengan kualitas terbaik.',
      imageAsset: 'assets/images/home_banner_mini_market.png',
      backgroundStart: Color(0xFFE7F0DE),
      backgroundEnd: Color(0xFFC9DEBC),
      glowColor: Color(0xFFA5CC9A),
      textColor: Color(0xFF20372E),
      targetRoute: '/market',
      ctaLabel: 'Lihat Detail',
    ),
    _BannerItem(
      title: 'Tukar Poin',
      subtitle: 'Kumpulkan poin dan tukarkan dengan reward yang menarik.',
      imageAsset: 'assets/images/home_banner_reward.png',
      backgroundStart: Color(0xFFF1EBD7),
      backgroundEnd: Color(0xFFD8D8B2),
      glowColor: Color(0xFFC7D39B),
      textColor: Color(0xFF314136),
      targetRoute: '/rewards',
      ctaLabel: 'Tukar Sekarang',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    if (mounted) {
      setState(() => _isLoadingHome = true);
    }

    final featuredProductsFuture = ref
        .read(marketRepositoryProvider)
        .fetchProducts();
    final activityFuture = _loadActivitySummary();

    try {
      final results = await Future.wait([
        featuredProductsFuture,
        activityFuture,
      ]);
      final products = (results[0] as List<MarketProduct>)
          .where((product) => product.stok > 0)
          .take(3)
          .toList();
      final activityBundle = results[1] as _HomeActivityBundle;

      if (!mounted) {
        return;
      }

      setState(() {
        _featuredProducts = products;
        _todayReportCount = activityBundle.todayReportCount;
        _recentActivities = activityBundle.activities;
        _isLoadingHome = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _featuredProducts = const [];
        _todayReportCount = 0;
        _recentActivities = _fallbackActivities();
        _isLoadingHome = false;
      });
    }
  }

  Future<_HomeActivityBundle> _loadActivitySummary() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const _HomeActivityBundle(todayReportCount: 0, activities: []);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    int todayReportCount = 0;
    final activities = <_HomeActivityItem>[];

    try {
      final todayRows = List<Map<String, dynamic>>.from(
        await _client
                .from('laporan_sampah')
                .select('waktu_lapor')
                .eq('id_masyarakat', userId)
                .gte('waktu_lapor', startOfDay.toIso8601String())
                .lt('waktu_lapor', startOfNextDay.toIso8601String())
                .timeout(const Duration(seconds: 10))
            as List,
      );
      todayReportCount = todayRows.length;
    } catch (_) {}

    try {
      final reportRows = List<Map<String, dynamic>>.from(
        await _client
                .from('laporan_sampah')
                .select(
                  'status_laporan,poin_diberikan,waktu_lapor,jalan,kelurahan,kecamatan',
                )
                .eq('id_masyarakat', userId)
                .order('waktu_lapor', ascending: false)
                .limit(3)
                .timeout(const Duration(seconds: 10))
            as List,
      );

      for (final row in reportRows) {
        final status = (row['status_laporan'] ?? '').toString().toLowerCase();
        final points = (row['poin_diberikan'] as num?)?.toInt() ?? 0;
        final occurredAt = _parseDate(row['waktu_lapor']?.toString());
        final location = [
          (row['jalan'] ?? '').toString().trim(),
          (row['kelurahan'] ?? '').toString().trim(),
          (row['kecamatan'] ?? '').toString().trim(),
        ].where((part) => part.isNotEmpty).join(', ');

        if (status.contains('ditolak') || status.contains('rejected')) {
          activities.add(
            _HomeActivityItem(
              title: 'Laporan sampah ditolak',
              subtitle: location.isEmpty
                  ? 'Tetap terima kasih sudah berkontribusi melapor.'
                  : location,
              trailingText: points > 0 ? '+$points Poin' : '+3 Poin',
              trailingColor: const Color(0xFFF4B437),
              icon: Icons.close_rounded,
              iconBackground: const Color(0xFFFFC14C),
              occurredAt: occurredAt,
            ),
          );
          continue;
        }

        if (status.contains('selesai') ||
            status.contains('valid') ||
            status.contains('diterima') ||
            status.contains('approved')) {
          activities.add(
            _HomeActivityItem(
              title: 'Laporan sampah diterima',
              subtitle: location.isEmpty
                  ? 'Laporan Anda berhasil diverifikasi admin.'
                  : location,
              trailingText: points > 0 ? '+$points Poin' : '+10 Poin',
              trailingColor: const Color(0xFF8DCB94),
              icon: Icons.check_rounded,
              iconBackground: const Color(0xFF8DCB94),
              occurredAt: occurredAt,
            ),
          );
          continue;
        }

        activities.add(
          _HomeActivityItem(
            title: 'Laporan sedang ditinjau',
            subtitle: location.isEmpty
                ? 'Admin sedang memeriksa laporan terbaru Anda.'
                : location,
            trailingText: 'Diproses',
            trailingColor: const Color(0xFFFFD777),
            icon: Icons.schedule_rounded,
            iconBackground: const Color(0xFFE8B84D),
            occurredAt: occurredAt,
          ),
        );
      }
    } catch (_) {}

    try {
      final orderRows = List<Map<String, dynamic>>.from(
        await _client
                .from('pesanan')
                .select('status_pesanan,tanggal_pesanan,total_bayar')
                .eq('id_masyarakat', userId)
                .order('tanggal_pesanan', ascending: false)
                .limit(2)
                .timeout(const Duration(seconds: 10))
            as List,
      );

      for (final row in orderRows) {
        final status = (row['status_pesanan'] ?? '').toString();
        final occurredAt = _parseDate(row['tanggal_pesanan']?.toString());
        final total = (row['total_bayar'] as num?)?.toDouble() ?? 0;
        activities.add(
          _HomeActivityItem(
            title: 'Pembelian produk',
            subtitle: status.isEmpty ? 'Transaksi mini market' : status,
            trailingText: _formatCurrency(total),
            trailingColor: const Color(0xFFF0B35E),
            icon: Icons.shopping_bag_outlined,
            iconBackground: const Color(0xFF5F8EDC),
            occurredAt: occurredAt,
          ),
        );
      }
    } catch (_) {}

    activities.sort((a, b) {
      final aTime = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    final normalizedActivities = activities.take(5).toList();
    return _HomeActivityBundle(
      todayReportCount: todayReportCount,
      activities: normalizedActivities.isEmpty
          ? _fallbackActivities()
          : normalizedActivities,
    );
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients) {
        return;
      }
      final nextPage = (_activeBannerIndex + 1) % _bannerItems.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final authUser = auth.currentUser;
    final profileUser = profileState.user;

    final userName = profileUser?.nama ?? authUser?.nama ?? 'Pengguna ReWorth';
    final totalPoints = profileUser?.totalPoin ?? authUser?.poin ?? 0;
    final totalReports =
        profileUser?.totalLaporanValid ?? authUser?.jumlahLaporanValid ?? 0;
    final streak = authUser?.streak ?? 0;
    final missionProgress = _todayReportCount > 0 ? 1 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF8DCB94),
              backgroundColor: const Color(0xFF0A1E19),
              onRefresh: _loadHomeData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _pagePadding,
                      14,
                      _pagePadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBrandBar(
                          onNotificationTap: () =>
                              context.push('/notifications'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Selamat datang kembali,',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _firstName(userName),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            height: 1.08,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 224,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: _bannerItems.length,
                      onPageChanged: (index) {
                        setState(() => _activeBannerIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final item = _bannerItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _pagePadding,
                          ),
                          child: _BannerCard(
                            item: item,
                            onTap: () => context.go(item.targetRoute),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BannerDots(
                    count: _bannerItems.length,
                    activeIndex: _activeBannerIndex,
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                    ),
                    child: _PointHeroCard(
                      points: totalPoints,
                      totalReports: totalReports,
                      streak: streak,
                      onTapHistory: () => context.push('/rewards'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            title: 'Lapor Sampah',
                            subtitle: 'Laporkan sampah di sekitar kamu',
                            imageAsset: 'assets/images/3d_trash.png',
                            accentColor: const Color(0xFF9FD57A),
                            baseStart: const Color(0xFFDDF0C8),
                            baseEnd: const Color(0xFFBFE095),
                            textColor: const Color(0xFF173427),
                            onTap: () => context.go('/report'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _FeatureCard(
                            title: 'Mini Market',
                            subtitle: 'Belanja produk olahan sampah',
                            imageAsset: 'assets/images/cart_3d.png',
                            accentColor: const Color(0xFFC3D78D),
                            baseStart: const Color(0xFFE7F0DE),
                            baseEnd: const Color(0xFFC9DEBC),
                            textColor: const Color(0xFF20372E),
                            onTap: () => context.go('/market'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                    ),
                    child: _DailyMissionCard(
                      progress: missionProgress,
                      todayReportCount: _todayReportCount,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                    ),
                    child: _WeeklyStreakCard(streak: streak),
                  ),
                  const SizedBox(height: 22),
                  _SectionHeader(
                    title: 'Produk Pilihan',
                    actionLabel: 'Lihat Semua',
                    onTap: () => context.go('/market'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 196,
                    child: _isLoadingHome
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF8DCB94),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: _pagePadding,
                            ),
                            itemBuilder: (context, index) {
                              final product = _featuredProducts[index];
                              return _ProductCard(
                                product: product,
                                onTap: () {
                                  context.push(
                                    '/market/product/${product.idProduk}',
                                    extra: product,
                                  );
                                },
                              );
                            },
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemCount: _featuredProducts.length,
                          ),
                  ),
                  if (!_isLoadingHome && _featuredProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _pagePadding,
                        0,
                        _pagePadding,
                        0,
                      ),
                      child: Text(
                        'Belum ada produk unggulan yang bisa ditampilkan saat ini.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _SectionHeader(
                    title: 'Aktivitas Terbaru',
                    actionLabel: 'Lihat Semua',
                    onTap: () => context.push('/report-history'),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                    ),
                    child: _ActivityPanel(activities: _recentActivities),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: _homeGradient)),
        Positioned(
          top: -140,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB5FF77).withValues(alpha: 0.38),
                      const Color(0xFF5BE22F).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.46, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 240,
          right: -70,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF94FF38).withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBrandBar extends StatelessWidget {
  const _TopBrandBar({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/logo_reworth.jpeg',
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'ReWorth',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC94D),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF001F1A),
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.item, required this.onTap});

  final _BannerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [item.backgroundStart, item.backgroundEnd],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Image.asset(
              item.imageAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    item.backgroundStart,
                    item.backgroundStart.withValues(alpha: 0.98),
                    item.backgroundStart.withValues(alpha: 0.82),
                    item.backgroundStart.withValues(alpha: 0.44),
                    item.backgroundStart.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.22, 0.42, 0.60, 0.78, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -24,
              right: 88,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.glowColor.withValues(alpha: 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 148, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                      color: item.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.46,
                      fontWeight: FontWeight.w400,
                      color: item.textColor.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF184635),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      item.ctaLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

class _BannerDots extends StatelessWidget {
  const _BannerDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFAFD79A)
                : Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PointHeroCard extends StatelessWidget {
  const _PointHeroCard({
    required this.points,
    required this.totalReports,
    required this.streak,
    required this.onTapHistory,
  });

  final int points;
  final int totalReports;
  final int streak;
  final VoidCallback onTapHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFDFF1C9), const Color(0xFFCBE6A5)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C8B50).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9ED56C).withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: -24,
            child: Container(
              width: 140,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL POIN',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF315345).withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCount(points),
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF173427),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalReports laporan tervalidasi',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.45,
                        color: const Color(0xFF48665A).withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 122,
                child: ElevatedButton(
                  onPressed: onTapHistory,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF174735),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Tukar Poin',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.accentColor,
    required this.baseStart,
    required this.baseEnd,
    required this.textColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final Color accentColor;
  final Color baseStart;
  final Color baseEnd;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 176,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseStart, baseEnd],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.26),
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 16,
              child: Image.asset(
                imageAsset,
                width: 74,
                height: 74,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 134,
                    child: Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.45,
                        color: textColor.withValues(alpha: 0.76),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: textColor),
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

class _DailyMissionCard extends StatelessWidget {
  const _DailyMissionCard({
    required this.progress,
    required this.todayReportCount,
  });

  final int progress;
  final int todayReportCount;

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF123328), const Color(0xFF0B241C)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8ACD64), Color(0xFF4E9C3E)],
                  ),
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Misi Hari Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laporkan 1 titik sampah',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCompleted
                          ? 'Misi selesai. Tinggal tunggu verifikasi admin.'
                          : 'Selesaikan 1 laporan untuk membuka progres hari ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$progress/1',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.66),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _MissionRewardInfo(
                icon: Icons.check_rounded,
                iconBackground: Color(0xFF8DCB94),
                title: 'Disetujui',
                reward: '+10 poin',
                rewardColor: Color(0xFF9FDE6D),
              ),
              _MissionRewardInfo(
                icon: Icons.close_rounded,
                iconBackground: Color(0xFFFFC14C),
                title: 'Ditolak',
                reward: '+3 poin',
                rewardColor: Color(0xFFFFC14C),
              ),
            ],
          ),
          if (todayReportCount > 1) ...[
            const SizedBox(height: 12),
            Text(
              'Hari ini Anda sudah mengirim $todayReportCount laporan.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.66),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MissionRewardInfo extends StatelessWidget {
  const _MissionRewardInfo({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.reward,
    required this.rewardColor,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String reward;
  final Color rewardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF082018), size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reward,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: rewardColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyStreakCard extends StatelessWidget {
  const _WeeklyStreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final activeDays = streak.clamp(0, 7);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF17372D), const Color(0xFF0D241C)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA7D37).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFEA7D37),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak 7 Hari',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeDays == 0
                          ? 'Mulai lapor hari ini untuk menjaga progres tetap menyala.'
                          : '$activeDays/7 hari aktif minggu ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF17372D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+25',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF4EFE3),
                      ),
                    ),
                    Text(
                      'Poin',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth > 28
                    ? constraints.maxWidth - 28
                    : 0.0;
                final progressWidth = activeDays <= 0
                    ? 0.0
                    : trackWidth * (activeDays / 7);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 14,
                      right: 14,
                      top: 14,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        width: progressWidth,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA7D37),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(7, (index) {
                        final reached = index < activeDays;
                        return Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: reached
                                      ? const Color(
                                          0xFFEA7D37,
                                        ).withValues(alpha: 0.16)
                                      : const Color(0xFF17372D),
                                  border: Border.all(
                                    color: reached
                                        ? const Color(0xFFEA7D37)
                                        : Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Icon(
                                  reached
                                      ? Icons.local_fire_department_rounded
                                      : Icons.circle_outlined,
                                  size: 15,
                                  color: reached
                                      ? const Color(0xFFEA7D37)
                                      : Colors.white.withValues(alpha: 0.34),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.68),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lapor sampah setiap hari untuk membuka bonus konsisten mingguan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.60),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFAED688),
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final MarketProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 184,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE7F0D8), Color(0xFFD7E8BE)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: product.gambarUrl == null || product.gambarUrl!.isEmpty
                      ? const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF756D63),
                          size: 40,
                        )
                      : Image.network(
                          product.gambarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF756D63),
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.namaProduk,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF193226),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatCurrency(product.harga),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF193226),
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF174735),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.activities});

  final List<_HomeActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < activities.length; i++) ...[
            _ActivityRow(activity: activities[i]),
            if (i != activities.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final _HomeActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activity.iconBackground.withValues(alpha: 0.18),
            ),
            child: Icon(activity.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.66),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.trailingText,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: activity.trailingColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _timeAgo(activity.occurredAt),
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.54),
          ),
        ],
      ),
    );
  }
}

class _BannerItem {
  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.glowColor,
    required this.textColor,
    required this.targetRoute,
    required this.ctaLabel,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color glowColor;
  final Color textColor;
  final String targetRoute;
  final String ctaLabel;
}

class _HomeActivityBundle {
  const _HomeActivityBundle({
    required this.todayReportCount,
    required this.activities,
  });

  final int todayReportCount;
  final List<_HomeActivityItem> activities;
}

class _HomeActivityItem {
  const _HomeActivityItem({
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.trailingColor,
    required this.icon,
    required this.iconBackground,
    required this.occurredAt,
  });

  final String title;
  final String subtitle;
  final String trailingText;
  final Color trailingColor;
  final IconData icon;
  final Color iconBackground;
  final DateTime? occurredAt;
}

List<_HomeActivityItem> _fallbackActivities() {
  final now = DateTime.now();
  return [
    _HomeActivityItem(
      title: 'Laporan sampah diterima',
      subtitle: 'Aktivitas lingkungan Anda akan tampil di sini.',
      trailingText: '+10 Poin',
      trailingColor: const Color(0xFF9FDE6D),
      icon: Icons.check_rounded,
      iconBackground: const Color(0xFF8DCB94),
      occurredAt: now.subtract(const Duration(minutes: 10)),
    ),
    _HomeActivityItem(
      title: 'Reward ditukar',
      subtitle: 'Pantau riwayat poin dan reward dari profil Anda.',
      trailingText: '-50 Poin',
      trailingColor: const Color(0xFFF0B35E),
      icon: Icons.redeem_rounded,
      iconBackground: const Color(0xFFF0B35E),
      occurredAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'Pengguna';
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String _formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

String _formatCount(int value) {
  return NumberFormat.decimalPattern('id_ID').format(value);
}

String _timeAgo(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Baru saja';
  }

  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) {
    return 'Baru saja';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  }
  return '${diff.inDays} hari lalu';
}
