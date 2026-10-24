import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'user_profile.dart';

/// State representation for authentication and user onboarding
class AppAuthState {
  final bool isInitialized;
  final bool isLoading;
  final bool isVerifyingOtp;
  final String? errorMessage;
  final String? phoneNumber;
  final bool isOtpSent;
  final int resendCooldownSeconds;
  final String? verificationId;
  final int? resendToken;
  final fb.User? firebaseUser;
  final UserProfile? userProfile;

  const AppAuthState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isVerifyingOtp = false,
    this.errorMessage,
    this.phoneNumber,
    this.isOtpSent = false,
    this.resendCooldownSeconds = 0,
    this.verificationId,
    this.resendToken,
    this.firebaseUser,
    this.userProfile,
  });

  bool get isAuthenticated => firebaseUser != null;

  bool get isProfileCompleted =>
      userProfile != null && userProfile!.hasCompletedProfile;

  bool get canResendOtp => resendCooldownSeconds <= 0;

  AppAuthState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isVerifyingOtp,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? phoneNumber,
    bool? isOtpSent,
    int? resendCooldownSeconds,
    String? verificationId,
    bool clearVerificationId = false,
    int? resendToken,
    fb.User? firebaseUser,
    bool clearFirebaseUser = false,
    UserProfile? userProfile,
    bool clearProfile = false,
  }) {
    return AppAuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
      verificationId: clearVerificationId
          ? null
          : (verificationId ?? this.verificationId),
      resendToken: resendToken ?? this.resendToken,
      firebaseUser:
          clearFirebaseUser ? null : (firebaseUser ?? this.firebaseUser),
      userProfile: clearProfile ? null : (userProfile ?? this.userProfile),
    );
  }
}
