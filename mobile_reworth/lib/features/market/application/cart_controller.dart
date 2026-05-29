import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_item.dart';
import '../domain/market_product.dart';

class CartState {
  const CartState({required this.items});

  final List<CartItem> items;

  List<CartItem> get selectedItems => items.where((i) => i.selected).toList();

  int get selectedProductCount => items.where((i) => i.selected).length;

  int get selectedItemQuantity => items
      .where((i) => i.selected)
      .fold(0, (sum, item) => sum + item.quantity);

  double get totalSelected => items
      .where((i) => i.selected)
      .fold(0, (sum, item) => sum + item.subtotal);
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState(items: []));

  void addProduct(MarketProduct product) {
    final index = state.items.indexWhere(
      (item) => item.product.idProduk == product.idProduk,
    );
    if (index == -1) {
      state = CartState(
        items: [
          ...state.items,
          CartItem(product: product, quantity: 1, selected: product.stok > 0),
        ],
      );
      return;
    }

    final item = state.items[index];
    if (item.quantity >= product.stok) {
      return;
    }

    final updated = [...state.items];
    updated[index] = item.copyWith(quantity: item.quantity + 1);
    state = CartState(items: updated);
  }

  void toggleSelected(int productId) {
    final updated = state.items
        .map(
          (item) => item.product.idProduk == productId
              ? item.copyWith(selected: !item.selected)
              : item,
        )
        .toList();
    state = CartState(items: updated);
  }

  bool increaseQuantity(int productId) {
    final index = state.items.indexWhere(
      (item) => item.product.idProduk == productId,
    );
    if (index == -1) {
      return false;
    }
    final item = state.items[index];
    if (item.quantity >= item.product.stok) {
      return false;
    }
    final updated = [...state.items];
    updated[index] = item.copyWith(quantity: item.quantity + 1);
    state = CartState(items: updated);
    return true;
  }

  bool decreaseQuantity(int productId) {
    final index = state.items.indexWhere(
      (item) => item.product.idProduk == productId,
    );
    if (index == -1) {
      return false;
    }
    final item = state.items[index];
    if (item.quantity <= 1) {
      return false;
    }
    final updated = [...state.items];
    updated[index] = item.copyWith(quantity: item.quantity - 1);
    state = CartState(items: updated);
    return true;
  }

  void removeProduct(int productId) {
    state = CartState(
      items: state.items
          .where((item) => item.product.idProduk != productId)
          .toList(),
    );
  }

  void clearSelected() {
    state = CartState(
      items: state.items.where((item) => !item.selected).toList(),
    );
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) {
    return CartController();
  },
);
