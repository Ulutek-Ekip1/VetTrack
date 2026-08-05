import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VerificationIcon extends StatelessWidget {
  const VerificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.mark_email_unread_outlined,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
