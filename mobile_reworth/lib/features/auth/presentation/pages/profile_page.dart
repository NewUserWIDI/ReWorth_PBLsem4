import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/top_curved_header_layout.dart';
import '../../application/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.currentUser;

    return TopCurvedHeaderLayout(
      title: 'Profile',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.nama ?? '-'),
                const SizedBox(height: AppSpacing.s8),
                Text(user?.email ?? '-'),
                Text(user?.nomorHp ?? '-'),
                const SizedBox(height: AppSpacing.s8),
                Text('Laporan valid: ${user?.jumlahLaporanValid ?? 0}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Logout',
            loading: auth.isLoading,
            onPressed: () async {
              final result = await ref.read(authControllerProvider).logout();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
