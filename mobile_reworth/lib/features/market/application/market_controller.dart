import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/market_repository.dart';
import '../domain/market_product.dart';

final marketProductsProvider = FutureProvider<List<MarketProduct>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.fetchProducts();
});

