class MarketProduct {
  const MarketProduct({
    required this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.namaToko,
    required this.kategori,
  });

  final int idProduk;
  final String namaProduk;
  final double harga;
  final int stok;
  final String? gambarUrl;
  final String namaToko;
  final String kategori;
}
