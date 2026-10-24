import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Screen 1: Premium Animated Splash Screen for Pet Care Medical
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _taglineFadeAnimation;
  late final Animation<Offset> _taglineSlideAnimation;
  late final Animation<double> _accentFadeAnimation;
  late final Animation<double> _footerFadeAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // 1. Logo entrance: smooth fade-in and scale-up
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // 2. Brand title entrance: fade-in with gentle upward slide
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Tagline entrance: fade-in with gentle upward slide
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.48, 0.88, curve: Curves.easeOut),
      ),
    );

    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.48, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Subtle brand accent pill fade
    _accentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.60, 0.95, curve: Curves.easeOut),
      ),
    );

    // 5. Footer and progress indicator fade
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.68, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Keep splash animation visible for ~1.75 seconds (within the 1.5-2.0s requirement)
    final minDisplayDuration = Future.delayed(const Duration(milliseconds: 1750));

    // Wait until Firebase authentication initialization completes
    final stopwatch = Stopwatch()..start();
    while (mounted && !ref.read(authControllerProvider).isInitialized) {
      if (stopwatch.elapsedMilliseconds >= 4000) {
        // Safe timeout after 4s so network startup delays do not hang indefinitely
        break;
      }
      await Future.delayed(const Duration(milliseconds: 80));
    }

    // Ensure the animation has completed before transitioning
    await minDisplayDuration;

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    try {
      if (GoRouter.maybeOf(context) == null) {
        // Safe return when tested in isolation without GoRouter provider
        return;
      }

      final authState = ref.read(authControllerProvider);

      if (authState.isAuthenticated) {
        if (authState.isProfileCompleted) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.profileSetup);
        }
      } else {
        context.go(AppRoutes.login);
      }
    } catch (_) {
      // Safe fallback on unexpected router state
      if (mounted && GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDF6F3), // Soft mint / sage tint
              Color(0xFFFAFBF9), // Calming off-white
              Color(0xFFF1F6F3), // Subtle warm sage whisper
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient soft background circles for clinical warmth
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightSage.withValues(alpha: 0.35),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x22D6E4DC),
                ),
              ),
            ),

            // Main Content Area
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // 1. Centered Animated Logo Emblem
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: _buildBrandEmblem(),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // 2. Brand Name: "Pet Care Medical"
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: SlideTransition(
                        position: _titleSlideAnimation,
                        child: Text(
                          'Pet Care Medical',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 3. Brand Tagline: "Complete Care for Your Pets"
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: SlideTransition(
                        position: _taglineSlideAnimation,
                        child: Text(
                          'Complete Care for Your Pets',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4. Subtle Paw-Print & Heart Trust Accent
                    FadeTransition(
                      opacity: _accentFadeAnimation,
                      child: _buildTrustBadge(),
                    ),

                    const Spacer(flex: 4),

                    // 5. Discreet Bottom Progress & Status
                    FadeTransition(
                      opacity: _footerFadeAnimation,
                      child: _buildFooterIndicator(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandEmblem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.26),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // White Medical Cross
            Icon(
              Icons.add_rounded,
              size: 56,
              color: AppColors.white.withValues(alpha: 0.95),
            ),
            // Warm Accent Pet Paw Icon
            Positioned(
              bottom: 21,
              child: const Icon(
                Icons.pets_rounded,
                size: 28,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6E4DC),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 13,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            'Specialized Veterinary Care',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Securing clinical session...',
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: AppColors.textHint,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
