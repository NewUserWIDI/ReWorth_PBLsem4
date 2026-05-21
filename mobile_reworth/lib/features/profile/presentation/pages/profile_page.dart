import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/auth_header_sheet_layout.dart';
import '../../application/profile_controller.dart';
import '../widgets/profile_placeholder_content.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(profileSummaryProvider);

    return AuthHeaderSheetLayout(
      title: 'Profile',
      child: summaryAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 10),
              Text(
                'Memuat profile...',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Gagal memuat profile.\n$error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ),
        data: (summary) => ProfilePlaceholderContent(summary: summary),
      ),
    );
  }
}
