// lib/features/profile/presentation/pages/bank_account_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/profile_controller.dart';
import '../../domain/bank_account.dart';

class BankAccountDetailPage extends ConsumerStatefulWidget {
  const BankAccountDetailPage({super.key, required this.account});

  final BankAccount account;

  @override
  ConsumerState<BankAccountDetailPage> createState() =>
      _BankAccountDetailPageState();
}

class _BankAccountDetailPageState extends ConsumerState<BankAccountDetailPage> {
  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003B2F),
                  Color(0xFF002D24),
                  Color(0xFF001F1A),
                ],
              ),
            ),
          ),
          // Efek glow
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8FCF8B).withValues(alpha: 0.24),
                      const Color(0xFF4D8E63).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _DetailHeader(
                  title: 'Detail Akun Bank',
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildBankCard(account),
                        const SizedBox(height: 24),
                        _buildDetailSection(account),
                        const SizedBox(height: 24),
                        _buildActionButtons(account),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BankAccount account) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A3A2F), const Color(0xFF0E2A20)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: account.isPrimary
              ? const Color(0xFF8DCB94).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: account.isPrimary
                ? const Color(0xFF8DCB94).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: account.isPrimary
                        ? [const Color(0xFF8DCB94), const Color(0xFF6BAF7A)]
                        : [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                ),
                child: Icon(
                  _getBankIcon(account.bankName),
                  color: account.isPrimary
                      ? const Color(0xFF0A1A12)
                      : Colors.white,
                  size: 32,
                ),
              ),
              if (account.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8DCB94), Color(0xFF6BAF7A)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFF0A1A12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'UTAMA',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A1A12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            account.bankName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            account.maskedNumber,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            account.ownerName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BankAccount account) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E2A20).withValues(alpha: 0.9),
            const Color(0xFF0A1E19).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8DCB94).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Informasi Lengkap',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Nama Bank', account.bankName),
          _buildDivider(),
          _buildDetailRow('Jenis Kartu', account.cardType ?? '-'),
          _buildDivider(),
          _buildDetailRow('Nama Pemilik', account.ownerName),
          _buildDivider(),
          _buildDetailRow('Nomor Rekening', account.maskedNumber),
          if (account.expiryDate != null) ...[
            _buildDivider(),
            _buildDetailRow('Tanggal Kadaluarsa', account.expiryDate!),
          ],
          _buildDivider(),
          _buildDetailRow(
            'Status',
            account.isPrimary ? 'Kartu Utama' : 'Kartu Biasa',
            isStatus: true,
            statusValue: account.isPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool statusValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: statusValue
                          ? const LinearGradient(
                              colors: [Color(0xFF8DCB94), Color(0xFF6BAF7A)],
                            )
                          : null,
                      color: statusValue
                          ? null
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusValue
                            ? const Color(0xFF0A1A12)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.06), height: 1);
  }

  Widget _buildActionButtons(BankAccount account) {
    return Row(
      children: [
        // Tombol Edit
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEditDialog(account),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text(
              'Edit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: const Color(0xFF8DCB94).withValues(alpha: 0.4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Tombol Jadikan Utama (jika bukan utama)
        if (!account.isPrimary)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8DCB94), Color(0xFF6BAF7A)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8DCB94).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(profileControllerProvider.notifier)
                      .setPrimaryBankAccount(account.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF173A2C),
                        content: Text(
                          '${account.bankName} berhasil dijadikan kartu utama',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Color(0xFF0A1A12),
                ),
                label: Text(
                  'Jadikan Utama',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A1A12),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        // Jika sudah utama, tampilkan tombol disabled atau kosong
        if (account.isPrimary)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: const Color(0xFF8DCB94).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kartu Utama Aktif',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showEditDialog(BankAccount account) async {
    final result = await showModalBottomSheet<_EditBankFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2A25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditBankFormSheet(
        initialBankName: account.bankName,
        initialCardType: account.cardType,
        initialOwnerName: account.ownerName,
        initialExpiryDate: account.expiryDate,
      ),
    );

    if (result == null) return;

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateBankAccount(
          cardId: account.id,
          bankName: result.bankName,
          cardType: result.cardType,
          ownerName: result.ownerName,
          accountNumber: account.last4Digit,
          expiryDate: result.expiryDate,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF173A2C),
          content: Text(
            'Akun bank berhasil diperbarui.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    }
  }

  IconData _getBankIcon(String bankName) {
    final name = bankName.toLowerCase();
    if (name.contains('bca')) return Icons.account_balance_rounded;
    if (name.contains('mandiri')) return Icons.account_balance_rounded;
    if (name.contains('bri')) return Icons.account_balance_rounded;
    if (name.contains('bni')) return Icons.account_balance_rounded;
    if (name.contains('cimb')) return Icons.account_balance_rounded;
    if (name.contains('danamon')) return Icons.account_balance_rounded;
    if (name.contains('permata')) return Icons.account_balance_rounded;
    return Icons.account_balance_wallet_rounded;
  }
}

// ========== HEADER COMPONENT ==========
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== EDIT FORM SHEET ==========
class _EditBankFormResult {
  const _EditBankFormResult({
    required this.bankName,
    required this.cardType,
    required this.ownerName,
    required this.expiryDate,
  });

  final String bankName;
  final String cardType;
  final String ownerName;
  final String? expiryDate;
}

class _EditBankFormSheet extends StatefulWidget {
  const _EditBankFormSheet({
    required this.initialBankName,
    required this.initialCardType,
    required this.initialOwnerName,
    this.initialExpiryDate,
  });

  final String initialBankName;
  final String? initialCardType;
  final String initialOwnerName;
  final String? initialExpiryDate;

  @override
  State<_EditBankFormSheet> createState() => _EditBankFormSheetState();
}

class _EditBankFormSheetState extends State<_EditBankFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bank = TextEditingController();
  String? _selectedCardType;
  final _owner = TextEditingController();
  final _expiryMonth = TextEditingController();
  final _expiryYear = TextEditingController();

  final List<String> _cardTypes = ['Debit', 'Kredit'];

  @override
  void initState() {
    super.initState();
    _bank.text = widget.initialBankName;
    _selectedCardType = widget.initialCardType;
    _owner.text = widget.initialOwnerName;

    if (widget.initialExpiryDate != null &&
        widget.initialExpiryDate!.contains('/')) {
      final parts = widget.initialExpiryDate!.split('/');
      if (parts.length == 2) {
        _expiryMonth.text = parts[0];
        _expiryYear.text = parts[1];
      }
    }
  }

  @override
  void dispose() {
    _bank.dispose();
    _owner.dispose();
    _expiryMonth.dispose();
    _expiryYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1E19),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edit Akun Bank',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(_bank, 'Nama Bank', requiredField: true),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Jenis Kartu',
                  value: _selectedCardType,
                  items: _cardTypes,
                  onChanged: (value) =>
                      setState(() => _selectedCardType = value),
                  requiredField: true,
                ),
                const SizedBox(height: 16),
                _buildField(
                  _owner,
                  'Nama Pemilik Rekening',
                  requiredField: true,
                ),
                const SizedBox(height: 16),
                _buildExpiryDateField(),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A1A12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Kadaluarsa (Opsional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonth,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration: InputDecoration(
                  labelText: 'MM',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A2A25),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF8DCB94).withValues(alpha: 0.24),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF8DCB94).withValues(alpha: 0.16),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7CB78A),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final month = int.tryParse(value);
                  if (month != null && (month < 1 || month > 12))
                    return 'Bulan 1-12';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _expiryYear,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration: InputDecoration(
                  labelText: 'YY',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A2A25),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF8DCB94).withValues(alpha: 0.24),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF8DCB94).withValues(alpha: 0.16),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7CB78A),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final year = int.tryParse(value);
                  if (year != null && year < 24) return 'Tahun tidak valid';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A2A25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8DCB94).withValues(alpha: 0.24),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8DCB94).withValues(alpha: 0.16),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF7CB78A),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F)),
            ),
          ),
          validator: (value) {
            if (requiredField && (value == null || value.trim().isEmpty))
              return 'Wajib diisi';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool requiredField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8DCB94).withValues(alpha: 0.16),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A2A25),
              hint: Text(
                'Pilih Jenis Kartu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    String? expiryDate;
    if (_expiryMonth.text.isNotEmpty && _expiryYear.text.isNotEmpty) {
      expiryDate = '${_expiryMonth.text}/${_expiryYear.text}';
    }

    Navigator.pop(
      context,
      _EditBankFormResult(
        bankName: _bank.text.trim(),
        cardType: _selectedCardType ?? 'Debit',
        ownerName: _owner.text.trim(),
        expiryDate: expiryDate,
      ),
    );
  }
}
