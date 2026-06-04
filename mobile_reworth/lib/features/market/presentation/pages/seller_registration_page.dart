import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../profile/application/profile_controller.dart';
import '../../../profile/domain/bank_account.dart';

class SellerRegistrationPage extends ConsumerStatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  ConsumerState<SellerRegistrationPage> createState() =>
      _SellerRegistrationPageState();
}

class _SellerRegistrationPageState
    extends ConsumerState<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaTokoController = TextEditingController();
  final _alamatTokoController = TextEditingController();
  final _deskripsiTokoController = TextEditingController();
  final _jenisProdukController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  String _kategori = 'Kerajinan Daur Ulang';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _didPrefill = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
      ref.read(profileControllerProvider.notifier).loadBankAccounts();
      ref.read(profileControllerProvider.notifier).loadSellerApplication();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _namaTokoController.dispose();
    _alamatTokoController.dispose();
    _deskripsiTokoController.dispose();
    _jenisProdukController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final user = state.user;
    final bankAccounts = state.bankAccounts;
    final latestApplication = state.sellerApplication;
    final isSubmitting = state.isSubmittingSellerApplication;

    if (!_didPrefill && user != null) {
      _namaController.text = user.nama;
      _nomorHpController.text = user.noTelp;
      _emailController.text = user.email;
      _didPrefill = true;
    }

    final primaryBank = _primaryBank(bankAccounts);
    final blockedByApplication =
        latestApplication?.isPending == true ||
        latestApplication?.isApproved == true;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _SellerBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _SellerHeader(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (latestApplication != null)
                          _StatusBanner(
                            applicationStatus: latestApplication.status,
                          ),
                        if (latestApplication != null)
                          const SizedBox(height: 14),
                        _HeroCard(
                          hasBankAccount: primaryBank != null,
                          primaryBank: primaryBank,
                          bankCount: bankAccounts.length,
                          blockedByApplication: blockedByApplication,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0A1E19,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lengkapi data toko dan akun dashboard seller. Setelah dikirim, admin akan meninjau pengajuan Anda.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _sectionTitle('Data Pemilik'),
                                _input(
                                  controller: _namaController,
                                  hint: 'Nama lengkap',
                                  icon: Icons.person_outline_rounded,
                                  validator: _requiredValidator('Nama lengkap'),
                                ),
                                _input(
                                  controller: _nomorHpController,
                                  hint: 'Nomor ponsel aktif',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: _phoneValidator,
                                ),
                                _input(
                                  controller: _emailController,
                                  hint: 'Alamat email',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _emailValidator,
                                ),
                                const SizedBox(height: 14),
                                _sectionTitle('Data Toko'),
                                _input(
                                  controller: _namaTokoController,
                                  hint: 'Nama toko yang ingin ditampilkan',
                                  icon: Icons.storefront_outlined,
                                  validator: _requiredValidator('Nama toko'),
                                ),
                                _input(
                                  controller: _alamatTokoController,
                                  hint: 'Alamat operasional toko',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 3,
                                  validator: _requiredValidator('Alamat toko'),
                                ),
                                _input(
                                  controller: _deskripsiTokoController,
                                  hint:
                                      'Ceritakan identitas, bahan, dan keunggulan toko Anda',
                                  icon: Icons.description_outlined,
                                  maxLines: 4,
                                  validator: _requiredValidator(
                                    'Deskripsi toko',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('Kategori Produk', style: _labelStyle()),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _kategori,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF10261B),
                                  borderRadius: BorderRadius.circular(16),
                                  decoration: _decoration(
                                    hint: 'Pilih kategori',
                                    icon: Icons.category_outlined,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  items:
                                      const [
                                            'Kerajinan Daur Ulang',
                                            'Eco Enzyme',
                                            'Kompos',
                                            'Peralatan Ramah Lingkungan',
                                            'Lainnya',
                                          ]
                                          .map(
                                            (value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(
                                                value,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _kategori = value);
                                    }
                                  },
                                ),
                                _input(
                                  controller: _jenisProdukController,
                                  hint:
                                      'Contoh: tas daur ulang, pupuk organik, eco enzyme',
                                  icon: Icons.inventory_2_outlined,
                                  validator: _requiredValidator('Jenis produk'),
                                ),
                                const SizedBox(height: 14),
                                _sectionTitle('Akun Dashboard Seller'),
                                _input(
                                  controller: _usernameController,
                                  hint: 'Username untuk login dashboard seller',
                                  icon: Icons.account_circle_outlined,
                                  validator: _requiredValidator(
                                    'Username dashboard',
                                  ),
                                ),
                                _input(
                                  controller: _passwordController,
                                  hint: 'Minimal 8 karakter',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: _passwordToggle(
                                    _obscurePassword,
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Kata sandi dashboard wajib diisi';
                                    }
                                    if (value.length < 8) {
                                      return 'Kata sandi minimal 8 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                _input(
                                  controller: _konfirmasiPasswordController,
                                  hint: 'Ulangi kata sandi dashboard',
                                  icon: Icons.verified_user_outlined,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: _passwordToggle(
                                    _obscureConfirmPassword,
                                    () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi kata sandi wajib diisi';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Konfirmasi kata sandi belum sama';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: _SoftSubmitButton(
                                    label: blockedByApplication
                                        ? 'Lihat Status Pengajuan'
                                        : (primaryBank == null
                                              ? 'Tambahkan Rekening Dulu'
                                              : (isSubmitting
                                                    ? 'Mengirim Pengajuan...'
                                                    : 'Kirim Pengajuan Seller')),
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            if (blockedByApplication) {
                                              context.push(
                                                '/seller-application',
                                              );
                                              return;
                                            }
                                            if (primaryBank == null) {
                                              context.push('/payment-method');
                                              return;
                                            }
                                            _submit();
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  BankAccount? _primaryBank(List<BankAccount> accounts) {
    if (accounts.isEmpty) {
      return null;
    }
    for (final account in accounts) {
      if (account.isPrimary) {
        return account;
      }
    }
    return accounts.first;
  }

  FormFieldValidator<String> _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label wajib diisi';
      }
      return null;
    };
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor ponsel wajib diisi';
    }
    final normalized = value.replaceAll(' ', '').replaceAll('-', '');
    final startsValid =
        normalized.startsWith('08') || normalized.startsWith('+62');
    final digitsOnly = normalized.replaceAll('+', '');
    final digitsValid = RegExp(r'^\d+$').hasMatch(digitsOnly);
    if (!startsValid ||
        !digitsValid ||
        digitsOnly.length < 10 ||
        digitsOnly.length > 15) {
      return 'Nomor ponsel belum valid';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Format email belum valid';
    }
    return null;
  }

  Widget _passwordToggle(bool hidden, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.white.withValues(alpha: 0.70),
        size: 20,
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .submitSellerApplication(
          fullName: _namaController.text.trim(),
          phone: _nomorHpController.text.trim(),
          email: _emailController.text.trim(),
          storeName: _namaTokoController.text.trim(),
          storeDescription: _deskripsiTokoController.text.trim(),
          storeAddress: _alamatTokoController.text.trim(),
          category: _kategori,
          productTypes: _jenisProdukController.text.trim(),
          usernameProposal: _usernameController.text.trim(),
          passwordProposal: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final error = ref
        .read(profileControllerProvider)
        .sellerApplicationErrorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success
            ? const Color(0xFF173A2C)
            : const Color(0xFF6B2A2A),
        content: Text(
          success
              ? 'Pengajuan seller berhasil dikirim. Silakan pantau statusnya dari profil.'
              : (error ?? 'Pengajuan seller belum berhasil dikirim.'),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ),
    );

    if (success) {
      context.push('/seller-application');
    }
  }

  TextStyle _labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFF8DCB94),
        decoration: _decoration(hint: hint, icon: icon, suffixIcon: suffixIcon),
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.44),
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.white, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF7CB78A), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEF7D7D), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEF7D7D), width: 1.4),
      ),
    );
  }
}

class _SellerBackdrop extends StatelessWidget {
  const _SellerBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8FCF8B).withValues(alpha: 0.24),
                      const Color(0xFF4A8F5C).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SellerHeader extends StatelessWidget {
  const _SellerHeader({required this.onBack});

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
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: IconButton(
              onPressed: onBack,
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
              'Pengajuan Seller',
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

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.applicationStatus});

  final String applicationStatus;

  @override
  Widget build(BuildContext context) {
    final normalized = applicationStatus.trim().toLowerCase();
    final isApproved = normalized == 'disetujui' || normalized == 'approved';
    final isRejected = normalized == 'ditolak' || normalized == 'rejected';

    final bg = isApproved
        ? const Color(0x334CBF6B)
        : isRejected
        ? const Color(0x33E06A6A)
        : const Color(0x33E3C36E);
    final fg = isApproved
        ? const Color(0xFFB8F3C4)
        : isRejected
        ? const Color(0xFFFFC2C2)
        : const Color(0xFFFFE5AE);
    final icon = isApproved
        ? Icons.verified_rounded
        : isRejected
        ? Icons.cancel_outlined
        : Icons.hourglass_top_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isApproved
                  ? 'Pengajuan Anda sudah disetujui. Detail lengkap bisa dilihat dari menu profil.'
                  : isRejected
                  ? 'Pengajuan terakhir ditolak. Anda masih bisa memperbarui data dan mengajukan ulang.'
                  : 'Pengajuan seller Anda sedang ditinjau admin.',
              style: GoogleFonts.poppins(
                fontSize: 12.8,
                height: 1.45,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hasBankAccount,
    required this.primaryBank,
    required this.bankCount,
    required this.blockedByApplication,
  });

  final bool hasBankAccount;
  final BankAccount? primaryBank;
  final int bankCount;
  final bool blockedByApplication;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siapkan toko Anda dengan tampilan yang profesional',
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            blockedByApplication
                ? 'Data pengajuan terakhir Anda masih aktif. Anda tetap bisa mengecek status dan memastikan rekening pencairan sudah siap.'
                : 'Isi identitas toko, kategori produk, dan akun dashboard seller. Kami juga akan memakai akun bank utama Anda sebagai rekening pencairan.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekening pencairan seller',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasBankAccount
                      ? '${primaryBank!.bankName} • ${primaryBank!.maskedNumber} ($bankCount rekening tersimpan)'
                      : 'Belum ada rekening. Tambahkan akun bank agar hasil penjualan bisa dicairkan.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftSubmitButton extends StatelessWidget {
  const _SoftSubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
              ),
        color: onPressed == null ? Colors.white.withValues(alpha: 0.10) : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: onPressed == null
                ? Colors.white.withValues(alpha: 0.70)
                : const Color(0xFF082018),
          ),
        ),
      ),
    );
  }
}
