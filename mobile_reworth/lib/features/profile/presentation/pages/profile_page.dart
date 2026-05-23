import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';

import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/widgets/auth_header_sheet_layout.dart';
=======

import '../../../../shared/widgets/auth_header_sheet_layout.dart';

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
import '../../application/profile_controller.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stat_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
<<<<<<< HEAD
    final user = state.user;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Data profile belum tersedia'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(profileControllerProvider.notifier).loadProfile(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return AuthHeaderSheetLayout(
      title: 'Profile',
=======

    final user = state.user;

    if (state.isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AuthHeaderSheetLayout(
      title: 'Profile',

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(user.fotoProfil),
            ),
<<<<<<< HEAD
            const SizedBox(height: 14),
=======

            const SizedBox(height: 14),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            Text(
              user.nama,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
<<<<<<< HEAD
            const SizedBox(height: 4),
            Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
=======

            const SizedBox(height: 4),

            Text(user.email, style: TextStyle(color: Colors.grey.shade600)),

            const SizedBox(height: 24),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            Row(
              children: [
                ProfileStatCard(
                  value: user.totalPoin.toString(),
                  label: 'Total Poin',
                ),
<<<<<<< HEAD
                const SizedBox(width: 10),
=======

                const SizedBox(width: 10),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
                ProfileStatCard(
                  value: user.laporanValid.toString(),
                  label: 'Laporan',
                ),
<<<<<<< HEAD
                const SizedBox(width: 10),
=======

                const SizedBox(width: 10),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
                ProfileStatCard(
                  value: '${user.setorSampahKg}Kg',
                  label: 'Sampah',
                ),
              ],
            ),
<<<<<<< HEAD
            const SizedBox(height: 28),
=======

            const SizedBox(height: 28),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ProfileMenuTile(
              icon: Icons.card_giftcard_rounded,
              title: 'Tukar Poin Reward',
              subtitle: '${user.totalPoin} poin tersedia',
<<<<<<< HEAD
              onTap: () => context.push('/rewards'),
            ),
=======
              onTap: () {},
            ),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'Riwayat Lapor Sampah',
              subtitle: 'Lihat riwayat laporan Anda',
<<<<<<< HEAD
              onTap: () => context.push('/report-history'),
            ),
=======
              onTap: () {},
            ),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ProfileMenuTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Akun Bank',
              subtitle: 'Tambahkan akun bank Anda',
              onTap: () {},
            ),
<<<<<<< HEAD
=======

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ProfileMenuTile(
              icon: Icons.edit_rounded,
              title: 'Edit Profil',
              subtitle: 'Ubah data profil Anda',
<<<<<<< HEAD
              onTap: () => context.push('/profile-edit'),
            ),
=======
              onTap: () {},
            ),

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Keluar',
              subtitle: 'Keluar dari akun',
<<<<<<< HEAD
              onTap: () async {
                await ref.read(authControllerProvider).logout();
                if (context.mounted) {
                  context.go('/login');
                }
=======
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
              },
            ),
          ],
        ),
      ),
    );
  }
}
