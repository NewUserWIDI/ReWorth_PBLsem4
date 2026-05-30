class ProfileUser {
  final String id;
  final String nama;
  final String email;
  final String noTelp;
  final String fotoProfil;
  final int totalPoin;
  final int totalLaporanValid;
  final int setorSampahKg;
  final String role;
  final String statusPengajuanSeller;

  ProfileUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.noTelp,
    required this.fotoProfil,
    required this.totalPoin,
    required this.totalLaporanValid,
    required this.setorSampahKg,
    required this.role,
    required this.statusPengajuanSeller,
  });

  // Copy with method
  ProfileUser copyWith({
    String? id,
    String? nama,
    String? email,
    String? noTelp,
    String? fotoProfil,
    int? totalPoin,
    int? totalLaporanValid,
    int? setorSampahKg,
    String? role,
    String? statusPengajuanSeller,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noTelp: noTelp ?? this.noTelp,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      totalPoin: totalPoin ?? this.totalPoin,
      totalLaporanValid: totalLaporanValid ?? this.totalLaporanValid,
      setorSampahKg: setorSampahKg ?? this.setorSampahKg,
      role: role ?? this.role,
      statusPengajuanSeller:
          statusPengajuanSeller ?? this.statusPengajuanSeller,
    );
  }
}
