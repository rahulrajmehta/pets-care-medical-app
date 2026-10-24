import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../domain/user_profile.dart';

/// Controller managing Firebase Phone OTP authentication and user profile onboarding
class AuthController extends Notifier<AppAuthState> {
  Timer? _cooldownTimer;
  StreamSubscription? _firebaseAuthSubscription;

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  AppAuthState build() {
    ref.onDispose(() {
      _firebaseAuthSubscription?.cancel();
      _cooldownTimer?.cancel();
    });

    // Run session check on initialization
    Future.microtask(() => _initializeAuth());

    return const AppAuthState();
  }

  /// Initial session check and auth stream listener for Firebase
  Future<void> _initializeAuth() async {
    try {
      final currentFbUser = _authRepository.currentFirebaseUser;

      if (currentFbUser != null) {
        final userId = currentFbUser.uid;
        UserProfile? profile;
        try {
          profile = await _authRepository
              .fetchProfile(userId, phone: currentFbUser.phoneNumber)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}

        state = state.copyWith(
          isInitialized: true,
          firebaseUser: currentFbUser,
          phoneNumber: currentFbUser.phoneNumber,
          userProfile: profile ??
              UserProfile(
                id: userId,
                phone: currentFbUser.phoneNumber,
                fullName: '',
                isProfileCompleted: false,
              ),
        );
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }

    // Listen to Firebase Auth state transitions
    _firebaseAuthSubscription =
        _authRepository.onFirebaseAuthStateChange.listen((fbUser) async {
      if (fbUser == null) {
        state = state.copyWith(
          clearFirebaseUser: true,
          clearProfile: true,
          isOtpSent: false,
        );
      } else if (state.firebaseUser?.uid != fbUser.uid) {
        UserProfile? profile;
        try {
          profile = await _authRepository.fetchProfile(
            fbUser.uid,
            phone: fbUser.phoneNumber,
          );
        } catch (_) {}

        state = state.copyWith(
          firebaseUser: fbUser,
          phoneNumber: fbUser.phoneNumber,
          userProfile: profile,
        );
      }
    });
  }

  /// Request Phone OTP via Firebase Phone Authentication
  Future<bool> sendOtp(String rawPhone) async {
    final validationError = Validators.validateIndianPhoneNumber(rawPhone);
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    final formattedPhone = Validators.toE164IndianPhone(rawPhone);

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      phoneNumber: formattedPhone,
    );

    final completer = Completer<bool>();

    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // Automatic SMS resolution (e.g., on Android Play Integrity)
          try {
            final userCredential =
                await _authRepository.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              UserProfile? profile;
              try {
                profile = await _authRepository.fetchProfile(user.uid, phone: user.phoneNumber);
              } catch (_) {}

              profile ??= UserProfile(
                id: user.uid,
                phone: user.phoneNumber ?? formattedPhone,
                fullName: '',
                isProfileCompleted: false,
              );

              state = state.copyWith(
                isLoading: false,
                isVerifyingOtp: false,
                firebaseUser: user,
                userProfile: profile,
                clearErrorMessage: true,
              );
              _stopResendCooldown();
              if (!completer.isCompleted) completer.complete(true);
            }
          } catch (e) {
            state = state.copyWith(
              isLoading: false,
              isVerifyingOtp: false,
              errorMessage: ErrorHandler.getReadableErrorMessage(e),
            );
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        verificationFailed: (fb.FirebaseAuthException exception) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: ErrorHandler.getReadableErrorMessage(exception),
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _startResendCooldown();
          state = state.copyWith(
            isLoading: false,
            isOtpSent: true,
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: formattedPhone,
            clearErrorMessage: true,
          );
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
        forceResendingToken: state.resendToken,
      );

      return await completer.future;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorHandler.getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Verify 6-digit OTP code with Firebase Phone Auth
  Future<bool> verifyOtp(String otpToken) async {
    if (state.isVerifyingOtp) return false;

    final validationError = Validators.validateOtp(otpToken);
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    final verificationId = state.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Verification session expired. Please request a new OTP code.',
      );
      return false;
    }

    state = state.copyWith(
      isVerifyingOtp: true,
      clearErrorMessage: true,
    );

    try {
      final userCredential = await _authRepository.verifyOtp(
        verificationId: verificationId,
        smsCode: otpToken.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Verification succeeded but no user was returned.');
      }

      UserProfile? profile;
      try {
        profile = await _authRepository.fetchProfile(user.uid, phone: user.phoneNumber);
      } catch (_) {}

      profile ??= UserProfile(
        id: user.uid,
        phone: user.phoneNumber ?? state.phoneNumber,
        fullName: '',
        isProfileCompleted: false,
      );

      state = state.copyWith(
        isVerifyingOtp: false,
        firebaseUser: user,
        userProfile: profile,
        clearErrorMessage: true,
      );

      _stopResendCooldown();
      return true;
    } catch (e) {
      state = state.copyWith(
        isVerifyingOtp: false,
        errorMessage: ErrorHandler.getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Resend OTP code if cooldown has expired
  Future<bool> resendOtp() async {
    if (!state.canResendOtp) return false;

    final phone = state.phoneNumber;
    if (phone == null || phone.isEmpty) return false;

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    final completer = Completer<bool>();

    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          try {
            final userCredential =
                await _authRepository.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              UserProfile? profile;
              try {
                profile = await _authRepository.fetchProfile(user.uid, phone: user.phoneNumber);
              } catch (_) {}

              profile ??= UserProfile(
                id: user.uid,
                phone: user.phoneNumber ?? phone,
                fullName: '',
                isProfileCompleted: false,
              );

              state = state.copyWith(
                isLoading: false,
                isVerifyingOtp: false,
                firebaseUser: user,
                userProfile: profile,
                clearErrorMessage: true,
              );
              _stopResendCooldown();
              if (!completer.isCompleted) completer.complete(true);
            }
          } catch (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: ErrorHandler.getReadableErrorMessage(e),
            );
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        verificationFailed: (fb.FirebaseAuthException exception) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: ErrorHandler.getReadableErrorMessage(exception),
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _startResendCooldown();
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            resendToken: resendToken,
            clearErrorMessage: true,
          );
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
        forceResendingToken: state.resendToken,
      );

      return await completer.future;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorHandler.getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Complete initial profile setup for first-time users
  Future<bool> saveProfile({
    required String fullName,
    String? email,
    String? avatarUrl,
  }) async {
    final nameError = Validators.validateFullName(fullName);
    if (nameError != null) {
      state = state.copyWith(errorMessage: nameError);
      return false;
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(errorMessage: emailError);
      return false;
    }

    final currentFbUser = _authRepository.currentFirebaseUser;
    final userId = currentFbUser?.uid;

    if (userId == null) {
      state = state.copyWith(
        errorMessage: 'Session expired. Please log in again.',
      );
      return false;
    }

    final userPhone = currentFbUser?.phoneNumber ?? state.phoneNumber;

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final updatedProfile = UserProfile(
        id: userId,
        fullName: fullName.trim(),
        phone: userPhone,
        email: email?.trim().isEmpty ?? true ? null : email!.trim(),
        avatarUrl: avatarUrl,
        role: 'pet_parent',
        isProfileCompleted: true,
      );

      final saved = await _authRepository.saveProfile(updatedProfile);

      state = state.copyWith(
        isLoading: false,
        userProfile: saved,
        clearErrorMessage: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorHandler.getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    _stopResendCooldown();
    try {
      await _authRepository.signOut();
    } catch (_) {}

    state = const AppAuthState(isInitialized: true);
  }

  /// Reset OTP screen state if user wants to change their phone number
  void resetOtpFlow() {
    _stopResendCooldown();
    state = state.copyWith(
      isOtpSent: false,
      clearVerificationId: true,
      clearErrorMessage: true,
    );
  }

  /// Clear active error banner
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void _startResendCooldown({int seconds = 30}) {
    _stopResendCooldown();
    state = state.copyWith(resendCooldownSeconds: seconds);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldownSeconds <= 1) {
        _stopResendCooldown();
      } else {
        state = state.copyWith(
          resendCooldownSeconds: state.resendCooldownSeconds - 1,
        );
      }
    });
  }

  void _stopResendCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    state = state.copyWith(resendCooldownSeconds: 0);
  }
}

/// Provider for AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AppAuthState>(AuthController.new);
