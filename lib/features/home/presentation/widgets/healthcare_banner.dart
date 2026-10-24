import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Premium Hero Banner: Luxury Veterinary Healthcare Experience
/// Headline: "Every Paw Deserves Exceptional Care."
/// Subtitle: "Compassionate care for the pets you love."
/// Primary CTA: "Book Appointment"
class HealthcareBanner extends StatelessWidget {
  final VoidCallback onBookAppointmentTap;

  const HealthcareBanner({
    super.key,
    required this.onBookAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF094C47),
            Color(0xFF0B615B),
            Color(0xFF0E706A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Right-aligned bright dog-and-cat photography
            Positioned(
              right: -5,
              bottom: 0,
              top: 10,
              width: 185,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                    ],
                    stops: [0.0, 0.28],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/hero_pets.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/pet_welcome_hero.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                ),
              ),
            ),

            // Subtle soft mint ambient lighting in background
            Positioned(
              top: -40,
              right: 40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softMint.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trust badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.softMint.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.mutedGold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '24/7 Veterinary Emergency Care',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.softMint,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Headline: "Every Paw Deserves Exceptional Care."
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      'Every Paw Deserves Exceptional Care.',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle: "Compassionate care for the pets you love."
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                      'Compassionate care for the pets you love.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.softMint.withValues(alpha: 0.90),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Primary CTA: "Book Appointment"
                  ElevatedButton.icon(
                    onPressed: onBookAppointmentTap,
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      size: 17,
                      color: AppColors.primaryTeal,
                    ),
                    label: Text(
                      'Book Appointment',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.primaryTeal,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softMint,
                      foregroundColor: AppColors.primaryTeal,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
