import 'market_product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.selected,
  });

  final MarketProduct product;
  final int quantity;
  final bool selected;

  double get subtotal => product.harga * quantity;

  CartItem copyWith({int? quantity, bool? selected}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }
}
