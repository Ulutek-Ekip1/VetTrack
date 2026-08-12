import 'package:flutter/material.dart';

class PhotoOption extends StatelessWidget {
  const PhotoOption(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF004AC6),
            ),
            const SizedBox(width: 28),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF131B2E),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
