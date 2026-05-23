import 'package:flutter/material.dart';

class ProfileMenuTile extends StatelessWidget {
<<<<<<< HEAD
=======
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

<<<<<<< HEAD
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

=======
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
<<<<<<< HEAD
              color: Colors.black.withValues(alpha: 0.05),
=======
              color: Colors.black.withOpacity(0.05),
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: const Color(0xFFEEF7E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
=======
                color: const Color(0xffEEF7E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xff2E7D32)),
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
<<<<<<< HEAD
                  color: Color(0xFF2E7D32),
=======
                  color: Color(0xff2E7D32),
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
                  size: 28,
                ),
          ],
        ),
      ),
    );
  }
}
