import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Premium veterinary medical brand logo widget
class PetBrandLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final bool showSubtitle;

  const PetBrandLogo({
    super.key,
    this.size = 76,
    this.showTitle = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Medical Cross
              Icon(
                Icons.add_rounded,
                size: size * 0.58,
                color: AppColors.white.withValues(alpha: 0.95),
              ),
              // Pet Paw in accent gold placed tastefully in center
              Positioned(
                bottom: size * 0.22,
                child: Icon(
                  Icons.pets_rounded,
                  size: size * 0.32,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VetCare',
                style: AppTextStyles.headingLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MED',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (showSubtitle) ...[
          const SizedBox(height: 6),
          Text(
            'Specialized Veterinary & Pet Care',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
