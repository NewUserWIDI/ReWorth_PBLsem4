import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/loading_view.dart';
import '../../application/cart_controller.dart';
import '../../application/market_controller.dart';
import '../../application/wishlist_controller.dart';
import '../widgets/market_catalog_card.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(marketProductsProvider);
    final favoriteIds = ref.watch(wishlistControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _WishlistBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _WishlistHeader(onBack: () => context.pop()),
                Expanded(
                  child: productsAsync.when(
                    loading: () =>
                        const LoadingView(message: 'Memuat wishlist...'),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Gagal memuat wishlist.\n$error',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFFFD4D4),
                          ),
                        ),
                      ),
                    ),
                    data: (products) {
                      final favorites = products
                          .where(
                            (product) => favoriteIds.contains(product.idProduk),
                          )
                          .toList();

                      if (favorites.isEmpty) {
                        return _WishlistEmpty(
                          onExplore: () => context.go('/market'),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 380;
                          final aspectRatio = isNarrow ? 0.62 : 0.68;

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: favorites.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: aspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final product = favorites[index];
                              return MarketCatalogCard(
                                product: product,
                                isFavorite: true,
                                onTapCard: () => context.push(
                                  '/market/product/${product.idProduk}',
                                  extra: product,
                                ),
                                onTapFavorite: () => ref
                                    .read(wishlistControllerProvider.notifier)
                                    .removeFavorite(product.idProduk),
                                onTapAdd: () {
                                  ref
                                      .read(cartControllerProvider.notifier)
                                      .addProduct(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF173A2C),
                                      content: Text(
                                        '${product.namaProduk} ditambahkan ke keranjang',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
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

class _WishlistBackdrop extends StatelessWidget {
  const _WishlistBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 135, sigmaY: 135),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  const _WishlistHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Wishlist',
              style: GoogleFonts.poppins(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistEmpty extends StatelessWidget {
  const _WishlistEmpty({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1FFFFFFF),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada produk favorit',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan ikon love di katalog untuk menyimpan produk yang kamu suka.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onExplore,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF082018),
                minimumSize: const Size(190, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Jelajahi Mini Market',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
