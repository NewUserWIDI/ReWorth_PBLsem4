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
  _SortOption _selectedSort = _SortOption.terlaris;

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
                      _buildSortChips(),
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
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    mainAxisExtent: isNarrow ? 286 : 300,
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
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: Colors.white.withValues(alpha: 0.76),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: 'Cari produk',
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.46),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return const _MarketHeroBanner(
      title: 'Mini Market',
      subtitle: 'Temukan produk daur ulang pilihan dengan kualitas terbaik.',
      ctaLabel: 'Lihat Detail',
      imageAsset: 'assets/images/home_banner_mini_market.png',
    );
  }

  Widget _buildSortChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'Urutkan',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _SortOption.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = _SortOption.values[index];
              final isActive = option == _selectedSort;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _selectedSort = option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF6FBEF), Color(0xFFD7EDC7)],
                          )
                        : null,
                    color: isActive
                        ? null
                        : Colors.white.withValues(alpha: 0.06),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        option.icon,
                        size: 18,
                        color: isActive
                            ? const Color(0xFF082018)
                            : Colors.white.withValues(alpha: 0.82),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option.label,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF082018)
                              : Colors.white.withValues(alpha: 0.82),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3FBEA), Color(0xFFD8EDC6), Color(0xFFC1E09A)],
          stops: [0.0, 0.62, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
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
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: -50,
            child: Container(
              width: 180,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.18),
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
                          color: const Color(0xFF173427),
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
                          color: const Color(0xFF4B675A),
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
                      backgroundColor: const Color(0xFF184635),
                      foregroundColor: Colors.white,
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

  List<MarketProduct> _filterProducts(List<MarketProduct> products) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = products.where((product) {
      if (query.isEmpty) return true;
      return product.namaProduk.toLowerCase().contains(query) ||
          product.namaToko.toLowerCase().contains(query) ||
          product.kategori.toLowerCase().contains(query);
    }).toList();
    filtered.sort((a, b) => _selectedSort.compare(a, b));
    return filtered;
  }
}

enum _SortOption {
  terlaris('Terlaris', Icons.local_fire_department_rounded),
  terbaru('Terbaru', Icons.schedule_rounded),
  termurah('Termurah', Icons.south_rounded),
  termahal('Termahal', Icons.north_rounded);

  const _SortOption(this.label, this.icon);

  final String label;
  final IconData icon;

  int compare(MarketProduct a, MarketProduct b) {
    switch (this) {
      case _SortOption.terlaris:
        final bySales = b.totalTerjual.compareTo(a.totalTerjual);
        return bySales != 0 ? bySales : b.idProduk.compareTo(a.idProduk);
      case _SortOption.terbaru:
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final byDate = bDate.compareTo(aDate);
        return byDate != 0 ? byDate : b.idProduk.compareTo(a.idProduk);
      case _SortOption.termurah:
        final byPrice = a.harga.compareTo(b.harga);
        return byPrice != 0 ? byPrice : a.namaProduk.compareTo(b.namaProduk);
      case _SortOption.termahal:
        final byPrice = b.harga.compareTo(a.harga);
        return byPrice != 0 ? byPrice : a.namaProduk.compareTo(b.namaProduk);
    }
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

class _MarketHeroBanner extends StatelessWidget {
  const _MarketHeroBanner({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFEAF6DD),
                    const Color(0xFFEAF6DD).withValues(alpha: 0.98),
                    const Color(0xFFEAF6DD).withValues(alpha: 0.82),
                    const Color(0xFFEAF6DD).withValues(alpha: 0.44),
                    const Color(0xFFEAF6DD).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.22, 0.42, 0.60, 0.78, 1.0],
                ),
              ),
            ),
            Positioned(
              left: -26,
              top: -30,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              right: 32,
              top: 18,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCAEB9F).withValues(alpha: 0.20),
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
                    title,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF173427),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      height: 1.52,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF425F52),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF184635),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      ctaLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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
