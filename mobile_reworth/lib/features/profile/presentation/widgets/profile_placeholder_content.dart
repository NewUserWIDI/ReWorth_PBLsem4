import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/profile_summary.dart';

class ProfilePlaceholderContent extends StatelessWidget {
  const ProfilePlaceholderContent({super.key, required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Halaman Profile sedang disiapkan',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Nama: ${summary.nama}\nEmail: ${summary.email}\nNo HP: ${summary.nomorHp}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
