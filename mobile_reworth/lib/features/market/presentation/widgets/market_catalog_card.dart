import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/market_product.dart';

class MarketCatalogCard extends StatelessWidget {
  const MarketCatalogCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTapFavorite,
    required this.onTapAdd,
    required this.onTapCard,
  });

  final MarketProduct product;
  final bool isFavorite;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapAdd;
  final VoidCallback onTapCard;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 380;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTapCard,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF014737), Color(0xFF003B2F)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 58,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      child: _CatalogProductImage(url: product.gambarUrl),
                    ),
                    Positioned(
                      top: isCompact ? 8 : 10,
                      right: isCompact ? 8 : 10,
                      child: GestureDetector(
                        onTap: onTapFavorite,
                        child: Container(
                          width: isCompact ? 34 : 36,
                          height: isCompact ? 34 : 36,
                          decoration: BoxDecoration(
                            color: const Color(0xE6003B2F),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: isCompact ? 17 : 18,
                            color: isFavorite
                                ? const Color(0xFFFF7A7A)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 42,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 10 : 12,
                    isCompact ? 8 : 10,
                    isCompact ? 10 : 12,
                    isCompact ? 8 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.namaProduk,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isCompact ? 13.8 : 15,
                          fontWeight: FontWeight.w700,
                          height: 1.14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isCompact ? 2 : 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: isCompact ? 10 : 11,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                          SizedBox(width: isCompact ? 3 : 4),
                          Expanded(
                            child: Text(
                              product.namaToko,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 10 : 10.8,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _rupiah(product.harga),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 13.2 : 14.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF6F4EA),
                              ),
                            ),
                          ),
                          SizedBox(width: isCompact ? 6 : 8),
                          GestureDetector(
                            onTap: onTapAdd,
                            child: Container(
                              width: isCompact ? 36 : 40,
                              height: isCompact ? 36 : 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEAF6DD),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF0F231C),
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

class _CatalogProductImage extends StatelessWidget {
  const _CatalogProductImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback();
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return SizedBox.expand(child: child);
        }
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6E9A5B),
            ),
          ),
        );
      },
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE6F0DD),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF5F7D55),
        size: 30,
      ),
    );
  }
}
