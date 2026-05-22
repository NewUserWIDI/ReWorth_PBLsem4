import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/auth_header_sheet_layout.dart';

import '../../application/profile_controller.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stat_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    final user = state.user;

    if (state.isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AuthHeaderSheetLayout(
      title: 'Profile',

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(user.fotoProfil),
            ),

            const SizedBox(height: 14),

            Text(
              user.nama,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(user.email, style: TextStyle(color: Colors.grey.shade600)),

            const SizedBox(height: 24),

            Row(
              children: [
                ProfileStatCard(
                  value: user.totalPoin.toString(),
                  label: 'Total Poin',
                ),

                const SizedBox(width: 10),

                ProfileStatCard(
                  value: user.laporanValid.toString(),
                  label: 'Laporan',
                ),

                const SizedBox(width: 10),

                ProfileStatCard(
                  value: '${user.setorSampahKg}Kg',
                  label: 'Sampah',
                ),
              ],
            ),

            const SizedBox(height: 28),

            ProfileMenuTile(
              icon: Icons.card_giftcard_rounded,
              title: 'Tukar Poin Reward',
              subtitle: '${user.totalPoin} poin tersedia',
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'Riwayat Lapor Sampah',
              subtitle: 'Lihat riwayat laporan Anda',
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Akun Bank',
              subtitle: 'Tambahkan akun bank Anda',
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.edit_rounded,
              title: 'Edit Profil',
              subtitle: 'Ubah data profil Anda',
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Keluar',
              subtitle: 'Keluar dari akun',
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
