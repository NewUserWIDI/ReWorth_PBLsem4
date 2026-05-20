import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/market_product.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository(Supabase.instance.client);
});

class MarketRepository {
  MarketRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<MarketProduct>> fetchProducts() async {
    final productsRaw = await _supabase
        .from('produk')
        .select()
        .order('id_produk', ascending: true);

    final productRows = List<Map<String, dynamic>>.from(productsRaw as List);
    if (productRows.isEmpty) {
      return const [];
    }

    final imagesRaw = await _supabase.from('gambar_produk').select();
    final imageRows = List<Map<String, dynamic>>.from(imagesRaw as List);
    final imageMap = <int, String>{};
    final imageGalleryMap = <int, List<String>>{};

    for (final row in imageRows) {
      final idProduk = _toInt(row['id_produk']);
      if (idProduk == null) {
        continue;
      }
      final isPrimary = row['is_primary'] == true;
      final current = imageMap[idProduk];
      final url = row['public_url']?.toString();
      if (url == null || url.isEmpty) {
        continue;
      }
      imageGalleryMap.putIfAbsent(idProduk, () => <String>[]).add(url);
      if (current == null || isPrimary) {
        imageMap[idProduk] = url;
      }
    }

    final sellerIds = productRows
        .map((row) => row['id_seller']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final sellerNames = <String, String>{};
    if (sellerIds.isNotEmpty) {
      final sellersRaw = await _supabase
          .from('profiles')
          .select('id, nama_lengkap')
          .inFilter('id', sellerIds);
      final sellerRows = List<Map<String, dynamic>>.from(sellersRaw as List);
      for (final row in sellerRows) {
        final id = row['id']?.toString();
        final name = row['nama_lengkap']?.toString();
        if (id == null || id.isEmpty || name == null || name.isEmpty) {
          continue;
        }
        sellerNames[id] = name;
      }
    }

    final categoryNames = <int, String>{};
    final categoryIds = productRows
        .map(
          (row) => _firstInt(row, const [
            'id_kategori',
            'kategori_id',
            'id_category',
          ]),
        )
        .whereType<int>()
        .toSet()
        .toList();

    if (categoryIds.isNotEmpty) {
      try {
        final categoriesRaw = await _supabase
            .from('kategori_produk')
            .select('id_kategori, nama_kategori')
            .inFilter('id_kategori', categoryIds);
        final categoryRows = List<Map<String, dynamic>>.from(
          categoriesRaw as List,
        );
        for (final row in categoryRows) {
          final id = _toInt(row['id_kategori']);
          final name = row['nama_kategori']?.toString().trim();
          if (id == null || name == null || name.isEmpty) {
            continue;
          }
          categoryNames[id] = name;
        }
      } catch (_) {
        // Fallback handled per product if table/columns belum ada.
      }
    }

    return productRows.map((row) {
      final idProduk = _toInt(row['id_produk']) ?? 0;
      final sellerId = row['id_seller']?.toString() ?? '';
      final categoryId = _firstInt(row, const [
        'id_kategori',
        'kategori_id',
        'id_category',
      ]);
      final dbCategoryName = categoryId == null
          ? null
          : categoryNames[categoryId];
      final productName =
          _firstString(row, const ['nama_produk', 'nama']) ?? 'Produk';
      final productCategory = (dbCategoryName == null || dbCategoryName.isEmpty)
          ? _fallbackCategory(productName)
          : dbCategoryName;
      final stok = _firstInt(row, const ['stok', 'stock']) ?? 0;
      final deskripsi =
          _firstString(row, const [
            'deskripsi',
            'deskripsi_produk',
            'description',
          ]) ??
          'Produk ramah lingkungan dari Mini Market ReWorth yang diolah dari material berkelanjutan.';
      final manfaat =
          _firstString(row, const ['manfaat', 'benefit']) ??
          'Membantu gaya hidup lebih ramah lingkungan.';
      final berat =
          _firstString(row, const ['berat', 'volume', 'ukuran']) ?? '-';
      final jenis =
          _firstString(row, const ['jenis', 'jenis_produk']) ?? productCategory;
      final caraPakai =
          _firstString(row, const [
            'cara_penggunaan',
            'cara_pakai',
            'cara_penggunaan_produk',
            'usage',
          ]) ??
          'Gunakan produk sesuai kebutuhan. Simpan di tempat sejuk dan kering.';
      final rating =
          _firstDouble(row, const ['rating', 'rating_rata_rata']) ?? 0;
      final jumlahUlasan =
          _firstInt(row, const [
            'jumlah_ulasan',
            'total_ulasan',
            'review_count',
          ]) ??
          0;

      return MarketProduct(
        idProduk: idProduk,
        namaProduk: productName,
        harga:
            _firstDouble(row, const [
              'harga',
              'harga_produk',
              'harga_jual',
              'price',
            ]) ??
            0,
        stok: stok,
        gambarUrl: imageMap[idProduk],
        gambarGaleri: imageGalleryMap[idProduk] ?? const [],
        namaToko: sellerNames[sellerId] ?? 'Toko ReWorth',
        kategori: productCategory,
        jenis: jenis,
        berat: berat,
        manfaat: manfaat,
        deskripsi: deskripsi,
        caraPenggunaan: caraPakai,
        rating: rating,
        jumlahUlasan: jumlahUlasan,
        lokasiToko:
            _firstString(row, const ['lokasi_toko', 'lokasi', 'asal_produk']) ??
            'Indonesia',
      );
    }).toList();
  }

  static String _fallbackCategory(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('kompos') ||
        name.contains('eco enzyme') ||
        name.contains('pupuk')) {
      return 'Kompos';
    }
    if (name.contains('tas') ||
        name.contains('kerajinan') ||
        name.contains('pot') ||
        name.contains('dekorasi')) {
      return 'Kerajinan';
    }
    if (name.contains('stainless') || name.contains('sedotan')) {
      return 'Eco Living';
    }
    if (name.contains('kaca') ||
        name.contains('lilin') ||
        name.contains('pensil')) {
      return 'Aksesoris';
    }
    return 'Daur Ulang';
  }

  static String? _firstString(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null) {
        continue;
      }
      final asString = value.toString().trim();
      if (asString.isNotEmpty) {
        return asString;
      }
    }
    return null;
  }

  static int? _firstInt(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = _toInt(row[key]);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static double? _firstDouble(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = _toDouble(row[key]);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
