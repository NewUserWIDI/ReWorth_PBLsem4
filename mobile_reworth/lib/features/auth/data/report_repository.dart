import '../domain/report.dart';
import '../domain/report_action_result.dart';

abstract class ReportRepository {
  Future<ReportActionResult> submitReport(Report report);
  Future<List<Report>> getUserReports(String userId);
  Future<ReportActionResult> uploadImage(String imagePath);
}
