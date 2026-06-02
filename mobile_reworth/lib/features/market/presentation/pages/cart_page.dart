import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_reworth/features/market/application/cart_controller.dart';
import 'package:mobile_reworth/features/market/domain/cart_item.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _CartBackground(),
          SafeArea(
            child: Column(
              children: [
                _CartHeader(onBack: () => context.pop()),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: cart.items.isEmpty
                              ? _CartEmptyState(onTapBelanja: () => context.go('/market'))
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                                  itemCount: cart.items.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = cart.items[index];
                                    final outOfStock = item.product.stok <= 0;
                                    return _CartItemCard(
                                      item: item,
                                      disabled: outOfStock,
                                      onToggle: outOfStock
                                          ? null
                                          : () => controller.toggleSelected(
                                                item.product.idProduk,
                                              ),
                                      onIncrease: outOfStock
                                          ? null
                                          : () {
                                              final ok = controller.increaseQuantity(
                                                item.product.idProduk,
                                              );
                                              if (!ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Stok produk hanya tersedia ${item.product.stok} item.',
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      onDecrease: outOfStock
                                          ? null
                                          : () async {
                                              if (item.quantity == 1) {
                                                final remove = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text(
                                                      'Hapus produk?',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Jumlah produk sudah 1. Hapus dari keranjang?',
                                                      style: GoogleFonts.poppins(fontSize: 14),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context, false),
                                                        child: Text(
                                                          'Batal',
                                                          style: GoogleFonts.poppins(),
                                                        ),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context, true),
                                                        child: Text(
                                                          'Hapus',
                                                          style: GoogleFonts.poppins(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (remove == true) {
                                                  controller.removeProduct(
                                                    item.product.idProduk,
                                                  );
                                                }
                                                return;
                                              }
                                              controller.decreaseQuantity(
                                                item.product.idProduk,
                                              );
                                            },
                                    );
                                  },
                                ),
                        ),
                        _CheckoutBar(
                          total: cart.totalSelected,
                          selectedCount: cart.selectedProductCount,
                          selectedQuantity: cart.selectedItemQuantity,
                          enabled: cart.selectedProductCount > 0,
                          onTapCheckout: () => context.push('/checkout'),
                        ),
                      ],
                    ),
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

class _CartBackground extends StatelessWidget {
  const _CartBackground();

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
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 135, sigmaY: 135),
              child: Container(
                width: 310,
                height: 310,
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

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Text(
            'Keranjang',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.disabled,
    this.onToggle,
    this.onIncrease,
    this.onDecrease,
  });

  final CartItem item;
  final bool disabled;
  final VoidCallback? onToggle;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.62 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.selected && !disabled ? const Color(0xFF5BBF3D) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromRGBO(17, 17, 17, 0.18)),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 22,
                  color: item.selected && !disabled
                      ? Colors.white
                      : const Color(0xFF9AA0A6),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF6E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _CartImage(url: item.product.gambarUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.namaProduk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rupiah(item.product.harga),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subtotal: ${_rupiah(item.subtotal)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  if (disabled)
                    Text(
                      'Stok habis',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyButton(
                  icon: Icons.remove_rounded,
                  background: Colors.white,
                  borderColor: const Color.fromRGBO(17, 17, 17, 0.20),
                  iconColor: const Color(0xFF111111),
                  onTap: onDecrease,
                ),
                const SizedBox(width: 8),
                Text(
                  item.quantity.toString(),
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                _QtyButton(
                  icon: Icons.add_rounded,
                  background: const Color(0xFFD6FF9C),
                  borderColor: Colors.transparent,
                  iconColor: const Color(0xFF1F5E23),
                  onTap: onIncrease,
                ),
              ],
            ),
          ],
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.background,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _CartImage extends StatelessWidget {
  const _CartImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const Icon(Icons.image_not_supported_outlined, color: Color(0xFF7DA36B));
    }
    return Image.network(
      url!,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image_outlined, color: Color(0xFF7DA36B)),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.selectedCount,
    required this.selectedQuantity,
    required this.enabled,
    required this.onTapCheckout,
  });

  final double total;
  final int selectedCount;
  final int selectedQuantity;
  final bool enabled;
  final VoidCallback onTapCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 1),
                Text(
                  _rupiah(total),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                Text(
                  '$selectedCount produk dipilih • $selectedQuantity item',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(17, 17, 17, 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 52,
            width: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF1F5E23), Color(0xFF2E7D32)],
                      )
                    : null,
                color: enabled ? null : const Color(0xFFC9D5BF),
              ),
              child: TextButton(
                onPressed: enabled ? onTapCheckout : null,
                child: Text(
                  'Checkout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState({required this.onTapBelanja});

  final VoidCallback onTapBelanja;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEF6E8),
              ),
              child:
                  const Icon(Icons.shopping_cart_outlined, size: 38, color: Color(0xFF5BBF3D)),
            ),
            const SizedBox(height: 14),
            Text(
              'Keranjang masih kosong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk pilih produk olahan sampah terbaik di Mini Market.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color.fromRGBO(17, 17, 17, 0.62),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onTapBelanja,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                'Mulai Belanja',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
