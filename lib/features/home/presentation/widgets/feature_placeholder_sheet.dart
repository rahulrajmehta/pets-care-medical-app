import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Modal bottom sheet displaying a clearly labelled placeholder for features scheduled for Step 2+
class FeaturePlaceholderSheet extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String stepLabel;

  const FeaturePlaceholderSheet({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction_rounded,
    this.stepLabel = 'Step 2 Feature',
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.construction_rounded,
    String stepLabel = 'Step 2 Feature',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FeaturePlaceholderSheet(
        title: title,
        description: description,
        icon: icon,
        stepLabel: stepLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightSage,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 2),
            ),
            child: Icon(
              icon,
              size: 34,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stepLabel,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8A5700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Understood'),
            ),
          ),
        ],
      ),
    );
  }
}
