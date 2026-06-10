class ProfileUser {
  final String id;
  final String nama;
  final String email;
  final String noTelp;
  final String? fotoProfil;
  final int totalPoin;
  final int totalLaporanValid;
  final int streakPoin;
  final int setorSampahKg;
  final String role;
  final String? statusPengajuanSeller; // Bisa null
  final DateTime createdAt;

  ProfileUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.noTelp,
    this.fotoProfil,
    required this.totalPoin,
    required this.totalLaporanValid,
    required this.streakPoin,
    required this.setorSampahKg,
    required this.role,
    this.statusPengajuanSeller,
    required this.createdAt,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as String,
      nama: json['nama_lengkap'] as String? ?? json['nama'] as String? ?? '',
      email: json['email'] as String,
      noTelp: json['no_telp'] as String? ?? json['nomor_hp'] as String? ?? '',
      fotoProfil: json['foto_profil'] as String?,
      totalPoin: (json['total_poin'] as num?)?.toInt() ?? 0,
      totalLaporanValid: (json['total_laporan_valid'] as num?)?.toInt() ?? 0,
      streakPoin: (json['streak_poin'] as num?)?.toInt() ?? 0,
      setorSampahKg: (json['setor_sampah_kg'] as num?)?.toInt() ?? 0,
      role: json['role'] as String? ?? 'user',
      statusPengajuanSeller: json['status_pengajuan_seller'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': nama,
      'email': email,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
      'total_poin': totalPoin,
      'total_laporan_valid': totalLaporanValid,
      'streak_poin': streakPoin,
      'setor_sampah_kg': setorSampahKg,
      'role': role,
      'status_pengajuan_seller': statusPengajuanSeller,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
