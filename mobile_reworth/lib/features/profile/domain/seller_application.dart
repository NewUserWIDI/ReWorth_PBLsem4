// lib/features/profile/domain/seller_application.dart

import 'package:flutter/material.dart';

class SellerApplication {
  final String? idPengajuan;
  final String namaTokoUsulan;
  final String? deskripsiToko;
  final String? alamatToko;
  final String? kategoriJualan;
  final String? jenisProdukJualan;
  final String? fotoToko;
  final String? fotoProdukContoh;
  final String usernameUsulan;
  final String passwordHashUsulan;
  final String statusPengajuan;
  final String? alasanPenolakan;
  final DateTime? tanggalPengajuan;
  final DateTime? tanggalDiproses;

  SellerApplication({
    this.idPengajuan,
    required this.namaTokoUsulan,
    this.deskripsiToko,
    this.alamatToko,
    this.kategoriJualan,
    this.jenisProdukJualan,
    this.fotoToko,
    this.fotoProdukContoh,
    required this.usernameUsulan,
    required this.passwordHashUsulan,
    this.statusPengajuan = 'Pending',
    this.alasanPenolakan,
    this.tanggalPengajuan,
    this.tanggalDiproses,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_toko_usulan': namaTokoUsulan,
      'deskripsi_toko': deskripsiToko,
      'alamat_toko': alamatToko,
      'kategori_jualan': kategoriJualan,
      'jenis_produk_jualan': jenisProdukJualan,
      'foto_toko': fotoToko,
      'foto_produk_contoh': fotoProdukContoh,
      'username_usulan': usernameUsulan,
      'password_hash_usulan': passwordHashUsulan,
      'status_pengajuan': statusPengajuan,
      'alasan_penolakan': alasanPenolakan,
      'tanggal_pengajuan': tanggalPengajuan?.toIso8601String(),
      'tanggal_diproses': tanggalDiproses?.toIso8601String(),
    };
  }

  factory SellerApplication.fromJson(Map<String, dynamic> json) {
    return SellerApplication(
      idPengajuan: json['id_pengajuan']?.toString(),
      namaTokoUsulan: json['nama_toko_usulan'] as String? ?? '',
      deskripsiToko: json['deskripsi_toko'] as String?,
      alamatToko: json['alamat_toko'] as String?,
      kategoriJualan: json['kategori_jualan'] as String?,
      jenisProdukJualan: json['jenis_produk_jualan'] as String?,
      fotoToko: json['foto_toko'] as String?,
      fotoProdukContoh: json['foto_produk_contoh'] as String?,
      usernameUsulan: json['username_usulan'] as String? ?? '',
      passwordHashUsulan: json['password_hash_usulan'] as String? ?? '',
      statusPengajuan: json['status_pengajuan'] as String? ?? 'Pending',
      alasanPenolakan: json['alasan_penolakan'] as String?,
      tanggalPengajuan: json['tanggal_pengajuan'] != null
          ? DateTime.parse(json['tanggal_pengajuan'])
          : null,
      tanggalDiproses: json['tanggal_diproses'] != null
          ? DateTime.parse(json['tanggal_diproses'])
          : null,
    );
  }

  String get statusText {
    switch (statusPengajuan) {
      case 'Pending':
        return 'Menunggu Verifikasi';
      case 'Disetujui':
        return 'Disetujui';
      case 'Ditolak':
        return 'Ditolak';
      case 'Dibatalkan':
        return 'Dibatalkan';
      default:
        return statusPengajuan;
    }
  }

  Color get statusColor {
    switch (statusPengajuan) {
      case 'Pending':
        return const Color(0xFFFFA726);
      case 'Disetujui':
        return const Color(0xFF4CAF50);
      case 'Ditolak':
        return const Color(0xFFEF5350);
      case 'Dibatalkan':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
