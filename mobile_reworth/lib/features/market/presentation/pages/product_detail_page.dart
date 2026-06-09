import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/loading_view.dart';
import '../../application/cart_controller.dart';
import '../../application/market_controller.dart';
import '../../application/wishlist_controller.dart';
import '../../domain/market_product.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final MarketProduct? initialProduct;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final PageController _galleryController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(marketProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _DetailBackdrop(),
          SafeArea(
            child: productsAsync.when(
              loading: () =>
                  const LoadingView(message: 'Memuat detail produk...'),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat detail produk.\n$error',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              data: (products) {
                final product =
                    widget.initialProduct ??
                    _findById(products, widget.productId);
                if (product == null) {
                  return Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                final gallery = _galleryUrls(product);
                if (_currentImageIndex >= gallery.length &&
                    gallery.isNotEmpty) {
                  _currentImageIndex = 0;
                }

                final isFavorite = ref.watch(
                  wishlistControllerProvider.select(
                    (ids) => ids.contains(product.idProduk),
                  ),
                );

                final cart = ref.watch(cartControllerProvider);
                final inCart = cart.items.any(
                  (item) => item.product.idProduk == product.idProduk,
                );
                final outOfStock = product.stok <= 0;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 230),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroSection(
                            controller: _galleryController,
                            images: gallery,
                            currentIndex: _currentImageIndex,
                            isFavorite: isFavorite,
                            onBack: () => context.pop(),
                            onSearch: () => context.go('/market'),
                            onToggleFavorite: () => ref
                                .read(wishlistControllerProvider.notifier)
                                .toggleFavorite(product.idProduk),
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _InfoSheet(product: product),
                        ],
                      ),
                    ),
                    _BottomActions(
                      outOfStock: outOfStock,
                      inCart: inCart,
                      onAddCart: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF173A2C),
                            content: Text(
                              '${product.namaProduk} ditambahkan ke keranjang',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        );
                      },
                      onCheckout: () => context.push('/cart'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  MarketProduct? _findById(List<MarketProduct> products, int id) {
    for (final product in products) {
      if (product.idProduk == id) {
        return product;
      }
    }
    return null;
  }

  List<String> _galleryUrls(MarketProduct product) {
    final urls = <String>[];
    if (product.gambarUrl != null && product.gambarUrl!.isNotEmpty) {
      urls.add(product.gambarUrl!);
    }
    for (final image in product.gambarGaleri) {
      if (image.isNotEmpty && !urls.contains(image)) {
        urls.add(image);
      }
    }
    return urls;
  }
}

class _DetailBackdrop extends StatelessWidget {
  const _DetailBackdrop();

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
          top: -50,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.16),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 220,
          right: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF94FF38).withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.controller,
    required this.images,
    required this.currentIndex,
    required this.isFavorite,
    required this.onBack,
    required this.onSearch,
    required this.onToggleFavorite,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> images;
  final int currentIndex;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onToggleFavorite;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.of(context).size.height * 0.43;
    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.1),
                        radius: 0.82,
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final imageUrl = images.isEmpty ? null : images[index];
                      return imageUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 72,
                                color: Color(0xFFCEE4BC),
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 72,
                                      color: Color(0xFFCEE4BC),
                                    ),
                                  ),
                            );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          const Color(0xFF001F1A).withValues(alpha: 0.18),
                          const Color(0xFF001F1A).withValues(alpha: 0.42),
                        ],
                        stops: const [0.0, 0.58, 0.82, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.isEmpty ? 1 : images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: currentIndex == index
                              ? const Color(0xFFAFD79A)
                              : Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _CircleIcon(icon: Icons.arrow_back_rounded, onTap: onBack),
                const Spacer(),
                _CircleIcon(icon: Icons.search_rounded, onTap: onSearch),
                const SizedBox(width: 10),
                _CircleIcon(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFavorite
                      ? const Color(0xFFFF8B8B)
                      : Colors.white,
                  onTap: onToggleFavorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    final infoChips = <String>[
      if (product.berat.trim().isNotEmpty && product.berat.trim() != '-')
        product.berat,
      if (product.stok > 0) 'Stok ${product.stok}' else 'Stok habis',
      if (product.lokasiToko.trim().isNotEmpty &&
          product.lokasiToko.trim().toLowerCase() != 'indonesia')
        product.lokasiToko,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      size: 16,
                      color: Color(0xFFB7E08C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.kategori,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.rating > 0) ...[
                const Spacer(),
                _MetricChip(
                  icon: Icons.star_rounded,
                  label:
                      '${product.rating.toStringAsFixed(1)} (${product.jumlahUlasan})',
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          Text(
            product.namaProduk,
            style: GoogleFonts.poppins(
              fontSize: 29,
              fontWeight: FontWeight.w700,
              height: 1.08,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(product.harga),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEAF6DD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (infoChips.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: infoChips
                  .map((value) => _InfoChip(label: value))
                  .toList(),
            ),
          const SizedBox(height: 24),
          _SectionTitle('Tentang Produk'),
          const SizedBox(height: 8),
          _BodyText(product.deskripsi),
          const SizedBox(height: 22),
          _SectionTitle('Manfaat'),
          const SizedBox(height: 10),
          _FeatureBullet(icon: Icons.eco_rounded, text: product.manfaat),
          const SizedBox(height: 22),
          _SectionTitle('Cara Penggunaan'),
          const SizedBox(height: 10),
          _FeatureBullet(
            icon: Icons.recycling_rounded,
            text: product.caraPenggunaan,
          ),
          const SizedBox(height: 22),
          _SectionTitle('Informasi Toko'),
          const SizedBox(height: 10),
          _SellerCard(product: product),
        ],
      ),
    );
  }

  static String _formatPrice(double value) {
    final asInt = value.toInt();
    final chars = asInt.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFD36C)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.8,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFE8F0DE),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFC7E79B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              height: 1.52,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 14.5,
        height: 1.58,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.78),
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A3A31),
            ),
            child: const Icon(Icons.storefront_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaToko,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.lokasiToko,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.62),
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.outOfStock,
    required this.inCart,
    required this.onAddCart,
    required this.onCheckout,
  });

  final bool outOfStock;
  final bool inCart;
  final VoidCallback onAddCart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: TextButton.icon(
                  onPressed: outOfStock ? null : onAddCart,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(
                    outOfStock
                        ? 'Stok Habis'
                        : (inCart ? 'Tambah Lagi' : 'Tambah ke Keranjang'),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 56,
              width: 156,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF2FAEA), Color(0xFFD8ECC8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: TextButton.icon(
                    onPressed: onCheckout,
                    icon: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      color: Color(0xFF0F231C),
                      size: 18,
                    ),
                    label: Text(
                      'Checkout',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F231C),
                      ),
                    ),
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
