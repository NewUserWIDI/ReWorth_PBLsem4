import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../application/cart_controller.dart';
import '../../application/market_controller.dart';
import '../../application/wishlist_controller.dart';
import '../../domain/market_product.dart';
import '../widgets/market_catalog_card.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(marketProductsProvider);
    final auth = ref.watch(authControllerProvider);
    final userName = auth.currentUser?.nama ?? 'Fatma';

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003B2F),
                  Color(0xFF002D24),
                  Color(0xFF001F1A),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: const Center(
              child: _AmbientGlow(
                size: 320,
                color: Color.fromRGBO(183, 241, 100, 0.16),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -110,
            child: _AmbientGlow(
              size: 250,
              color: const Color.fromRGBO(183, 241, 100, 0.10),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xFFFAFAF7),
              onRefresh: () async {
                ref.invalidate(marketProductsProvider);
                await ref.read(marketProductsProvider.future);
              },
              child: productsAsync.when(
                loading: () =>
                    const LoadingView(message: 'Memuat produk mini market...'),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [_MarketError(message: error.toString())],
                ),
                data: (products) {
                  final wishlistIds = ref.watch(wishlistControllerProvider);
                  final categories = _buildCategories(products);
                  if (!categories.contains(_selectedCategory)) {
                    _selectedCategory = 'Semua';
                  }

                  final filteredProducts = _filterProducts(products);
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _buildHeader(context, userName),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildBanner(),
                      const SizedBox(height: 18),
                      _buildCategoryChips(categories),
                      const SizedBox(height: 20),
                      if (filteredProducts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 34),
                          child: EmptyState(
                            message:
                                'Belum ada produk tersedia untuk filter ini.',
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 380;
                            final aspectRatio = isNarrow ? 0.62 : 0.68;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: aspectRatio,
                                  ),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return MarketCatalogCard(
                                  product: product,
                                  isFavorite: wishlistIds.contains(
                                    product.idProduk,
                                  ),
                                  onTapFavorite: () => ref
                                      .read(wishlistControllerProvider.notifier)
                                      .toggleFavorite(product.idProduk),
                                  onTapAdd: () {
                                    ref
                                        .read(cartControllerProvider.notifier)
                                        .addProduct(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFF173A2C,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          '${product.namaProduk} ditambahkan ke keranjang',
                                        ),
                                      ),
                                    );
                                  },
                                  onTapCard: () => context.push(
                                    '/market/product/${product.idProduk}',
                                    extra: product,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 26),
                      _buildSellerCta(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Berbelanja',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _ActionIcon(
              icon: Icons.favorite_border_rounded,
              onTap: () => context.push('/wishlist'),
            ),
            const SizedBox(width: 10),
            _ActionIcon(
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.push('/cart'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _searchController.text.isEmpty
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.white.withValues(alpha: 0.76),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              cursorColor: const Color(0xFFD8F0C8),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Cari produk',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.46),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: -18,
          child: _AmbientGlow(
            size: 130,
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/banner_market.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'Kategori',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 98,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isActive = category == _selectedCategory;
              return InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 84,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF5FAEE), Color(0xFFDDEFD1)],
                          )
                        : null,
                    color: isActive
                        ? null
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isActive ? 0.16 : 0.12,
                      ),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFFEAF4E2)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          _categoryIcon(category),
                          size: 22,
                          color: isActive
                              ? const Color(0xFF163127)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.8,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF082018)
                              : Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCta(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF13372B), Color(0xFF1E4B3A), Color(0xFF315E4C)],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -46,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 335;
                final textBlock = Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Punya produk olahan sampah?',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yuk jual hasil kreativitasmu di ReWorth Mini Market dan bantu lebih banyak orang memilih produk ramah lingkungan.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.86),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
                final button = SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/seller-registration'),
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                    label: Text(
                      'Daftar Seller',
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF082018),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [textBlock]),
                      const SizedBox(height: 12),
                      button,
                    ],
                  );
                }

                return Row(
                  children: [textBlock, const SizedBox(width: 12), button],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildCategories(List<MarketProduct> products) {
    final fromDb =
        products
            .map((p) => p.kategori.trim())
            .where((v) => v.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Semua', ...fromDb];
  }

  List<MarketProduct> _filterProducts(List<MarketProduct> products) {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final passCategory =
          _selectedCategory == 'Semua' || product.kategori == _selectedCategory;
      if (!passCategory) return false;
      if (query.isEmpty) return true;
      return product.namaProduk.toLowerCase().contains(query) ||
          product.namaToko.toLowerCase().contains(query) ||
          product.kategori.toLowerCase().contains(query);
    }).toList();
  }

  IconData _categoryIcon(String category) {
    final key = category.toLowerCase();
    if (key.contains('semua')) return Icons.apps_rounded;
    if (key.contains('kompos') || key.contains('organik')) {
      return Icons.spa_rounded;
    }
    if (key.contains('kerajinan') || key.contains('aksesoris')) {
      return Icons.chair_rounded;
    }
    if (key.contains('eco') || key.contains('living')) {
      return Icons.lightbulb_outline_rounded;
    }
    if (key.contains('daur')) return Icons.recycling_rounded;
    return Icons.category_rounded;
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 76, sigmaY: 76),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  const _ActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _pressed ? 0.94 : 1.0,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Icon(
            widget.icon,
            size: 23,
            color: Colors.white.withValues(alpha: 0.90),
          ),
        ),
      ),
    );
  }
}

class _MarketError extends StatelessWidget {
  const _MarketError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFFFFD4D4),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
