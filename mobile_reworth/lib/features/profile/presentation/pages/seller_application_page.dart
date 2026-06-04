import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/profile_controller.dart';
import '../../domain/bank_account.dart';
import '../../domain/seller_application.dart';

class SellerApplicationPage extends ConsumerStatefulWidget {
  const SellerApplicationPage({super.key});

  @override
  ConsumerState<SellerApplicationPage> createState() =>
      _SellerApplicationPageState();
}

class _SellerApplicationPageState extends ConsumerState<SellerApplicationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadSellerApplication();
      ref.read(profileControllerProvider.notifier).loadBankAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final application = state.sellerApplication;
    final bankAccounts = state.bankAccounts;
    final isLoading =
        state.isLoadingSellerApplication || state.isLoadingBankAccounts;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _ApplicationBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _ApplicationHeader(onBack: () => context.pop()),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF5D9F68),
                          backgroundColor: const Color(0xFF0A1E19),
                          onRefresh: () async {
                            await ref
                                .read(profileControllerProvider.notifier)
                                .loadSellerApplication();
                            await ref
                                .read(profileControllerProvider.notifier)
                                .loadBankAccounts();
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              if (state.sellerApplicationErrorMessage != null)
                                _InfoPanel(
                                  title: 'Koneksi pengajuan seller',
                                  description:
                                      state.sellerApplicationErrorMessage!,
                                  icon: Icons.info_outline_rounded,
                                  tone: _PanelTone.warning,
                                ),
                              if (application == null)
                                _EmptyApplicationCard(
                                  hasBankAccount: bankAccounts.isNotEmpty,
                                )
                              else ...[
                                _ApplicationStatusHero(
                                  application: application,
                                ),
                                const SizedBox(height: 14),
                                _ApplicationDetailCard(
                                  application: application,
                                ),
                                const SizedBox(height: 14),
                                _BankPayoutCard(
                                  primaryBank: _primaryBank(bankAccounts),
                                  bankCount: bankAccounts.length,
                                ),
                              ],
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
}

class _ApplicationBackdrop extends StatelessWidget {
  const _ApplicationBackdrop();

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
            ),
          ),
        ),
        Positioned(
          top: -150,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8FCF8B).withValues(alpha: 0.22),
                      const Color(0xFF4A8F5C).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.45, 1],
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

class _ApplicationHeader extends StatelessWidget {
  const _ApplicationHeader({required this.onBack});

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

class _EmptyApplicationCard extends StatelessWidget {
  const _EmptyApplicationCard({required this.hasBankAccount});

  final bool hasBankAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pengajuan seller',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasBankAccount
                ? 'Ajukan toko Anda untuk mulai menjual produk daur ulang di mini market ReWorth.'
                : 'Sebelum mengajukan seller, tambahkan dulu akun bank agar pencairan hasil penjualan bisa diproses.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 18),
          if (!hasBankAccount)
            SizedBox(
              width: double.infinity,
              child: _SoftGreenButton(
                label: 'Tambahkan Rekening Pencairan',
                onPressed: () => context.push('/payment-method'),
                icon: Icons.account_balance_rounded,
              ),
            ),
          if (!hasBankAccount) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _SoftGreenButton(
              label: 'Buka Form Pengajuan Seller',
              onPressed: () => context.push('/seller-registration'),
              icon: Icons.note_alt_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationStatusHero extends StatelessWidget {
  const _ApplicationStatusHero({required this.application});

  final SellerApplication application;

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(application);
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: meta.background,
            ),
            child: Icon(meta.icon, color: meta.foreground, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.storeName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: meta.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meta.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: meta.foreground,
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
}

class _ApplicationDetailCard extends StatelessWidget {
  const _ApplicationDetailCard({required this.application});

  final SellerApplication application;

  @override
  Widget build(BuildContext context) {
    final processedAt = application.processedAt;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengajuan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Nama toko', value: application.storeName),
          _DetailRow(label: 'Kategori', value: application.category),
          _DetailRow(label: 'Jenis produk', value: application.productTypes),
          _DetailRow(
            label: 'Username dashboard',
            value: application.usernameProposal,
          ),
          _DetailRow(label: 'Alamat toko', value: application.storeAddress),
          _DetailRow(
            label: 'Deskripsi toko',
            value: application.storeDescription,
          ),
          _DetailRow(
            label: 'Diajukan pada',
            value: _formatDate(application.submittedAt),
          ),
          if (processedAt != null)
            _DetailRow(label: 'Diproses pada', value: _formatDate(processedAt)),
          if (application.rejectionReason != null &&
              application.rejectionReason!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF5A2323).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFCA7373).withValues(alpha: 0.30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFC1C1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    application.rejectionReason!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.82),
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

class _BankPayoutCard extends StatelessWidget {
  const _BankPayoutCard({required this.primaryBank, required this.bankCount});

  final BankAccount? primaryBank;
  final int bankCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekening Pencairan Seller',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (primaryBank == null)
            Text(
              'Belum ada rekening yang bisa dipakai untuk pencairan. Tambahkan akun bank dari menu profil.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            )
          else ...[
            _DetailRow(label: 'Bank', value: primaryBank!.bankName),
            _DetailRow(label: 'Atas nama', value: primaryBank!.ownerName),
            _DetailRow(
              label: 'Nomor rekening',
              value: primaryBank!.maskedNumber,
            ),
            _DetailRow(
              label: 'Total rekening tersimpan',
              value: '$bankCount rekening',
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _SoftGreenButton(
              label: primaryBank == null
                  ? 'Tambah Rekening'
                  : 'Kelola Rekening Seller',
              onPressed: () => context.push('/payment-method'),
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGreenButton extends StatelessWidget {
  const _SoftGreenButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D8E63).withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF082018), size: 19),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF082018),
          ),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PanelTone { warning }

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String description;
  final IconData icon;
  final _PanelTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D3A17).withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2C062).withValues(alpha: 0.26),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFE29B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.78),
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

class _SellerApplicationStatusMeta {
  const _SellerApplicationStatusMeta({
    required this.label,
    required this.description,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color background;
  final Color foreground;
}

_SellerApplicationStatusMeta _statusMeta(SellerApplication application) {
  if (application.isApproved) {
    return const _SellerApplicationStatusMeta(
      label: 'Disetujui',
      description:
          'Pengajuan seller sudah disetujui. Anda bisa masuk ke dashboard seller menggunakan kredensial yang diajukan.',
      icon: Icons.verified_rounded,
      background: Color(0x334CBF6B),
      foreground: Color(0xFFB8F3C4),
    );
  }

  if (application.isRejected) {
    return const _SellerApplicationStatusMeta(
      label: 'Ditolak',
      description:
          'Pengajuan seller Anda ditolak. Silakan cek catatan admin dan ajukan ulang setelah diperbaiki.',
      icon: Icons.cancel_outlined,
      background: Color(0x33E06A6A),
      foreground: Color(0xFFFFC2C2),
    );
  }

  return const _SellerApplicationStatusMeta(
    label: 'Menunggu Verifikasi',
    description:
        'Pengajuan seller sedang diperiksa admin. Kami akan memperbarui status setelah proses verifikasi selesai.',
    icon: Icons.hourglass_top_rounded,
    background: Color(0x33F0C562),
    foreground: Color(0xFFFFE4A4),
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}
