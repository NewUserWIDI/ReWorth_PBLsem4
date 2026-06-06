// lib/features/profile/presentation/pages/payment_method_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/profile_controller.dart';
import '../../domain/bank_account.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadBankAccounts();
    });
  }

  Future<void> _showAddDialog() async {
    final currentState = ref.read(profileControllerProvider);

    if (currentState.bankAccounts.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 3 akun bank per akun.')),
      );
      return;
    }

    final result = await showModalBottomSheet<_BankCardFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2A25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BankCardFormSheet(),
    );

    if (result == null) return;

    final success = await ref
        .read(profileControllerProvider.notifier)
        .addBankAccount(
          bankName: result.bankName,
          cardType: result.cardType,
          ownerName: result.ownerName,
          accountNumber: result.accountNumber,
          expiryDate: result.expiryDate,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success
            ? const Color(0xFF173A2C)
            : const Color(0xFF732727),
        content: Text(
          success
              ? 'Akun bank berhasil ditambahkan.'
              : 'Gagal menambah akun bank.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BankAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Hapus Akun Bank',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus akun bank ${account.bankName}?\n\nAkun yang dihapus tidak dapat dikembalikan.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(profileControllerProvider.notifier)
          .deleteBankAccount(account.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success
              ? const Color(0xFF173A2C)
              : const Color(0xFF732727),
          content: Text(
            success
                ? 'Akun bank berhasil dihapus.'
                : 'Gagal menghapus akun bank.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final accounts = state.bankAccounts;
    final isLoading =
        state.isLoadingBankAccounts ||
        state.isAddingBankAccount ||
        state.isDeletingBankAccount ||
        state.isSettingPrimaryBank;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
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
                _Header(title: 'Akun Bank', onBack: () => context.pop()),
                const SizedBox(height: 8),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7CB78A),
                          ),
                        )
                      : _buildBody(accounts),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: accounts.length >= 3
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4D8E63).withValues(alpha: 0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showAddDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add_rounded, color: Color(0xFF0A1A12)),
                label: Text(
                  'Tambah Bank',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A1A12),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(List<BankAccount> accounts) {
    if (accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8DCB94).withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 40,
                  color: Color(0xFF8DCB94),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada akun bank',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan akun bank untuk\nmemudahkan transaksi Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: _showAddDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(160, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '+ Tambah Bank',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A1A12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(profileControllerProvider.notifier).loadBankAccounts(),
      color: const Color(0xFF8DCB94),
      backgroundColor: const Color(0xFF0A1E19),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: accounts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final account = accounts[index];
          return Dismissible(
            key: Key(account.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            confirmDismiss: (direction) async {
              await _confirmDelete(account);
              return false;
            },
            child: GestureDetector(
              onTap: () {
                context.push('/bank-account-detail', extra: account);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E19).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8DCB94).withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        _getBankIcon(account.bankName),
                        color: account.isPrimary
                            ? const Color(0xFF8DCB94)
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                account.bankName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (account.isPrimary) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8DCB94,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF8DCB94,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Utama',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF8DCB94),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account.maskedNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

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
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 28,
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

// ========== FORM SHEET ==========
class _BankCardFormResult {
  const _BankCardFormResult({
    required this.bankName,
    required this.cardType,
    required this.ownerName,
    required this.accountNumber,
    this.expiryDate,
    this.label,
  });

  final String bankName;
  final String cardType;
  final String ownerName;
  final String accountNumber;
  final String? expiryDate;
  final String? label;
}

class _BankCardFormSheet extends StatefulWidget {
  const _BankCardFormSheet({
    this.initialBankName,
    this.initialCardType,
    this.initialOwnerName,
    this.initialAccountNumber,
    this.initialExpiryDate,
    this.isEditMode = false,
  });

  final String? initialBankName;
  final String? initialCardType;
  final String? initialOwnerName;
  final String? initialAccountNumber;
  final String? initialExpiryDate;
  final bool isEditMode;

  @override
  State<_BankCardFormSheet> createState() => _BankCardFormSheetState();
}

class _BankCardFormSheetState extends State<_BankCardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bank = TextEditingController();
  String? _selectedCardType;
  final _owner = TextEditingController();
  final _number = TextEditingController();
  final _expiryMonth = TextEditingController();
  final _expiryYear = TextEditingController();

  bool _isObscured = true;

  final List<String> _cardTypes = ['Debit', 'Kredit'];

  @override
  void initState() {
    super.initState();
    if (widget.initialBankName != null) _bank.text = widget.initialBankName!;
    if (widget.initialCardType != null)
      _selectedCardType = widget.initialCardType;
    if (widget.initialOwnerName != null) _owner.text = widget.initialOwnerName!;
    if (widget.initialAccountNumber != null) {
      if (widget.isEditMode) {
        _number.text = '•••• •••• ${widget.initialAccountNumber}';
      } else {
        _number.text = widget.initialAccountNumber!;
      }
    }
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
    _number.dispose();
    _expiryMonth.dispose();
    _expiryYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initialBankName != null;

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
                  isEdit ? 'Edit Akun Bank' : 'Tambah Akun Bank',
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
                _buildNumberField(),
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
                      isEdit ? 'Simpan Perubahan' : 'Simpan Akun Bank',
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

  Widget _buildNumberField() {
    final isEditMode = widget.isEditMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Rekening',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _number,
          obscureText: !isEditMode && _isObscured,
          readOnly: isEditMode,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A2A25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: !isEditMode
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : const Icon(
                    Icons.lock_outline,
                    color: Colors.white54,
                    size: 20,
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
            if (value == null || value.trim().isEmpty) return 'Wajib diisi';
            if (!isEditMode) {
              final cleanNumber = value.replaceAll(RegExp(r'\s+'), '');
              if (cleanNumber.length < 6)
                return 'Minimal 6 digit nomor rekening';
            }
            return null;
          },
        ),
        if (isEditMode)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Nomor rekening tidak dapat diubah saat edit',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
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

    String accountNumber = _number.text.trim();

    if (widget.isEditMode) {
      final match = RegExp(r'(\d{4})$').firstMatch(accountNumber);
      if (match != null && widget.initialAccountNumber != null) {
        accountNumber = widget.initialAccountNumber!;
      }
    }

    String? expiryDate;
    if (_expiryMonth.text.isNotEmpty && _expiryYear.text.isNotEmpty) {
      expiryDate = '${_expiryMonth.text}/${_expiryYear.text}';
    }

    Navigator.pop(
      context,
      _BankCardFormResult(
        bankName: _bank.text.trim(),
        cardType: _selectedCardType ?? 'Debit',
        ownerName: _owner.text.trim(),
        accountNumber: accountNumber,
        expiryDate: expiryDate,
        label: null,
      ),
    );
  }
}
