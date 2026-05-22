class ProfileUser {
  const ProfileUser({
    required this.nama,
    required this.email,
    required this.fotoProfil,
    required this.totalPoin,
    required this.laporanValid,
    required this.setorSampahKg,
  });

  final String nama;
  final String email;
  final String fotoProfil;
  final int totalPoin;
  final int laporanValid;
  final int setorSampahKg;
}
