import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cart_item.dart';
import '../domain/checkout_payment_session.dart';
import '../domain/checkout_pricing.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(Supabase.instance.client);
});

class CheckoutRepository {
  CheckoutRepository(this._client);

  final SupabaseClient _client;

  Future<CheckoutPaymentSession> createPendingCheckout({
    required String userId,
    required int addressId,
    required double shippingFee,
    required List<CartItem> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Tidak ada item yang dipilih untuk checkout.');
    }

    final pricing = CheckoutPricing.fromItems(
      items,
      biayaPengiriman: shippingFee,
    );
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 15));
    final kodePesanan = _buildCode('ORD', now);
    final kodePembayaran = _buildCode('QRD', now);
    final qrPayload =
        'reworth://qris/$kodePembayaran?amount=${pricing.totalBayar.round()}';

    final orderPayload = {
      'kode_pesanan': kodePesanan,
      'id_masyarakat': userId,
      'id_alamat': addressId,
      'tanggal_pesanan': now.toIso8601String(),
      'status_pesanan': 'baru',
      'subtotal': pricing.subtotalProduk,
      'biaya_pengiriman': pricing.biayaPengiriman,
      'pajak': pricing.feePlatform,
      'total_bayar': pricing.totalBayar,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final extendedOrderPayload = {
      ...orderPayload,
      'subtotal_produk': pricing.subtotalProduk,
      'fee_platform_persen': pricing.feePlatformPersen,
      'fee_platform': pricing.feePlatform,
      'biaya_layanan': pricing.biayaLayanan,
    };

    final orderInsert = await _insertWithVariants(
      table: 'pesanan',
      payloads: [
        extendedOrderPayload,
        orderPayload,
        {...extendedOrderPayload, 'status_pesanan': 'pending'},
        {...orderPayload, 'status_pesanan': 'pending'},
        {...extendedOrderPayload, 'status_pesanan': 'menunggu'},
        {...orderPayload, 'status_pesanan': 'menunggu'},
      ],
    );
    final orderRow = Map<String, dynamic>.from(orderInsert);
    final orderId = _readInt(orderRow, const ['id_pesanan']);
    if (orderId == null) {
      throw Exception('ID pesanan tidak ditemukan setelah checkout.');
    }

    final detailPayloads = <Map<String, dynamic>>[];
    final fallbackDetailPayloads = <Map<String, dynamic>>[];
    for (final item in items) {
      final allocation = pricing.itemAllocations.firstWhere(
        (line) => line.productId == item.product.idProduk,
      );
      final basePayload = {
        'id_pesanan': orderId,
        'id_produk': item.product.idProduk,
        'jumlah': item.quantity,
        'harga_satuan': item.product.harga,
        'subtotal': item.subtotal,
        'created_at': now.toIso8601String(),
      };
      fallbackDetailPayloads.add(basePayload);
      detailPayloads.add({
        ...basePayload,
        'id_seller': item.product.sellerId,
        'fee_platform_item': allocation.feePlatformItem,
        'pendapatan_seller': allocation.pendapatanSeller,
        'status_pencairan': 'tertahan',
      });
    }

    await _insertListWithFallback(
      table: 'detail_pesanan',
      primaryPayloads: detailPayloads,
      fallbackPayloads: fallbackDetailPayloads,
    );

    final paymentPayload = {
      'id_pesanan': orderId,
      'jumlah_bayar': pricing.totalBayar,
      'status_pembayaran': 'menunggu',
      'referensi_pembayaran': kodePembayaran,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    final extendedPaymentPayload = {
      ...paymentPayload,
      'metode_pembayaran': 'QRIS Dummy',
      'provider_pembayaran': 'ReWorth QRIS Dummy',
      'kode_pembayaran': kodePembayaran,
      'qr_payload': qrPayload,
      'tanggal_kadaluarsa': expiresAt.toIso8601String(),
    };

    final paymentInsert = await _insertWithVariants(
      table: 'pembayaran',
      payloads: [
        extendedPaymentPayload,
        paymentPayload,
        {...extendedPaymentPayload, 'status_pembayaran': 'pending'},
        {...paymentPayload, 'status_pembayaran': 'pending'},
      ],
    );
    final paymentRow = Map<String, dynamic>.from(paymentInsert);
    final paymentId = _readInt(paymentRow, const ['id_pembayaran']);
    if (paymentId == null) {
      throw Exception('ID pembayaran tidak ditemukan setelah checkout.');
    }

    return CheckoutPaymentSession(
      orderId: orderId,
      paymentId: paymentId,
      kodePesanan: kodePesanan,
      kodePembayaran: kodePembayaran,
      totalBayar: pricing.totalBayar,
      qrPayload: qrPayload,
      kadaluarsaPada: expiresAt,
      productLines: [
        for (final item in items)
          CheckoutPaymentLine(
            productId: item.product.idProduk,
            quantity: item.quantity,
          ),
      ],
    );
  }

  Future<void> confirmDummyPayment(CheckoutPaymentSession session) async {
    final now = DateTime.now().toIso8601String();

    try {
      await _client
          .from('pembayaran')
          .update({
            'status_pembayaran': 'berhasil',
            'tanggal_bayar': now,
            'updated_at': now,
          })
          .eq('id_pembayaran', session.paymentId);
    } on PostgrestException {
      await _client
          .from('pembayaran')
          .update({
            'status_pembayaran': 'selesai',
            'tanggal_bayar': now,
            'updated_at': now,
          })
          .eq('id_pembayaran', session.paymentId);
    }

    await _client
        .from('pesanan')
        .update({'status_pesanan': 'diproses', 'updated_at': now})
        .eq('id_pesanan', session.orderId);

    for (final line in session.productLines) {
      final productRaw = await _client
          .from('produk')
          .select('stok')
          .eq('id_produk', line.productId)
          .single();
      final currentStock =
          _readInt(Map<String, dynamic>.from(productRaw), const ['stok']) ?? 0;
      final newStock = currentStock - line.quantity;
      await _client
          .from('produk')
          .update({'stok': newStock < 0 ? 0 : newStock, 'updated_at': now})
          .eq('id_produk', line.productId);
    }
  }

  Future<Map<String, dynamic>> _insertWithVariants({
    required String table,
    required List<Map<String, dynamic>> payloads,
  }) async {
    Object? lastError;
    for (final payload in payloads) {
      try {
        final result = await _client
            .from(table)
            .insert(payload)
            .select()
            .single();
        return Map<String, dynamic>.from(result);
      } on PostgrestException catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Gagal menyimpan data ke tabel $table.');
  }

  Future<void> _insertListWithFallback({
    required String table,
    required List<Map<String, dynamic>> primaryPayloads,
    required List<Map<String, dynamic>> fallbackPayloads,
  }) async {
    try {
      await _client.from(table).insert(primaryPayloads);
    } on PostgrestException {
      await _client.from(table).insert(fallbackPayloads);
    }
  }

  int? _readInt(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  String _buildCode(String prefix, DateTime now) {
    final millis = now.millisecondsSinceEpoch.toString();
    return '$prefix-${millis.substring(millis.length - 8)}';
  }
}
