int reportApprovedPointsForSeverity(String? severity) {
  final normalized = severity?.trim().toLowerCase() ?? '';

  switch (normalized) {
    case 'ringan':
    case 'mild':
      return 10;
    case 'sedang':
    case 'moderate':
    case 'berat':
    case 'severe':
      return 30;
    default:
      return 10;
  }
}

int reportRewardPointsFromRow({
  required String? status,
  String? severity,
  int? storedPoints,
}) {
  final points = storedPoints ?? 0;
  if (points > 0) {
    return points;
  }

  final normalizedStatus = status?.trim().toLowerCase() ?? '';
  if (normalizedStatus.contains('ditolak') ||
      normalizedStatus.contains('rejected')) {
    return 3;
  }

  if (normalizedStatus.contains('selesai') ||
      normalizedStatus.contains('valid') ||
      normalizedStatus.contains('diterima') ||
      normalizedStatus.contains('approved') ||
      normalizedStatus.contains('completed')) {
    return reportApprovedPointsForSeverity(severity);
  }

  return 0;
}

String reportApprovedPointsSummary() {
  return 'Poin sesuai tingkat laporan';
}
