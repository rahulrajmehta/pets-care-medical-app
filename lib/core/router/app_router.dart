import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/main_scaffold.dart';
import '../../features/home/presentation/screens/profile_screen.dart';
import 'app_routes.dart';

/// RouterNotifier converts Riverpod auth state updates into GoRouter refresh triggers
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authControllerProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.isProfileCompleted != next.isProfileCompleted ||
            previous?.isInitialized != next.isInitialized ||
            previous?.isOtpSent != next.isOtpSent) {
          notifyListeners();
        }
      },
    );
  }

  /// Pure decision engine for app navigation rules
  static String? evaluateRedirect({
    required bool isInitialized,
    required bool isAuthenticated,
    required bool isProfileCompleted,
    required bool isOtpSent,
    required String matchedLocation,
  }) {
    // 1. Initial boot check
    if (!isInitialized) {
      return matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final isSplash = matchedLocation == AppRoutes.splash;
    final isLogin = matchedLocation == AppRoutes.login;
    final isOtp = matchedLocation == AppRoutes.otp;
    final isProfileSetup = matchedLocation == AppRoutes.profileSetup;
    final isHome = matchedLocation == AppRoutes.home;
    final isProfile = matchedLocation == AppRoutes.profile;

    // While the user is on the Splash screen, let the Splash screen manage
    // its smooth brand animation and navigate directly to the target destination
    // once session initialization is complete.
    if (isSplash) {
      return null;
    }

    // 2. Unauthenticated user guards
    if (!isAuthenticated) {
      if (isHome || isProfileSetup || isProfile) {
        return AppRoutes.login;
      }
      if (isOtp && !isOtpSent) {
        return AppRoutes.login;
      }
      return null;
    }

    // 3. Authenticated without completed profile
    if (!isProfileCompleted) {
      if (isProfileSetup) {
        return null;
      }
      return AppRoutes.profileSetup;
    }

    // 4. Authenticated with completed profile
    if (isLogin || isOtp || isProfileSetup) {
      return AppRoutes.home;
    }

    return null;
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    return evaluateRedirect(
      isInitialized: authState.isInitialized,
      isAuthenticated: authState.isAuthenticated,
      isProfileCompleted: authState.isProfileCompleted,
      isOtpSent: authState.isOtpSent,
      matchedLocation: state.matchedLocation,
    );
  }
}

/// Provider for GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
