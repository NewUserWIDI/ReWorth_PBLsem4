import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/auth/application/auth_controller.dart';
import '../../application/profile_controller.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stat_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _localAvatar;
  String? _remoteAvatarUrl;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadRemoteAvatar();
  }

  Future<void> _loadRemoteAvatar() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final columns = ['foto_profil', 'fotoProfil', 'avatar_url', 'profile_photo'];
    for (final col in columns) {
      try {
        final row = await client
            .from('profiles')
            .select(col)
            .eq('id_masyarakat', userId)
            .maybeSingle();
        if (row is Map<String, dynamic>) {
          final value = row[col]?.toString().trim() ?? '';
          if (value.isNotEmpty && mounted) {
            setState(() => _remoteAvatarUrl = value);
            return;
          }
        }
      } catch (_) {}

      try {
        final row = await client
            .from('profiles')
            .select(col)
            .eq('id', userId)
            .maybeSingle();
        if (row is Map<String, dynamic>) {
          final value = row[col]?.toString().trim() ?? '';
          if (value.isNotEmpty && mounted) {
            setState(() => _remoteAvatarUrl = value);
            return;
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _pickAvatar() async {
    if (_isUploadingAvatar) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _localAvatar = picked;
      _isUploadingAvatar = true;
    });

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
      return;
    }

    try {
      final bytes = await picked.readAsBytes();
      final path = 'avatar/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final buckets = ['profile-photo', 'avatars', 'avatar', 'laporan-sampah'];
      String? publicUrl;

      for (final bucket in buckets) {
        try {
          await client.storage.from(bucket).uploadBinary(
                path,
                bytes,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: true,
                ),
              );
          publicUrl = client.storage.from(bucket).getPublicUrl(path);
          break;
        } catch (_) {}
      }

      if (publicUrl == null) {
        throw Exception('Bucket avatar tidak tersedia.');
      }

      final avatarColumns = ['foto_profil', 'fotoProfil', 'avatar_url', 'profile_photo'];
      var updated = false;

      for (final column in avatarColumns) {
        try {
          await client
              .from('profiles')
              .update({column: publicUrl})
              .eq('id_masyarakat', userId);
          updated = true;
          break;
        } catch (_) {}
        try {
          await client.from('profiles').update({column: publicUrl}).eq('id', userId);
          updated = true;
          break;
        } catch (_) {}
      }

      if (!updated) {
        throw Exception('Kolom foto profil belum sesuai schema profiles.');
      }

      if (mounted) {
        setState(() {
          _remoteAvatarUrl = publicUrl;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil diperbarui')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto gagal diunggah, hanya tersimpan lokal')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profileUser = state.user;
    final authUser = authState.currentUser;

    final hasAnyUser = profileUser != null || authUser != null;
    final nama = profileUser?.nama ?? authUser?.nama ?? 'Pengguna ReWorth';
    final email = profileUser?.email ?? authUser?.email ?? '-';
    final fotoProfil = profileUser?.fotoProfil ?? '';
    final totalPoin = profileUser?.totalPoin ?? authUser?.poin ?? 0;
    final totalLaporan =
        profileUser?.laporanValid ?? authUser?.jumlahLaporanValid ?? 0;
    final avatarUrl = _remoteAvatarUrl ?? fotoProfil;

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF001F1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF94FF38)),
        ),
      );
    }

    if (!hasAnyUser) {
      return Scaffold(
        backgroundColor: const Color(0xFF001F1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data profil belum tersedia',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(profileControllerProvider.notifier)
                          .loadProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94FF38),
                      foregroundColor: const Color(0xFF0A1A12),
                    ),
                    child: const Text('Coba lagi'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Login ulang'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

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
                      const Color(0xFFB5FF77).withValues(alpha: 0.30),
                      const Color(0xFF5BE22F).withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              child: Column(
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E19).withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF94FF38).withValues(alpha: 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFF94FF38,
                                    ).withValues(alpha: 0.8),
                                    width: 2.4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  backgroundImage: _localAvatar != null
                                      ? FileImage(File(_localAvatar!.path))
                                      : (avatarUrl.isEmpty
                                            ? null
                                            : NetworkImage(avatarUrl)),
                                  child: avatarUrl.isEmpty && _localAvatar == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF94FF38),
                                          size: 52,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF94FF38),
                                    border: Border.all(
                                      color: const Color(0xFF0A1A12),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: _isUploadingAvatar
                                      ? const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF0A1A12),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 16,
                                          color: Color(0xFF0A1A12),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 14,
                          ),
                        ),
                        if (profileUser == null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Data lengkap profil sedang disinkronkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(
                                0xFF94FF38,
                              ).withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            ProfileStatCard(
                              value: totalPoin.toString(),
                              label: 'Total Poin',
                            ),
                            const SizedBox(width: 10),
                            ProfileStatCard(
                              value: totalLaporan.toString(),
                              label: 'Laporan',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ProfileMenuTile(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Tukar Poin Reward',
                    subtitle: '$totalPoin poin tersedia',
                    onTap: () => context.push('/rewards'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Lapor Sampah',
                    subtitle: 'Lihat riwayat laporan Anda',
                    onTap: () => context.push('/report-history'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Akun Bank',
                    subtitle: 'Tambahkan akun bank Anda',
                    onTap: () => context.push('/payment-method'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Saya',
                    subtitle: 'Kelola alamat pengiriman',
                    onTap: () => context.push('/address'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profil',
                    subtitle: 'Ubah data profil Anda',
                    onTap: () => context.push('/profile-edit'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun',
                    onTap: () async {
                      await ref.read(authControllerProvider).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onPressed: () => context.go('/home'),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Profil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
