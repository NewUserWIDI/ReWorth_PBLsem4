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

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final MarketProduct? initialProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    initialProduct ?? _findById(products, productId);
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
                          const SizedBox(height: 12),
                          _HeroImage(url: product.gambarUrl),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFCFC),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.namaProduk,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111111),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _InfoTriplet(product: product),
                                const SizedBox(height: 20),
                                _SectionTitle('Detail Barang'),
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
                                _SectionTitle('Informasi Seller'),
                                const SizedBox(height: 10),
                                _SellerCard(product: product),
                              ],
                            ),
                          ),
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
        _CircleIcon(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        _CircleIcon(
          icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: isFavorite ? const Color(0xFFEF3D3D) : Colors.white,
          onTap: onToggleFavorite,
        ),
        const SizedBox(width: 10),
        _CircleIcon(
          icon: Icons.shopping_bag_outlined,
          onTap: onCart,
        ),
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

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        color: const Color(0xFF10311C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: (url == null || url!.isEmpty)
            ? const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 54,
                  color: Color(0xFFB7F164),
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 54,
                    color: Color(0xFFB7F164),
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoTriplet extends StatelessWidget {
  const _InfoTriplet({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.05)),
      ),
      child: Row(
        children: [
          _Cell(label: 'Jenis', value: product.jenis),
          _DividerCell(),
          _Cell(label: 'Harga', value: _rupiah(product.harga)),
          _DividerCell(),
          _Cell(
            label: 'Stok',
            value: product.stok > 0 ? '${product.stok} item' : 'Habis',
          ),
        ],
      ),
    );
  }

  String _rupiah(double value) {
    final asInt = value.toInt();
    final chars = asInt.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(17, 17, 17, 0.58),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color.fromRGBO(0, 0, 0, 0.12),
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
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111111),
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
        color: const Color.fromRGBO(17, 17, 17, 0.78),
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
        color: const Color(0xFFF6F7F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAF5E1),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFF2E7D32),
            ),
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
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.lokasiToko,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(17, 17, 17, 0.58),
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
                child: FilledButton(
                  onPressed: outOfStock ? null : onAddCart,
                  style: FilledButton.styleFrom(
                    backgroundColor: outOfStock
                        ? const Color(0xFFBFC9B9)
                        : const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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
              width: 132,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF1F5E23), Color(0xFF2E7D32)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F5E23).withValues(alpha: 0.24),
                      blurRadius: 20,
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
                      color: Colors.white,
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
