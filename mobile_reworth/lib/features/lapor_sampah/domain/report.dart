import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'waste_type.dart';
import 'severity_level.dart';

class Report extends Equatable {
  final String? id;
  final String imagePath;
  final String street;
  final String village;
  final String district;
  final String postalCode;
  final String description;
  final WasteType wasteType;
  final SeverityLevel severityLevel;
  final DateTime createdAt;
  final String? userId;
  final String? status;
  final String? rejectionReason;

  // Field tambahan untuk database Supabase
  final int? idLaporan;
  final double? latitude;
  final double? longitude;
  final String? patokan;
  final String? alasanDitolak;
  final int poinDiberikan;
  final DateTime? updatedAt;

  const Report({
    this.id,
    required this.imagePath,
    required this.street,
    required this.village,
    required this.district,
    required this.postalCode,
    required this.description,
    required this.wasteType,
    required this.severityLevel,
    required this.createdAt,
    this.userId,
    this.status,
    this.rejectionReason,
    this.idLaporan,
    this.latitude,
    this.longitude,
    this.patokan,
    this.alasanDitolak,
    this.poinDiberikan = 0,
    this.updatedAt,
  });

  Report copyWith({
    String? id,
    String? imagePath,
    String? street,
    String? village,
    String? district,
    String? postalCode,
    String? description,
    WasteType? wasteType,
    SeverityLevel? severityLevel,
    DateTime? createdAt,
    String? userId,
    String? status,
    String? rejectionReason,
    int? idLaporan,
    double? latitude,
    double? longitude,
    String? patokan,
    String? alasanDitolak,
    int? poinDiberikan,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      street: street ?? this.street,
      village: village ?? this.village,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      description: description ?? this.description,
      wasteType: wasteType ?? this.wasteType,
      severityLevel: severityLevel ?? this.severityLevel,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      idLaporan: idLaporan ?? this.idLaporan,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      patokan: patokan ?? this.patokan,
      alasanDitolak: alasanDitolak ?? this.alasanDitolak,
      poinDiberikan: poinDiberikan ?? this.poinDiberikan,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory method untuk konversi dari Supabase JSON
  factory Report.fromSupabaseJson(Map<String, dynamic> json) {
    String statusValue = json['status_laporan'] ?? 'pending';
    String? rejectionReasonValue;

    if (statusValue == 'rejected') {
      rejectionReasonValue = json['alasan_ditolak'];
    }

    return Report(
      id: json['id_laporan'].toString(),
      idLaporan: json['id_laporan'],
      imagePath: json['foto_sampah'] ?? '',
      street: json['jalan'] ?? '',
      village: json['kelurahan'] ?? '',
      district: json['kecamatan'] ?? '',
      postalCode: '',
      description: json['deskripsi'] ?? '',
      wasteType: _mapStringToWasteType(json['jenis_sampah'] ?? 'Organik'),
      severityLevel: _mapStringToSeverity(
        json['tingkat_keparahan'] ?? 'Ringan',
      ),
      createdAt: DateTime.parse(json['waktu_lapor']),
      userId: json['id_masyarakat'],
      status: statusValue,
      rejectionReason: rejectionReasonValue,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      patokan: json['patokan'],
      alasanDitolak: json['alasan_ditolak'],
      poinDiberikan: json['poin_diberikan'] ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Helper method untuk mapping string ke enum WasteType
  static WasteType _mapStringToWasteType(String jenis) {
    switch (jenis) {
      case 'Organik':
        return WasteType.organic;
      case 'Anorganik':
        return WasteType.inorganic;
      case 'B3':
        return WasteType.b3;
      case 'Campuran':
        return WasteType.mixed;
      default:
        return WasteType.organic;
    }
  }

  // Helper method untuk mapping string ke enum SeverityLevel
  static SeverityLevel _mapStringToSeverity(String tingkat) {
    switch (tingkat) {
      case 'Ringan':
        return SeverityLevel.mild;
      case 'Sedang':
        return SeverityLevel.moderate;
      case 'Berat':
        return SeverityLevel.severe;
      default:
        return SeverityLevel.mild;
    }
  }

  // Getter untuk menampilkan nama status di UI
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status ?? 'Unknown';
    }
  }

  // Getter untuk mendapatkan warna status
  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'processing':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  // Getter untuk mengecek apakah laporan aktif (pending atau processing)
  bool get isActive => status == 'pending' || status == 'processing';

  // Getter untuk mengecek apakah laporan selesai
  bool get isCompleted => status == 'completed';

  // Getter untuk mengecek apakah laporan ditolak
  bool get isRejected => status == 'rejected';

  // Getter untuk format tanggal yang lebih ramah
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  List<Object?> get props => [
    id,
    imagePath,
    street,
    village,
    district,
    postalCode,
    description,
    wasteType,
    severityLevel,
    createdAt,
    userId,
    status,
    rejectionReason,
    idLaporan,
    latitude,
    longitude,
    patokan,
    alasanDitolak,
    poinDiberikan,
    updatedAt,
  ];
}
