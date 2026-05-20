import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../application/cart_controller.dart';
import '../../application/market_controller.dart';
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
  int _imageIndex = 0;
  bool _showFullDescription = false;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(marketProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: productsAsync.when(
        loading: () => const LoadingView(message: 'Memuat detail produk...'),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Gagal memuat detail produk.\n$error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.error),
            ),
          ),
        ),
        data: (products) {
          final product =
              widget.initialProduct ?? _findById(products, widget.productId);

          if (product == null) {
            return Center(
              child: Text(
                'Produk tidak ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final gallery = _buildGallery(product);
          if (_imageIndex >= gallery.length) {
            _imageIndex = 0;
          }

          final cart = ref.watch(cartControllerProvider);
          final inCart = cart.items.any(
            (item) => item.product.idProduk == product.idProduk,
          );
          final stockHabis = product.stok <= 0;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _heroSection(context, product, gallery),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaProduk,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 33,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _summaryCard(product),
                          const SizedBox(height: 26),
                          _sectionTitle('Deskripsi'),
                          const SizedBox(height: 12),
                          _sectionBody(
                            _showFullDescription
                                ? product.deskripsi
                                : _truncateDescription(
                                    product.deskripsi,
                                    maxChars: 240,
                                  ),
                          ),
                          if (product.deskripsi.length > 240)
                            TextButton(
                              onPressed: () => setState(
                                () => _showFullDescription =
                                    !_showFullDescription,
                              ),
                              child: Text(
                                _showFullDescription
                                    ? 'Lihat lebih sedikit'
                                    : 'Lihat selengkapnya',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          _sectionTitle('Harga'),
                          const SizedBox(height: 8),
                          Text(
                            _rupiah(product.harga),
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle('Cara Penggunaan'),
                          const SizedBox(height: 10),
                          _sectionBody(product.caraPenggunaan),
                          const SizedBox(height: 22),
                          _sectionTitle('Stok'),
                          const SizedBox(height: 8),
                          Text(
                            product.stok > 0
                                ? 'Tersedia ${product.stok} item'
                                : 'Stok habis',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: product.stok > 0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle('Rating'),
                          const SizedBox(height: 10),
                          _ratingCard(product),
                          const SizedBox(height: 22),
                          _sectionTitle('Informasi Seller'),
                          const SizedBox(height: 10),
                          _sellerCard(product),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _bottomCta(
                context: context,
                disabled: stockHabis,
                text: stockHabis
                    ? 'Stok Habis'
                    : (inCart
                          ? 'Tambah Lagi ke Keranjang'
                          : 'Tambahkan Produk'),
                onTap: stockHabis
                    ? null
                    : () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.namaProduk} ditambahkan ke keranjang',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _buildGallery(MarketProduct product) {
    final items = <String>[];
    if (product.gambarUrl != null && product.gambarUrl!.isNotEmpty) {
      items.add(product.gambarUrl!);
    }
    for (final url in product.gambarGaleri) {
      if (url.isNotEmpty && !items.contains(url)) {
        items.add(url);
      }
    }
    return items;
  }

  MarketProduct? _findById(List<MarketProduct> products, int id) {
    for (final product in products) {
      if (product.idProduk == id) {
        return product;
      }
    }
    return null;
  }

  Widget _heroSection(
    BuildContext context,
    MarketProduct product,
    List<String> gallery,
  ) {
    final image = gallery.isNotEmpty ? gallery[_imageIndex] : null;

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image == null)
                Container(
                  color: const Color(0xFFF0F3EC),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 56,
                    color: Color(0xFF7DA36B),
                  ),
                )
              else
                Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF0F3EC),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                      color: Color(0xFF7DA36B),
                    ),
                  ),
                ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 18,
                child: _topAction(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 18,
                child: Row(
                  children: [
                    _topAction(
                      icon: _favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _favorite
                          ? const Color(0xFFE53935)
                          : const Color(0xFF2E7D32),
                      onTap: () => setState(() => _favorite = !_favorite),
                    ),
                    const SizedBox(width: 10),
                    _topAction(
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => context.push('/cart'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (gallery.length > 1)
          SizedBox(
            height: 82,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final active = index == _imageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _imageIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF5BBF3D)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(gallery[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _topAction({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF2E7D32),
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  Widget _summaryCard(MarketProduct product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryColumn('Jenis', product.jenis),
          _dividerVertical(),
          _summaryColumn('Berat', product.berat),
          _dividerVertical(),
          _summaryColumn('Manfaat', product.manfaat),
        ],
      ),
    );
  }

  Widget _summaryColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(17, 17, 17, 0.60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerVertical() {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.black.withValues(alpha: 0.14),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111111),
      ),
    );
  }

  Widget _sectionBody(String value) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 15.5,
        height: 1.8,
        fontWeight: FontWeight.w400,
        color: const Color.fromRGBO(17, 17, 17, 0.82),
      ),
    );
  }

  Widget _ratingCard(MarketProduct product) {
    if (product.jumlahUlasan <= 0 || product.rating <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Text(
          'Belum ada ulasan.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(17, 17, 17, 0.60),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(
            product.rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(width: 10),
          ...List.generate(
            5,
            (index) => Icon(
              index < product.rating.round()
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: const Color(0xFFF9A825),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '(${product.jumlahUlasan} ulasan)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(17, 17, 17, 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerCard(MarketProduct product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF6E8),
              shape: BoxShape.circle,
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.lokasiToko,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(17, 17, 17, 0.62),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _bottomCta({
    required BuildContext context,
    required String text,
    required VoidCallback? onTap,
    required bool disabled,
  }) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 20,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6CAB1D).withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.shopping_cart_outlined, size: 22),
              label: Text(
                text,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: disabled
                    ? const Color(0xFFC6D5BC)
                    : const Color(0xFF6CAB1D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _truncateDescription(String input, {required int maxChars}) {
    if (input.length <= maxChars) {
      return input;
    }
    return '${input.substring(0, maxChars).trim()}...';
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
