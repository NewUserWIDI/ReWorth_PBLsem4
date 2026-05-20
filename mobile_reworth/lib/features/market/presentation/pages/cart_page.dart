import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/cart_controller.dart';
import '../../domain/cart_item.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F5),
      body: Column(
        children: [
          _CartHeader(title: 'Keranjang', onBack: () => context.pop()),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: -22),
              decoration: const BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: cart.items.isEmpty
                  ? _CartEmptyState(onTapBelanja: () => context.go('/market'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
                      itemCount: cart.items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
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
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
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
          ),
        ],
      ),
      bottomNavigationBar: _CheckoutBar(
        total: cart.totalSelected,
        selectedCount: cart.selectedProductCount,
        selectedQuantity: cart.selectedItemQuantity,
        enabled: cart.selectedProductCount > 0,
        onTapCheckout: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Checkout akan dilanjutkan di tahap berikutnya.',
                style: GoogleFonts.poppins(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 10,
        24,
        38,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F5E23), Color(0xFF2E7D32), Color(0xFF5BBF3D)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 38,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.selected && !disabled
                      ? const Color(0xFF5BBF3D)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromRGBO(17, 17, 17, 0.20),
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: item.selected && !disabled
                      ? Colors.white
                      : const Color(0xFF9AA0A6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF6E8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _CartImage(url: item.product.gambarUrl),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.namaProduk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _rupiah(item.product.harga),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: ${_rupiah(item.subtotal)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  if (disabled)
                    Text(
                      'Stok habis',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _QtyButton(
                  icon: Icons.remove_rounded,
                  background: Colors.white,
                  borderColor: const Color.fromRGBO(17, 17, 17, 0.20),
                  iconColor: const Color(0xFF111111),
                  onTap: onDecrease,
                ),
                const SizedBox(height: 8),
                Text(
                  item.quantity.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 26, color: iconColor),
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
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF7DA36B),
      );
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        14 + MediaQuery.of(context).padding.bottom,
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
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _rupiah(total),
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                Text(
                  '$selectedCount produk dipilih • $selectedQuantity item',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(17, 17, 17, 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 58,
            width: 156,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF2E7D32), Color(0xFF5BBF3D)],
                      )
                    : null,
                color: enabled ? null : const Color(0xFFC9D5BF),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF2E7D32,
                          ).withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: TextButton(
                onPressed: enabled ? onTapCheckout : null,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Checkout',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEF6E8),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 42,
                color: Color(0xFF5BBF3D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang masih kosong',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk pilih produk olahan sampah terbaik di Mini Market.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromRGBO(17, 17, 17, 0.62),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onTapBelanja,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(200, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Mulai Belanja',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
