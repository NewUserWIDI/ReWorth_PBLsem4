class BankAccount {
  final String id;
  final String bankName;
  final String? cardType;
  final String ownerName;
  final String last4Digit;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? expiryDate;
  final String? paymentToken;

  BankAccount({
    required this.id,
    required this.bankName,
    this.cardType,
    required this.ownerName,
    required this.last4Digit,
    required this.isPrimary,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.expiryDate,
    this.paymentToken,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id_kartu'].toString(),
      bankName: json['nama_bank'] as String? ?? 'Bank Lainnya',
      cardType: json['jenis_kartu'] as String?,
      ownerName: json['nama_pemilik'] as String? ?? '',
      last4Digit: json['last4_digit'] as String? ?? '',
      isPrimary: json['kartu_utama'] as bool? ?? false,
      isActive: json['status_aktif'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      expiryDate: json['expiry_date'] as String?,
      paymentToken: json['payment_token'] as String?,
    );
  }

  String get maskedNumber {
    if (last4Digit.isEmpty) return '•••• ••••';
    return '•••• •••• $last4Digit';
  }
}
