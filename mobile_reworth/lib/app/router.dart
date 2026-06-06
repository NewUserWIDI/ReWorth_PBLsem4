import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_reworth/core/constants/app_spacing.dart';
import 'package:mobile_reworth/features/auth/application/auth_controller.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/home_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/notifications_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_reworth/features/auth/presentation/pages/welcome_page.dart';
import 'package:mobile_reworth/features/lapor_sampah/presentation/pages/report_history_page.dart';
import 'package:mobile_reworth/features/lapor_sampah/presentation/pages/report_page.dart';
import 'package:mobile_reworth/features/market/domain/checkout_payment_session.dart';
import 'package:mobile_reworth/features/market/domain/market_product.dart';
import 'package:mobile_reworth/features/market/presentation/pages/cart_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/checkout_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/market_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/order_history_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/product_detail_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/qris_payment_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/seller_registration_page.dart';
import 'package:mobile_reworth/features/market/presentation/pages/wishlist_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/address_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/bank_account_detail_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/payment_method_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/rewards_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/seller_application_detail_page.dart';
import 'package:mobile_reworth/features/profile/presentation/pages/seller_application_page.dart';
import 'package:mobile_reworth/features/profile/domain/bank_account.dart';
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // ==================== SHELL ROUTE (BOTTOM NAVIGATION) ====================
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
      // ========================================
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
        builder: (context, state) => const RewardsPage(),
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
        path: '/seller-application',
        builder: (context, state) => const SellerApplicationPage(),
      ),
      GoRoute(
        path: '/seller-application-detail',
        name: 'seller-application-detail',
        builder: (context, state) => const SellerApplicationDetailPage(),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
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
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) => QrisPaymentPage(
          session: state.extra is CheckoutPaymentSession
              ? state.extra as CheckoutPaymentSession
              : null,
        ),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistPage(),
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const AddressPage(),
      ),
      GoRoute(
        path: '/payment-method',
        builder: (context, state) => const PaymentMethodPage(),
      ),
      GoRoute(
        path: '/bank-account-detail',
        name: 'bank-account-detail',
        builder: (context, state) {
          final account = state.extra as BankAccount;
          return BankAccountDetailPage(account: account);
        },
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});

  final Widget child;

  static const _tabs = ['/home', '/report', '/market', '/profile'];

  // Daftar route yang TIDAK boleh menampilkan bottom navigation bar
  static const _noNavRoutes = [
    '/report-history',
    '/rewards',
    '/address',
    '/payment-method',
    '/profile-edit',
    '/order-history',
    '/wishlist',
    '/cart',
    '/checkout',
    '/notifications',
    '/seller-application',
    '/seller-application-detail',
    '/seller-registration',
    '/history',
    '/reward',
  ];

  int _indexFromLocation(String location) {
    final idx = _tabs.indexWhere((route) => location.startsWith(route));
    return idx == -1 ? 0 : idx;
  }

  bool _shouldShowNav(String location) {
    for (final route in _noNavRoutes) {
      if (location.startsWith(route)) {
        return false;
      }
    }
    // Juga sembunyikan jika bukan di tab utama
    final isMainTab = _tabs.any((route) => location.startsWith(route));
    return isMainTab;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final showNav = _shouldShowNav(location);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: showNav
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1F12).withOpacity(0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: index,
                      onTap: (value) => context.go(_tabs[value]),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: const Color(0xFF8EEA5B),
                      unselectedItemColor: Colors.white.withOpacity(0.55),
                      iconSize: 24,
                      selectedLabelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      type: BottomNavigationBarType.fixed,
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.home_outlined),
                          activeIcon: _ActiveNavIcon(
                            child: const Icon(Icons.home),
                          ),
                          label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.report_gmailerrorred_outlined),
                          activeIcon: _ActiveNavIcon(
                            child: const Icon(Icons.report_gmailerrorred),
                          ),
                          label: 'Lapor',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.storefront_outlined),
                          activeIcon: _ActiveNavIcon(
                            child: const Icon(Icons.storefront),
                          ),
                          label: 'Market',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.person_outline),
                          activeIcon: _ActiveNavIcon(
                            child: const Icon(Icons.person),
                          ),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _ActiveNavIcon extends StatelessWidget {
  const _ActiveNavIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8EEA5B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8EEA5B).withOpacity(0.18),
            blurRadius: 18,
          ),
        ],
      ),
      child: child,
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
