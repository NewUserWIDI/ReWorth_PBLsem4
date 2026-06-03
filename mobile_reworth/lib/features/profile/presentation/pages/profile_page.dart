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

    try {
      final row = await client
          .from('profiles')
          .select('foto_profil')
          .eq('id', userId)
          .maybeSingle();

      if (row != null && mounted) {
        final fotoProfil = row['foto_profil'] as String?;
        if (fotoProfil != null && fotoProfil.isNotEmpty) {
          setState(() => _remoteAvatarUrl = fotoProfil);
        }
      }
    } catch (e) {
      print('Error loading avatar: $e');
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
      final path =
          'avatar/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bucket = 'avatars';

      await client.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);

      await client
          .from('profiles')
          .update({'foto_profil': publicUrl})
          .eq('id', userId);

      if (mounted) {
        setState(() {
          _remoteAvatarUrl = publicUrl;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto profil diperbarui')));

        // Refresh profile data from controller
        ref.read(profileControllerProvider.notifier).loadProfile();
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto gagal diunggah, hanya tersimpan lokal'),
          ),
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
        profileUser?.totalLaporanValid ?? authUser?.jumlahLaporanValid ?? 0;
    final avatarUrl = _remoteAvatarUrl ?? fotoProfil;

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF001F1A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
                      backgroundColor: Colors.white,
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
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
                                    color: Colors.white.withValues(alpha: 0.76),
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
                                  child:
                                      avatarUrl.isEmpty && _localAvatar == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
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
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.white, Color(0xFFDCEBD5)],
                                    ),
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
                              color: Colors.white.withValues(alpha: 0.84),
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
                  // Menu Tukar Poin Reward
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
                  // Updated Edit Profile Menu with refresh functionality
                  ProfileMenuTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profil',
                    subtitle: 'Ubah data profil Anda',
                    onTap: () async {
                      // Navigate to edit profile and wait for result
                      final shouldRefresh = await context.push<bool>(
                        '/profile-edit',
                      );
                      if (shouldRefresh == true && mounted) {
                        // Refresh profile data from controller
                        ref
                            .read(profileControllerProvider.notifier)
                            .loadProfile();
                        // Also reload avatar URL from database
                        await _loadRemoteAvatar();
                      }
                    },
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
