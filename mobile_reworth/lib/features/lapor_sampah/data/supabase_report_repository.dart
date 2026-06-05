import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/report.dart';
import '../domain/report_action_result.dart';
import '../domain/waste_type.dart';
import '../domain/severity_level.dart';
import 'report_repository.dart';

class SupabaseReportRepository implements ReportRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<ReportActionResult> submitReport(Report report) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return ReportActionResult.failure(message: 'Anda belum login');
      }

      final data = {
        'id_masyarakat': currentUser.id,
        'foto_sampah': report.imagePath,
        'jalan': report.street,
        'kelurahan': report.village,
        'kecamatan': report.district,
        'deskripsi': report.description,
        'jenis_sampah': _mapWasteTypeToString(report.wasteType),
        'tingkat_keparahan': _mapSeverityToString(report.severityLevel),
        'status_laporan': 'pending',
        'poin_diberikan': 0,
        'waktu_lapor': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('laporan_sampah')
          .insert(data)
          .select()
          .single();

      return ReportActionResult.success(
        message: 'Laporan berhasil dikirim',
        report: Report.fromSupabaseJson(response),
      );
    } catch (e) {
      return ReportActionResult.failure(message: 'Gagal mengirim laporan: $e');
    }
  }

  @override
  Future<List<Report>> getUserReports(String userId) async {
    try {
      final response = await _supabase
          .from('laporan_sampah')
          .select()
          .eq('id_masyarakat', userId)
          .order('waktu_lapor', ascending: false);

      return response.map((data) => Report.fromSupabaseJson(data)).toList();
    } catch (e) {
      print('Error getUserReports: $e');
      return [];
    }
  }

  @override
  Future<ReportActionResult> uploadImage(String imagePath) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return ReportActionResult.failure(message: 'Anda belum login');
      }

      final file = File(imagePath);
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'laporan/${currentUser.id}/$fileName';

      await _supabase.storage.from('laporan-sampah').upload(storagePath, file);

      final publicUrl = _supabase.storage
          .from('laporan-sampah')
          .getPublicUrl(storagePath);

      return ReportActionResult.success(
        message: 'Upload gambar berhasil',
        report: null,
      );
    } catch (e) {
      return ReportActionResult.failure(message: 'Gagal upload gambar: $e');
    }
  }

  String _mapWasteTypeToString(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return 'Organik';
      case WasteType.inorganic:
        return 'Anorganik';
      case WasteType.b3:
        return 'B3';
      case WasteType.mixed:
        return 'Campuran';
    }
  }

  String _mapSeverityToString(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.mild:
        return 'Ringan';
      case SeverityLevel.moderate:
        return 'Sedang';
      case SeverityLevel.severe:
        return 'Berat';
    }
  }
}
