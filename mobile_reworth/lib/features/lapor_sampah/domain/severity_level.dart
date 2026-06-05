enum SeverityLevel {
  mild('Ringan', 'Sampah sedikit, mudah ditangani'),
  moderate('Sedang', 'Sampah menumpuk, perlu penanganan'),
  severe('Berat', 'Sampah sangat banyak, kondisi darurat');

  final String label;
  final String description;
  const SeverityLevel(this.label, this.description);
}
