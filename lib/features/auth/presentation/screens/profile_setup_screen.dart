import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/premium_button.dart';

/// Screen 4: First-Time User Profile Setup
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _nameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // Prefill if partial profile exists
    final profile = ref.read(authControllerProvider).userProfile;
    if (profile != null) {
      if (profile.fullName.isNotEmpty) {
        _nameController.text = profile.fullName;
      }
      if (profile.email != null && profile.email!.isNotEmpty) {
        _emailController.text = profile.email!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final nameValidation = Validators.validateFullName(name);
    final emailValidation = Validators.validateEmail(email);

    setState(() {
      _nameError = nameValidation;
      _emailError = emailValidation;
    });

    if (nameValidation != null || emailValidation != null) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .saveProfile(
          fullName: name,
          email: email.isEmpty ? null : email,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final phoneDisplay = authState.phoneNumber != null
        ? Validators.formatForDisplay(authState.phoneNumber!)
        : (authState.firebaseUser?.phoneNumber != null
            ? Validators.formatForDisplay(authState.firebaseUser!.phoneNumber!)
            : '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complete Profile',
          style: AppTextStyles.headingMedium,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: Text(
              'Sign Out',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const ClampingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Pet Parent Avatar Badge
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColors.lightSage,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 56,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            size: 16,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome, Pet Parent! 🐾',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please tell us your name so our veterinary doctors know who is caring for your pets.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Full Name Input (Required)
                Row(
                  children: [
                    Text(
                      'Full Name',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. Rahul Sharma',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    errorText: _nameError,
                  ),
                  onChanged: (val) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Email Input (Optional)
                Row(
                  children: [
                    Text(
                      'Email Address',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(Optional)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. rahul@example.com',
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    errorText: _emailError,
                  ),
                  onChanged: (val) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Verified Phone Number (Read-only)
                Text(
                  'Verified Mobile Number',
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightSage.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        phoneDisplay.isNotEmpty
                            ? phoneDisplay
                            : 'Verified in Session',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verified',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message banner
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Complete Profile CTA
                PremiumButton(
                  label: 'Complete Profile & Enter Home',
                  isLoading: authState.isLoading,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                  onPressed: _handleSubmit,
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Stored securely in Cloud Firestore with Firebase Security Rules',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
