class MarketProduct {
  const MarketProduct({
    required this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.sellerId,
    required this.gambarUrl,
    required this.gambarGaleri,
    required this.namaToko,
    required this.kategori,
    required this.jenis,
    required this.berat,
    required this.manfaat,
    required this.deskripsi,
    required this.caraPenggunaan,
    required this.rating,
    required this.jumlahUlasan,
    required this.lokasiToko,
  });

  final int idProduk;
  final String namaProduk;
  final double harga;
  final int stok;
  final String sellerId;
  final String? gambarUrl;
  final List<String> gambarGaleri;
  final String namaToko;
  final String kategori;
  final String jenis;
  final String berat;
  final String manfaat;
  final String deskripsi;
  final String caraPenggunaan;
  final double rating;
  final int jumlahUlasan;
  final String lokasiToko;
}
