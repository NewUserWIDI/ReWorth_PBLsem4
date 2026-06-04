import 'package:flutter/material.dart';

class SellerApplication {
  const SellerApplication({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.storeDescription,
    required this.storeAddress,
    required this.category,
    required this.productTypes,
    required this.usernameProposal,
    required this.passwordProposal,
    required this.status,
    required this.submittedAt,
    this.rejectionReason,
    this.processedAt,
    this.storePhotoUrl = '',
    this.samplePhotoUrl = '',
  });

  final int id;
  final String userId;
  final String storeName;
  final String storeDescription;
  final String storeAddress;
  final String category;
  final String productTypes;
  final String usernameProposal;
  final String passwordProposal;
  final String status;
  final DateTime submittedAt;
  final String? rejectionReason;
  final DateTime? processedAt;
  final String storePhotoUrl;
  final String samplePhotoUrl;

  factory SellerApplication.fromJson(Map<String, dynamic> json) {
    return SellerApplication(
      id: (json['id_pengajuan'] as num?)?.toInt() ?? 0,
      userId: (json['id_masyarakat'] ?? '').toString(),
      storeName: (json['nama_toko_usulan'] ?? '').toString(),
      storeDescription: (json['deskripsi_toko'] ?? '').toString(),
      storeAddress: (json['alamat_toko'] ?? '').toString(),
      category: (json['kategori_jualan'] ?? '').toString(),
      productTypes: (json['jenis_produk_jualan'] ?? '').toString(),
      usernameProposal: (json['username_usulan'] ?? '').toString(),
      passwordProposal: (json['password_hash_usulan'] ?? '').toString(),
      status: (json['status_pengajuan'] ?? 'Pending').toString(),
      rejectionReason:
          (json['alasan_penolakan'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['alasan_penolakan'] as String),
      submittedAt:
          DateTime.tryParse(
            (json['tanggal_pengajuan'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      processedAt: DateTime.tryParse(
        (json['tanggal_diproses'] ?? '').toString(),
      ),
      storePhotoUrl: (json['foto_toko'] ?? '').toString(),
      samplePhotoUrl: (json['foto_produk_contoh'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengajuan': id,
      'id_masyarakat': userId,
      'nama_toko_usulan': storeName,
      'deskripsi_toko': storeDescription,
      'alamat_toko': storeAddress,
      'kategori_jualan': category,
      'jenis_produk_jualan': productTypes,
      'username_usulan': usernameProposal,
      'password_hash_usulan': passwordProposal,
      'status_pengajuan': status,
      'alasan_penolakan': rejectionReason,
      'tanggal_pengajuan': submittedAt.toIso8601String(),
      'tanggal_diproses': processedAt?.toIso8601String(),
      'foto_toko': storePhotoUrl,
      'foto_produk_contoh': samplePhotoUrl,
    };
  }

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isPending => normalizedStatus == 'pending';
  bool get isApproved =>
      normalizedStatus == 'disetujui' ||
      normalizedStatus == 'approved' ||
      normalizedStatus == 'aktif';
  bool get isRejected =>
      normalizedStatus == 'ditolak' || normalizedStatus == 'rejected';

  String? get idPengajuan => id == 0 ? null : id.toString();
  String get namaTokoUsulan => storeName;
  String? get deskripsiToko => storeDescription;
  String? get alamatToko => storeAddress;
  String? get kategoriJualan => category;
  String? get jenisProdukJualan => productTypes;
  String? get fotoToko => storePhotoUrl;
  String? get fotoProdukContoh => samplePhotoUrl;
  String get usernameUsulan => usernameProposal;
  String get passwordHashUsulan => passwordProposal;
  String get statusPengajuan => status;
  String? get alasanPenolakan => rejectionReason;
  DateTime? get tanggalPengajuan => submittedAt;
  DateTime? get tanggalDiproses => processedAt;

  String get statusText {
    switch (normalizedStatus) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'disetujui':
      case 'approved':
      case 'aktif':
        return 'Disetujui';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (normalizedStatus) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'disetujui':
      case 'approved':
      case 'aktif':
        return const Color(0xFF4CAF50);
      case 'ditolak':
      case 'rejected':
        return const Color(0xFFEF5350);
      case 'dibatalkan':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
