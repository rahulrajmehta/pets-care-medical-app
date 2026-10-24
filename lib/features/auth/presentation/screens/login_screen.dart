import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/premium_button.dart';
import '../widgets/terms_dialog.dart';

/// Screen 2: Mobile Login Screen with premium veterinary healthcare aesthetic
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _inlineError;
  bool _isFocused = false;
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Select Country / Region',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Text('🇮🇳', style: TextStyle(fontSize: 26)),
                  title: Text(
                    'India',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Default region for SMS verification',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightSage,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+91',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  selected: true,
                  selectedTileColor: AppColors.lightSage.withValues(alpha: 0.35),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleContinue() async {
    // Prevent duplicate submissions while request is ongoing
    if (ref.read(authControllerProvider).isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final input = _phoneController.text.trim();
    final validationError = Validators.validateIndianPhoneNumber(input);

    if (validationError != null) {
      setState(() {
        _inlineError = validationError;
      });
      return;
    }

    setState(() {
      _inlineError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(input);

    if (success && mounted) {
      context.push(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDF6F3), // Soft mint / sage tint at top
              Color(0xFFFAFBF9), // Calming off-white
              Color(0xFFF2F6F9), // Light blue-gray whisper at bottom
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle decorative ambient background elements
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF388E3C).withValues(alpha: 0.04),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),

                              // 1. BRAND HEADER (Centered)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppColors.border.withValues(alpha: 0.7),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.pets_rounded,
                                          color: AppColors.accent,
                                          size: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pet Care Medical',
                                        style: AppTextStyles.headingSmall.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryGreen,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 2. HERO PET ILLUSTRATION CARD (Centered)
                              Center(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 380,
                                    maxHeight: 185,
                                  ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFFD6E4DC),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.09),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(21),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // High quality art-directed pet illustration
                                        Image.asset(
                                          'assets/images/pet_welcome_hero.png',
                                          width: double.infinity,
                                          height: 185,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback graceful banner if image asset is unavailable
                                            return Container(
                                              height: 185,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.lightSage,
                                                    AppColors.lightSage.withValues(alpha: 0.4),
                                                  ],
                                                ),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.pets_rounded,
                                                  size: 64,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Subtle gradient scrim at bottom of hero image
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          height: 50,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black.withValues(alpha: 0.28),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Certified Clinical Trust Badge
                                        Positioned(
                                          bottom: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white.withValues(alpha: 0.94),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.verified_rounded,
                                                  size: 14,
                                                  color: AppColors.primaryGreen,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Certified Veterinary Care • 24/7 Helpline',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primaryGreen,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 3. MAIN HEADINGS (Centered with balanced mobile breaks)
                              Center(
                                child: Text(
                                  'Care that feels\nlike family',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.displayMedium.copyWith(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                    height: 1.18,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Expert veterinary care for your furry family,\nall in one place.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.38,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // 4. PHONE LOGIN SECTION (Readable, clean left-aligned label)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mobile Number',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    'Fast OTP login',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),

                              // Rounded, premium input container with subtle border & focus state
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: (_inlineError != null || authState.errorMessage != null)
                                        ? AppColors.error
                                        : _isFocused
                                            ? AppColors.primaryGreen
                                            : const Color(0xFFD6DFD6),
                                    width: _isFocused ? 1.6 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isFocused
                                          ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.03),
                                      blurRadius: _isFocused ? 14 : 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Country Code Selector (+91)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _showCountryPicker,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 15,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Color(0xFFE4ECE6),
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '🇮🇳',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '+91',
                                                style: AppTextStyles.headingMedium.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                size: 18,
                                                color: AppColors.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Phone Number Text Field
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        focusNode: _phoneFocusNode,
                                        keyboardType: TextInputType.phone,
                                        style: AppTextStyles.headingMedium.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          color: AppColors.text,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: '98765 43210',
                                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                                            color: AppColors.textHint,
                                            letterSpacing: 1.0,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 15,
                                          ),
                                          suffixIcon: _phoneController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.clear_rounded,
                                                    size: 18,
                                                    color: AppColors.textHint,
                                                  ),
                                                  onPressed: () {
                                                    _phoneController.clear();
                                                    setState(() {
                                                      _inlineError = null;
                                                    });
                                                  },
                                                )
                                              : null,
                                        ),
                                        onChanged: (val) {
                                          if (_inlineError != null) {
                                            setState(() {
                                              _inlineError = null;
                                            });
                                          }
                                        },
                                        onSubmitted: (_) => _handleContinue(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Inline validation error display
                              if (_inlineError != null) ...[
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 14,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        _inlineError!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Global Firebase Auth Error Banner
                              if (authState.errorMessage != null && _inlineError == null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.error,
                                        size: 19,
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          authState.errorMessage!,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 22),

                              // 5. PRIMARY ACTION BUTTON
                              PremiumButton(
                                label: 'Continue with Phone',
                                isLoading: authState.isLoading,
                                onPressed: _handleContinue,
                              ),

                              const Spacer(),
                              const SizedBox(height: 20),

                              // 6. DISCREET TERMS & PRIVACY FOOTER (Centered)
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'By continuing, you agree to our ',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => TermsDialog.show(
                                        context,
                                        isPrivacyPolicy: false,
                                      ),
                                      child: Text(
                                        'Terms of Service',
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 11.5,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => TermsDialog.show(
                                        context,
                                        isPrivacyPolicy: true,
                                      ),
                                      child: Text(
                                        'Privacy Policy',
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 11.5,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
