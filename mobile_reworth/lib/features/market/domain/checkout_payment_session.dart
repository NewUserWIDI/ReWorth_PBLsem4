class CheckoutPaymentSession {
  const CheckoutPaymentSession({
    required this.orderId,
    required this.paymentId,
    required this.kodePesanan,
    required this.kodePembayaran,
    required this.totalBayar,
    required this.qrPayload,
    required this.kadaluarsaPada,
    required this.productLines,
  });

  final int orderId;
  final int paymentId;
  final String kodePesanan;
  final String kodePembayaran;
  final double totalBayar;
  final String qrPayload;
  final DateTime kadaluarsaPada;
  final List<CheckoutPaymentLine> productLines;
}

class CheckoutPaymentLine {
  const CheckoutPaymentLine({
    required this.productId,
    required this.quantity,
  });

  final int productId;
  final int quantity;
}
