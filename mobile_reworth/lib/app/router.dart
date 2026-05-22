import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_reworth/core/constants/app_spacing.dart';
import 'package:mobile_reworth/features/auth/application/auth_controller.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/home_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/welcome_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/profile_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/report_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/report_history_page.dart';
import 'package:mobile_reworth/features/cart/presentation/pages/cart_page.dart';
import 'package:mobile_reworth/features/market/domain/market_product.dart';
import 'package:mobile_reworth/features/market/presentation/pages/market_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/product_detail_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/wishlist_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_reworth/features/seller_registration/presentation/pages/seller_registration_page.dart';
import 'package:mobile_reworth/shared/widgets/app_card.dart';
import 'package:mobile_reworth/shared/widgets/top_curved_header_layout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: auth,
    redirect: (context, state) {
      const publicRoutes = {'/welcome', '/login', '/register'};
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!auth.isLoggedIn && !isPublicRoute) {
        return '/welcome';
      }

      if (auth.isLoggedIn && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // ==================== SHELL ROUTE (BOTTOM NAVIGATION) ====================
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          // ✅ MENGGUNAKAN ReportPage (bukan placeholder)
          GoRoute(
            path: '/report',
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: '/market',
            builder: (context, state) => const MarketPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      // ==================== ROUTES DI LUAR BOTTOM NAVIGATION ====================
      
      // ✅ MENGGUNAKAN ReportHistoryPage (bukan placeholder)
      GoRoute(
        path: '/report-history',
        builder: (context, state) => const ReportHistoryPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Riwayat Laporan',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Tukar Poin Reward',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/reward',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Tukar Poin Reward',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/seller-registration',
        builder: (context, state) => const SellerRegistrationPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/market/product/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailPage(
            productId: id,
            initialProduct: state.extra is MarketProduct
                ? state.extra as MarketProduct
                : null,
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Checkout',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Riwayat Pesanan',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistPage(),
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Alamat Tersimpan',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/payment-method',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Metode Pembayaran',
          useGradientHeader: true,
        ),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const _PlaceholderPage(
          title: 'Edit Profile',
          useGradientHeader: true,
        ),
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});

  final Widget child;

  static const _tabs = ['/home', '/report', '/market', '/profile'];

  int _indexFromLocation(String location) {
    final idx = _tabs.indexWhere((route) => location.startsWith(route));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => context.go(_tabs[value]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred_outlined),
            activeIcon: Icon(Icons.report_gmailerrorred),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, this.useGradientHeader = false});

  final String title;
  final bool useGradientHeader;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        AppCard(
          child: Text(
            'Halaman placeholder. Akan diisi pada tahap fitur berikutnya.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );

    if (useGradientHeader) {
      return TopCurvedHeaderLayout(title: title, child: content);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}