import 'report.dart';

class ReportActionResult {
  final bool success;
  final String? message;
  final Report? report;
  final Exception? error;

  const ReportActionResult({
    required this.success,
    this.message,
    this.report,
    this.error,
  });

  factory ReportActionResult.success({String? message, Report? report}) {
    return ReportActionResult(
      success: true,
      message: message ?? 'Laporan berhasil dikirim',
      report: report,
    );
  }

  factory ReportActionResult.failure({String? message, Exception? error}) {
    return ReportActionResult(
      success: false,
      message: message ?? 'Gagal mengirim laporan',
      error: error,
    );
  }
}