import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Compact section for Upcoming Appointments, Vaccination Reminders, and Medical Records
/// Displays clean, premium empty states when no active data exists (strictly no fake clinical records)
class HealthAndAppointmentsSection extends StatelessWidget {
  final VoidCallback? onBookAppointmentTap;
  final VoidCallback? onAppointmentDetailsTap;
  final VoidCallback? onVaccinationTap;
  final VoidCallback? onVaccinationReminderTap;
  final VoidCallback? onMedicalRecordsTap;
  final List<dynamic> appointments;
  final List<dynamic> vaccinationReminders;
  final List<dynamic> medicalRecords;

  const HealthAndAppointmentsSection({
    super.key,
    this.onBookAppointmentTap,
    this.onAppointmentDetailsTap,
    this.onVaccinationTap,
    this.onVaccinationReminderTap,
    this.onMedicalRecordsTap,
    this.appointments = const [],
    this.vaccinationReminders = const [],
    this.medicalRecords = const [],
  });

  VoidCallback? get _appointmentAction => onBookAppointmentTap ?? onAppointmentDetailsTap;
  VoidCallback? get _vaccineAction => onVaccinationTap ?? onVaccinationReminderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. UPCOMING APPOINTMENTS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 20,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Appointments',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _appointmentAction,
              child: Text(
                'Schedule',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildAppointmentsCard(context),
        const SizedBox(height: 20),

        // 2. VACCINATION REMINDERS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.vaccines_rounded,
                  size: 20,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vaccination Reminders',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.softMint,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Up to Date',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildVaccinationCard(context),
        const SizedBox(height: 20),

        // 3. MEDICAL RECORDS (Pet Health Vault)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_shared_rounded,
                  size: 20,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medical Records',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onMedicalRecordsTap,
              child: Text(
                'Health Vault',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildMedicalRecordsCard(context),
      ],
    );
  }

  Widget _buildAppointmentsCard(BuildContext context) {
    if (appointments.isNotEmpty) {
      return Container();
    }

    // Clean luxury empty state (no fake appointments)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Upcoming Appointments',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Schedule an in-clinic consultation or preventive health check for your pet.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _appointmentAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryTeal,
              side: const BorderSide(color: AppColors.primaryTeal, width: 1.2),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Book',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BuildContext context) {
    if (vaccinationReminders.isNotEmpty) {
      return Container();
    }

    // Clean luxury empty state (no fake vaccination dates)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaccination Records Clear',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Booster notifications and rabies alert schedules will appear once pet profiles are linked.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _vaccineAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              'Details',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsCard(BuildContext context) {
    if (medicalRecords.isNotEmpty) {
      return Container();
    }

    // Clean luxury empty state (no fake clinical records)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.file_present_rounded,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pet Health Vault',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Upload blood test reports, histopathology results, and digital X-rays to share securely with your vet.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onMedicalRecordsTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              'View',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
