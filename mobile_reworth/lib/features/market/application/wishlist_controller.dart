import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistController extends StateNotifier<Set<int>> {
  WishlistController() : super(<int>{});

  void toggleFavorite(int productId) {
    final updated = <int>{...state};
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
  }

  bool isFavorite(int productId) => state.contains(productId);

  void removeFavorite(int productId) {
    if (!state.contains(productId)) {
      return;
    }
    final updated = <int>{...state}..remove(productId);
    state = updated;
  }

  void clearAll() {
    state = <int>{};
  }
}

final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, Set<int>>((ref) {
      return WishlistController();
    });
