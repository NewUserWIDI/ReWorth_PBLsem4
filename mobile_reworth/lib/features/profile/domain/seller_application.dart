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

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isPending => normalizedStatus == 'pending';
  bool get isApproved =>
      normalizedStatus == 'disetujui' ||
      normalizedStatus == 'approved' ||
      normalizedStatus == 'aktif';
  bool get isRejected =>
      normalizedStatus == 'ditolak' || normalizedStatus == 'rejected';
}
