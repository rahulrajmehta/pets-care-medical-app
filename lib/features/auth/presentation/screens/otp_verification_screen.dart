import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_digit_field.dart';
import '../widgets/pet_brand_logo.dart';
import '../widgets/premium_button.dart';

/// Screen 3: 6-Digit OTP Verification Screen
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final GlobalKey<OtpDigitFieldState> _otpFieldKey =
      GlobalKey<OtpDigitFieldState>();
  String _enteredOtp = '';
  String? _localError;

  Future<void> _handleVerify() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_enteredOtp.length != 6) {
      setState(() {
        _localError = 'Please enter all 6 digits of the OTP code';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(_enteredOtp);

    if (success && mounted) {
      final authState = ref.read(authControllerProvider);
      if (authState.isProfileCompleted) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.profileSetup);
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _localError = null;
    });
    _otpFieldKey.currentState?.clear();
    await ref.read(authControllerProvider.notifier).resendOtp();
  }

  void _handleChangeNumber() {
    ref.read(authControllerProvider.notifier).resetOtpFlow();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final displayPhone = authState.phoneNumber != null
        ? Validators.formatForDisplay(authState.phoneNumber!)
        : 'your mobile number';

    final hasError = _localError != null || authState.errorMessage != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _handleChangeNumber,
        ),
        title: Text(
          'Verification',
          style: AppTextStyles.headingMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Small branding icon
              const Center(
                child: PetBrandLogo(
                  size: 56,
                  showTitle: false,
                  showSubtitle: false,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Verify Phone Number',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Description and phone display
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'We sent a 6-digit code to ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      displayPhone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Change Phone Number Action
              Center(
                child: TextButton.icon(
                  onPressed: _handleChangeNumber,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  label: Text(
                    'Wrong number? Edit phone number',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 6-Digit OTP Field with paste support and auto-advance
              OtpDigitField(
                key: _otpFieldKey,
                length: 6,
                hasError: hasError,
                enabled: !authState.isVerifyingOtp,
                onChanged: (val) {
                  setState(() {
                    _enteredOtp = val;
                    if (_localError != null) _localError = null;
                  });
                  if (authState.errorMessage != null) {
                    ref.read(authControllerProvider.notifier).clearError();
                  }
                },
                onCompleted: (val) {
                  setState(() {
                    _enteredOtp = val;
                  });
                  _handleVerify();
                },
              ),
              const SizedBox(height: 14),

              // Local / inline validation error
              if (_localError != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _localError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // Clear Invalid/Expired OTP or SMS Provider Error Box
              if (authState.errorMessage != null && _localError == null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 20),

              // Verify OTP Button
              PremiumButton(
                label: 'Verify & Continue',
                isLoading: authState.isVerifyingOtp,
                onPressed: _enteredOtp.length == 6 && !authState.isVerifyingOtp
                    ? _handleVerify
                    : null,
              ),
              const SizedBox(height: 28),

              // Resend OTP Cooldown Section
              Center(
                child: authState.canResendOtp
                    ? TextButton.icon(
                        onPressed: authState.isLoading ? null : _handleResend,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                        label: Text(
                          'Resend Verification Code',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryGreen,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${authState.resendCooldownSeconds}s',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),
              // Security info note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightSage.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your session is protected with end-to-end veterinary clinical encryption.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
