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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 132),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderActions(
                            isFavorite: isFavorite,
                            onBack: () => context.pop(),
                            onCart: () => context.push('/cart'),
                            onToggleFavorite: () => ref
                                .read(wishlistControllerProvider.notifier)
                                .toggleFavorite(product.idProduk),
                          ),
                          const SizedBox(height: 16),
                          _GallerySection(
                            controller: _galleryController,
                            images: gallery,
                            currentIndex: _currentImageIndex,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          _SummaryCard(product: product),
                          const SizedBox(height: 18),
                          _DetailSection(product: product),
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
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.isFavorite,
    required this.onBack,
    required this.onCart,
    required this.onToggleFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onCart;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIcon(icon: Icons.arrow_back_rounded, onTap: onBack),
        const Spacer(),
        _CircleIcon(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isFavorite ? const Color(0xFFFF8B8B) : Colors.white,
          onTap: onToggleFavorite,
        ),
        const SizedBox(width: 10),
        _CircleIcon(icon: Icons.shopping_bag_outlined, onTap: onCart),
      ],
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
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.controller,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6FAF0), Color(0xFFE7F1DD)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: PageView.builder(
              controller: controller,
              itemCount: images.isEmpty ? 1 : images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final imageUrl = images.isEmpty ? null : images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Colors.white,
                    child: imageUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 58,
                              color: Color(0xFF7A8E6B),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 58,
                                    color: Color(0xFF7A8E6B),
                                  ),
                                ),
                          ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.isEmpty ? 1 : images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: currentIndex == index
                      ? const Color(0xFF6A9B56)
                      : const Color(0xFFB9C9B0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF0F281F),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.namaProduk,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.namaToko,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFDCE9D0),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _rupiah(product.harga),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F4EA),
                ),
              ),
              const Spacer(),
              _MetricChip(
                icon: Icons.star_rounded,
                label: product.rating <= 0
                    ? 'Baru'
                    : '${product.rating.toStringAsFixed(1)} (${product.jumlahUlasan})',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: product.kategori),
              _InfoChip(label: product.berat),
              _InfoChip(
                label: product.stok > 0 ? 'Stok ${product.stok}' : 'Stok habis',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _rupiah(double value) {
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF0B221B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Deskripsi'),
          const SizedBox(height: 8),
          _BodyText(product.deskripsi),
          const SizedBox(height: 18),
          _SectionTitle('Manfaat'),
          const SizedBox(height: 8),
          _BodyText(product.manfaat),
          const SizedBox(height: 18),
          _SectionTitle('Cara Penggunaan'),
          const SizedBox(height: 8),
          _BodyText(product.caraPenggunaan),
          const SizedBox(height: 18),
          _SectionTitle('Informasi Toko'),
          const SizedBox(height: 10),
          _SellerCard(product: product),
        ],
      ),
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
                child: TextButton(
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
                  child: Text(
                    outOfStock
                        ? 'Stok Habis'
                        : (inCart ? 'Tambah Lagi' : 'Tambah ke Keranjang'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 56,
              width: 138,
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
                child: TextButton(
                  onPressed: onCheckout,
                  child: Text(
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
          ],
        ),
      ),
    );
  }
}
