import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// 8 Veterinary Hospital Service Shortcuts:
/// 4 Premium Photo Cards:
/// 1. Doctor Consultation, 2. Vaccination, 3. Grooming, 4. Diagnostics
///
/// 4 Compact Icon Cards:
/// 5. Video Consultation (Planned), 6. Wellness, 7. Book Visit, 8. Emergency (24/7)
class ServiceCategories extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;

  const ServiceCategories({
    super.key,
    required this.onCategoryTap,
  });

  static const List<_ServiceItem> _photoServices = [
    _ServiceItem(
      title: 'Doctor Consultation',
      subtitle: 'General & Specialist Care',
      imagePath: 'assets/images/services/doctor_consultation.png',
      icon: Icons.medical_services_outlined,
    ),
    _ServiceItem(
      title: 'Vaccination',
      subtitle: 'Core & Booster Shots',
      imagePath: 'assets/images/services/vaccination.png',
      icon: Icons.vaccines_outlined,
    ),
    _ServiceItem(
      title: 'Grooming',
      subtitle: 'Bath, Haircut & Spa',
      imagePath: 'assets/images/services/grooming.png',
      icon: Icons.content_cut_rounded,
    ),
    _ServiceItem(
      title: 'Diagnostics',
      subtitle: 'Lab Tests & Digital X-Ray',
      imagePath: 'assets/images/services/diagnostics.png',
      icon: Icons.monitor_heart_outlined,
    ),
  ];

  static const List<_ServiceItem> _compactServices = [
    _ServiceItem(
      title: 'Video\nConsultation',
      icon: Icons.video_call_outlined,
      badgeText: 'Planned',
      isPlanned: true,
    ),
    _ServiceItem(
      title: 'Wellness',
      icon: Icons.spa_outlined,
    ),
    _ServiceItem(
      title: 'Book\nVisit',
      icon: Icons.calendar_month_outlined,
    ),
    _ServiceItem(
      title: 'Emergency',
      icon: Icons.emergency_outlined,
      badgeText: '24/7',
      isEmergency: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  size: 20,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Veterinary Services',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              'Licensed Care',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row 1: Doctor Consultation & Vaccination
        Row(
          children: [
            Expanded(child: _buildPhotoCard(_photoServices[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildPhotoCard(_photoServices[1])),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Grooming & Diagnostics
        Row(
          children: [
            Expanded(child: _buildPhotoCard(_photoServices[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildPhotoCard(_photoServices[3])),
          ],
        ),
        const SizedBox(height: 14),

        // Row 3: 4 Compact Icon Cards
        Row(
          children: _compactServices.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildCompactCard(item),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(_ServiceItem item) {
    return InkWell(
      onTap: () => onCategoryTap(item.title.replaceAll('\n', ' ')),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Container
            SizedBox(
              height: 106,
              width: double.infinity,
              child: item.imagePath != null
                  ? Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.softMint,
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon,
                          size: 36,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.softMint,
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        size: 36,
                        color: AppColors.primaryTeal,
                      ),
                    ),
            ),
            // Title & Subtitle Below Photo
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(_ServiceItem item) {
    return InkWell(
      onTap: () => onCategoryTap(item.title.replaceAll('\n', ' ')),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.isEmergency
                        ? const Color(0xFFFDECEE)
                        : (item.isPlanned
                            ? const Color(0xFFF3F5F4)
                            : AppColors.softMint),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.isEmergency
                        ? AppColors.error
                        : (item.isPlanned
                            ? AppColors.textSecondary
                            : AppColors.primaryTeal),
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                      fontSize: 10.5,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
            if (item.badgeText != null)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: item.isEmergency
                        ? AppColors.error
                        : AppColors.textSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.badgeText!,
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: item.isEmergency
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String? subtitle;
  final String? imagePath;
  final IconData icon;
  final String? badgeText;
  final bool isPlanned;
  final bool isEmergency;

  const _ServiceItem({
    required this.title,
    this.subtitle,
    this.imagePath,
    required this.icon,
    this.badgeText,
    this.isPlanned = false,
    this.isEmergency = false,
  });
}
