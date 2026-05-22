enum SeverityLevel {
  mild('Ringan', 'Tumpukan sampah kecil'),
  moderate('Sedang', 'Tumpukan sampah sedang'),
  severe('Parah', 'Tumpukan sampah besar');

  final String label;
  final String description;
  const SeverityLevel(this.label, this.description);
}