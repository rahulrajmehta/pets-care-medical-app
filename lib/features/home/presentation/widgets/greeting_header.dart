import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Luxury Veterinary Header: Pet Care Medical branding, personalized greeting, notification, and top-right Profile icon
class GreetingHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.onProfileTap,
    this.onNotificationTap,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.trim().isNotEmpty
        ? userName.trim().split(' ').first
        : 'Pet Parent';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Luxury Brand Emblem
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.mutedGold,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Brand Name and Personalized Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pet Care Medical',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTeal,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_getTimeGreeting()}, $displayName 👋',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // Notification Action with Subtle Indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.charcoal,
                  size: 20,
                ),
                tooltip: 'Notifications',
                padding: EdgeInsets.zero,
                onPressed: onNotificationTap,
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.mutedGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Profile Icon in Top-Right Corner
        Tooltip(
          message: 'My Profile',
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.softMint,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTeal, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryTeal,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
