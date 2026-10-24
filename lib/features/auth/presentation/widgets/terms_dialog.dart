import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Bottom sheet dialog displaying Terms of Service and Privacy Policy
class TermsDialog extends StatelessWidget {
  final bool isPrivacyPolicy;

  const TermsDialog({
    super.key,
    this.isPrivacyPolicy = false,
  });

  static void show(BuildContext context, {bool isPrivacyPolicy = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TermsDialog(isPrivacyPolicy: isPrivacyPolicy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.text),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                isPrivacyPolicy
                    ? 'Pet Care Medical respects the privacy of you and your beloved pets. '
                        'We collect your mobile number exclusively for secure OTP-based login '
                        'and appointment confirmations.\n\n'
                        '1. Information Collection: We gather basic profile information (name, optional email) '
                        'and veterinary clinical records required to provide specialized care.\n\n'
                        '2. Data Security: All sensitive pet health data is securely encrypted in transit and at rest '
                        'using Cloud Firestore and Firebase Security Rules.\n\n'
                        '3. No Third-Party Selling: We never sell or lease your personal information to third-party marketers.\n\n'
                        '4. Inquiries: For any privacy concerns, reach out to our veterinary care team.'
                    : 'Welcome to VetCare Medical. By using our veterinary telehealth and clinic booking service, '
                        'you agree to the following terms:\n\n'
                        '1. Emergency Care: This application facilitates veterinary appointments and consultations. '
                        'In life-threatening pet emergencies, immediately take your pet to the nearest 24/7 veterinary hospital.\n\n'
                        '2. Account Security: You are responsible for maintaining the confidentiality of your mobile OTP logins.\n\n'
                        '3. Veterinary Advice: Digital consultations supplement in-person physical examinations and '
                        'do not substitute physical diagnostic assessments.\n\n'
                        '4. Cancellations: Appointments can be rescheduled or cancelled through the app within designated clinic timeframes.',
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
