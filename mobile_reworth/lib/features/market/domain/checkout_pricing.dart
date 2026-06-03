import 'cart_item.dart';

class CheckoutPricing {
  const CheckoutPricing({
    required this.subtotalProduk,
    required this.biayaPengiriman,
    required this.feePlatformPersen,
    required this.feePlatform,
    required this.biayaLayanan,
    required this.totalBayar,
    required this.itemAllocations,
  });

  static const double defaultFeePlatformPersen = 10;
  static const double defaultBiayaLayanan = 500;

  final double subtotalProduk;
  final double biayaPengiriman;
  final double feePlatformPersen;
  final double feePlatform;
  final double biayaLayanan;
  final double totalBayar;
  final List<CheckoutItemAllocation> itemAllocations;

  factory CheckoutPricing.fromItems(
    List<CartItem> items, {
    required double biayaPengiriman,
    double feePlatformPersen = defaultFeePlatformPersen,
    double biayaLayanan = defaultBiayaLayanan,
  }) {
    if (items.isEmpty) {
      return const CheckoutPricing(
        subtotalProduk: 0,
        biayaPengiriman: 0,
        feePlatformPersen: defaultFeePlatformPersen,
        feePlatform: 0,
        biayaLayanan: 0,
        totalBayar: 0,
        itemAllocations: [],
      );
    }

    final subtotalProduk = _roundCurrency(
      items.fold<double>(0, (sum, item) => sum + item.subtotal),
    );
    final feePlatform = _roundCurrency(
      subtotalProduk * (feePlatformPersen / 100),
    );
    final itemAllocations = _allocateItems(items, subtotalProduk, feePlatform);
    final totalBayar = _roundCurrency(
      subtotalProduk + biayaPengiriman + feePlatform + biayaLayanan,
    );

    return CheckoutPricing(
      subtotalProduk: subtotalProduk,
      biayaPengiriman: _roundCurrency(biayaPengiriman),
      feePlatformPersen: feePlatformPersen,
      feePlatform: feePlatform,
      biayaLayanan: biayaLayanan,
      totalBayar: totalBayar,
      itemAllocations: itemAllocations,
    );
  }

  static List<CheckoutItemAllocation> _allocateItems(
    List<CartItem> items,
    double subtotalProduk,
    double feePlatform,
  ) {
    if (items.isEmpty) {
      return const [];
    }

    var allocated = 0.0;
    final allocations = <CheckoutItemAllocation>[];

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final subtotalItem = _roundCurrency(item.subtotal);
      final isLast = index == items.length - 1;
      final feeItem = isLast
          ? _roundCurrency(feePlatform - allocated)
          : _roundCurrency(
              subtotalProduk <= 0 ? 0 : feePlatform * (subtotalItem / subtotalProduk),
            );
      allocated = _roundCurrency(allocated + feeItem);

      allocations.add(
        CheckoutItemAllocation(
          productId: item.product.idProduk,
          sellerId: item.product.sellerId,
          quantity: item.quantity,
          subtotalItem: subtotalItem,
          feePlatformItem: feeItem,
          pendapatanSeller: _roundCurrency(subtotalItem - feeItem),
        ),
      );
    }

    return allocations;
  }

  static double _roundCurrency(double value) {
    return double.parse(value.toStringAsFixed(0));
  }
}

class CheckoutItemAllocation {
  const CheckoutItemAllocation({
    required this.productId,
    required this.sellerId,
    required this.quantity,
    required this.subtotalItem,
    required this.feePlatformItem,
    required this.pendapatanSeller,
  });

  final int productId;
  final String sellerId;
  final int quantity;
  final double subtotalItem;
  final double feePlatformItem;
  final double pendapatanSeller;
}
