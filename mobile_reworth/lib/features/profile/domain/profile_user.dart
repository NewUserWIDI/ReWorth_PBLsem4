// lib/features/profile/domain/profile_user.dart
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
  final DateTime createdAt;

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
    required this.createdAt,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as String,
      nama:
          (json['nama_lengkap'] as String?) ??
          (json['nama'] as String?) ??
          'Pengguna ReWorth',
      email: json['email'] as String? ?? '-',
      noTelp:
          (json['no_telp'] as String?) ?? (json['nomor_hp'] as String?) ?? '',
      fotoProfil: json['foto_profil'] as String? ?? '',
      totalPoin: (json['total_poin'] as num?)?.toInt() ?? 0,
      totalLaporanValid:
          (json['total_laporan_valid'] as num?)?.toInt() ??
          (json['laporan_valid'] as num?)?.toInt() ??
          0,
      setorSampahKg: (json['setor_sampah_kg'] as num?)?.toInt() ?? 0,
      role: json['role'] as String? ?? 'user',
      statusPengajuanSeller:
          json['status_pengajuan_seller'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
