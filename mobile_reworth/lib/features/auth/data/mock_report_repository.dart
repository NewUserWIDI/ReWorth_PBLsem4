import '../domain/report.dart';
import '../domain/report_action_result.dart';
import 'report_repository.dart';

class MockReportRepository implements ReportRepository {
  final List<Report> _reports = [];

  @override
  Future<ReportActionResult> submitReport(Report report) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final newReport = report.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        status: 'pending',
      );
      
      _reports.add(newReport);
      
      return ReportActionResult.success(
        message: 'Laporan sampah berhasil dikirim!',
        report: newReport,
      );
    } catch (e) {
      return ReportActionResult.failure(
        message: 'Gagal mengirim laporan',
        error: e as Exception?,
      );
    }
  }

  @override
  Future<List<Report>> getUserReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _reports.where((r) => r.userId == userId).toList();
  }

  @override
  Future<ReportActionResult> uploadImage(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock successful upload
    return ReportActionResult.success(
      message: 'Foto berhasil diupload',
    );
  }
}