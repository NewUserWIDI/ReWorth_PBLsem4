class AppUser {
  const AppUser({
    required this.nama,
    required this.nomorHp,
    required this.email,
    required this.password,
    required this.poin,
    required this.streak,
    required this.jumlahLaporanValid,
    required this.alamatTersimpan,
    required this.metodePembayaran,
    required this.wishlist,
    required this.cart,
  });

  final String nama;
  final String nomorHp;
  final String email;
  final String password;
  final int poin;
  final int streak;
  final int jumlahLaporanValid;
  final List<String> alamatTersimpan;
  final List<String> metodePembayaran;
  final List<String> wishlist;
  final List<String> cart;
}
