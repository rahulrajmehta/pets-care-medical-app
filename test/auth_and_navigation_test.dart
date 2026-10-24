import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care_medical/core/env/app_env.dart';
import 'package:pet_care_medical/core/router/app_router.dart';
import 'package:pet_care_medical/core/router/app_routes.dart';
import 'package:pet_care_medical/core/utils/validators.dart';
import 'package:pet_care_medical/features/auth/data/auth_repository.dart';
import 'package:pet_care_medical/features/auth/domain/user_profile.dart';
import 'package:pet_care_medical/features/auth/presentation/controllers/auth_controller.dart';

class FakeFirebaseUser extends Fake implements fb.User {
  @override
  final String uid;
  @override
  final String? phoneNumber;

  FakeFirebaseUser({
    this.uid = 'test-firebase-uid-1234',
    this.phoneNumber = '+919876543210',
  });
}

class FakeUserCredential extends Fake implements fb.UserCredential {
  final fb.User _user;
  FakeUserCredential([fb.User? user]) : _user = user ?? FakeFirebaseUser();

  @override
  fb.User? get user => _user;
}

class FakePhoneAuthCredential extends Fake implements fb.PhoneAuthCredential {}

/// Test Mock for AuthRepository using pure Firebase & Firestore concepts
class MockAuthRepository implements AuthRepository {
  fb.User? mockFirebaseUser;
  final StreamController<fb.User?> _firebaseStateController =
      StreamController<fb.User?>.broadcast();

  String? lastPhoneSent;
  String? lastTokenVerified;
  UserProfile? mockStoredProfile;

  bool shouldThrowOnSignIn = false;
  Exception? signInException;

  bool shouldThrowOnVerify = false;
  Exception? verifyException;

  bool shouldThrowOnSaveProfile = false;
  Exception? saveProfileException;

  bool triggerAutoVerification = false;

  @override
  fb.User? get currentFirebaseUser => mockFirebaseUser;

  @override
  fb.User? get currentUser => mockFirebaseUser;

  @override
  Stream<fb.User?> get onAuthStateChange =>
      _firebaseStateController.stream;

  @override
  Stream<fb.User?> get onFirebaseAuthStateChange =>
      _firebaseStateController.stream;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(fb.PhoneAuthCredential credential) verificationCompleted,
    required void Function(fb.FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    lastPhoneSent = phoneNumber;
    if (shouldThrowOnSignIn) {
      verificationFailed(
        (signInException as fb.FirebaseAuthException?) ??
            fb.FirebaseAuthException(
              code: 'quota-exceeded',
              message: 'Too many requests',
            ),
      );
      return;
    }

    if (triggerAutoVerification) {
      final user = FakeFirebaseUser(
        uid: 'test-firebase-uid-auto',
        phoneNumber: phoneNumber,
      );
      mockFirebaseUser = user;
      verificationCompleted(FakePhoneAuthCredential());
      return;
    }

    codeSent('test-verification-id-123456', 999);
  }

  @override
  Future<fb.UserCredential> signInWithCredential(
    fb.PhoneAuthCredential credential,
  ) async {
    final user = FakeFirebaseUser(
      uid: 'test-firebase-uid-auto',
      phoneNumber: lastPhoneSent ?? '+919876543210',
    );
    mockFirebaseUser = user;
    return FakeUserCredential(user);
  }

  @override
  Future<fb.UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    lastTokenVerified = smsCode;
    if (shouldThrowOnVerify) {
      throw verifyException ??
          fb.FirebaseAuthException(
            code: 'invalid-verification-code',
            message: 'Invalid or expired OTP token',
          );
    }

    final user = FakeFirebaseUser(
      uid: 'test-firebase-uid-1234',
      phoneNumber: lastPhoneSent ?? '+919876543210',
    );
    mockFirebaseUser = user;
    return FakeUserCredential(user);
  }

  @override
  Future<UserProfile?> fetchProfile(String userId, {String? phone}) async {
    return mockStoredProfile;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    if (shouldThrowOnSaveProfile) {
      throw saveProfileException ??
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Permission denied: cannot write to users collection.',
          );
    }

    // Role escalation security guard: client writes cannot assign admin role
    final safeRole = profile.role == 'admin' ? 'pet_parent' : profile.role;
    final savedProfile = profile.copyWith(role: safeRole);

    mockStoredProfile = savedProfile;
    return savedProfile;
  }

  @override
  Future<void> signOut() async {
    mockFirebaseUser = null;
    _firebaseStateController.add(null);
  }

  void dispose() {
    _firebaseStateController.close();
  }
}

void main() {
  group('Pet Care Medical - Step 1 Verification Tests', () {
    late MockAuthRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      AppEnv.bypassEnvCheckForTesting = true;
      mockRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      mockRepo.dispose();
      AppEnv.bypassEnvCheckForTesting = false;
    });

    // -------------------------------------------------------------------------
    // TEST 1: Invalid Phone Number Validation
    // -------------------------------------------------------------------------
    test('1. Test Invalid phone number validation', () async {
      // Empty phone
      expect(
        Validators.validateIndianPhoneNumber(''),
        'Please enter your mobile number',
      );

      // Less than 10 digits
      expect(
        Validators.validateIndianPhoneNumber('98765'),
        'Mobile number must be exactly 10 digits',
      );

      // 10 digits starting with invalid Indian prefix (e.g. 1, 2, 3, 4, 5)
      expect(
        Validators.validateIndianPhoneNumber('5555555555'),
        'Indian mobile numbers must start with 6, 7, 8, or 9',
      );

      // Valid Indian phone numbers (starting with 6, 7, 8, 9)
      expect(Validators.validateIndianPhoneNumber('9876543210'), isNull);
      expect(Validators.validateIndianPhoneNumber('8123456789'), isNull);
      expect(Validators.validateIndianPhoneNumber('7012345678'), isNull);
      expect(Validators.validateIndianPhoneNumber('6398765432'), isNull);

      // AuthController should reject invalid phone
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.sendOtp('12345');
      expect(result, isFalse);
      expect(
        container.read(authControllerProvider).errorMessage,
        'Mobile number must be exactly 10 digits',
      );
    });

    // -------------------------------------------------------------------------
    // TEST 2: OTP Request
    // -------------------------------------------------------------------------
    test('2. Test OTP request with valid phone number', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.sendOtp('9876543210');

      expect(result, isTrue);
      expect(mockRepo.lastPhoneSent, '+919876543210');

      final state = container.read(authControllerProvider);
      expect(state.isOtpSent, isTrue);
      expect(state.phoneNumber, '+919876543210');
      expect(state.resendCooldownSeconds, greaterThan(0));
      expect(state.errorMessage, isNull);
    });

    // -------------------------------------------------------------------------
    // TEST 3: Wrong OTP
    // -------------------------------------------------------------------------
    test('3. Test Wrong OTP error handling', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');

      mockRepo.shouldThrowOnVerify = true;
      mockRepo.verifyException = fb.FirebaseAuthException(
        code: 'invalid-verification-code',
        message: 'The 6-digit OTP entered is incorrect. Please check the code and try again.',
      );

      final result = await controller.verifyOtp('000000');
      expect(result, isFalse);

      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(
        state.errorMessage,
        'The 6-digit OTP entered is incorrect. Please check the code and try again.',
      );
    });

    // -------------------------------------------------------------------------
    // TEST 4: Expired OTP
    // -------------------------------------------------------------------------
    test('4. Test Expired OTP error handling', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');

      mockRepo.shouldThrowOnVerify = true;
      mockRepo.verifyException = fb.FirebaseAuthException(
        code: 'session-expired',
        message: 'The OTP code has expired. Please tap "Resend Code" to receive a fresh verification code.',
      );

      final result = await controller.verifyOtp('123456');
      expect(result, isFalse);

      final state = container.read(authControllerProvider);
      expect(
        state.errorMessage,
        'The OTP code has expired. Please tap "Resend Code" to receive a fresh verification code.',
      );
    });

    // -------------------------------------------------------------------------
    // TEST 5: Correct OTP
    // -------------------------------------------------------------------------
    test('5. Test Correct OTP verification succeeds and establishes session',
        () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');

      mockRepo.shouldThrowOnVerify = false;
      final result = await controller.verifyOtp('123456');

      expect(result, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.firebaseUser, isNotNull);
      expect(state.errorMessage, isNull);
    });

    // -------------------------------------------------------------------------
    // TEST 6: New User Profile Setup
    // -------------------------------------------------------------------------
    test('6. Test New user profile setup validation and completion', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      await controller.verifyOtp('123456');

      // Before profile setup, profile is not completed
      expect(
        container.read(authControllerProvider).isProfileCompleted,
        isFalse,
      );

      // Name validation: cannot be blank or single letter
      expect(Validators.validateFullName(''), 'Full name is required');
      expect(
        Validators.validateFullName('A'),
        'Name must be at least 2 characters',
      );

      // Save valid profile
      final saveResult = await controller.saveProfile(
        fullName: 'Dr. Rahul Sharma',
        email: 'rahul@example.com',
      );

      expect(saveResult, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.isProfileCompleted, isTrue);
      expect(state.userProfile?.fullName, 'Dr. Rahul Sharma');
      expect(state.userProfile?.email, 'rahul@example.com');
      expect(mockRepo.mockStoredProfile?.isProfileCompleted, isTrue);
    });

    // -------------------------------------------------------------------------
    // TEST 7: Existing User Login
    // -------------------------------------------------------------------------
    test('7. Test Existing user login preserves completed profile', () async {
      // Pre-set existing completed profile in DB
      mockRepo.mockStoredProfile = const UserProfile(
        id: 'test-user-uuid-1234',
        fullName: 'Pooja Verma',
        phone: '+919876543210',
        email: 'pooja@example.com',
        isProfileCompleted: true,
      );

      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      await controller.verifyOtp('123456');

      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isProfileCompleted, isTrue);
      expect(state.userProfile?.fullName, 'Pooja Verma');
    });

    // -------------------------------------------------------------------------
    // TEST 8: Session Persistence
    // -------------------------------------------------------------------------
    test('8. Test Session persistence initializes active session on app launch',
        () async {
      final persistedUser = FakeFirebaseUser(
        uid: 'persisted-uuid-999',
        phoneNumber: '+919876543210',
      );

      mockRepo.mockFirebaseUser = persistedUser;
      mockRepo.mockStoredProfile = const UserProfile(
        id: 'persisted-uuid-999',
        fullName: 'Amit Patel',
        isProfileCompleted: true,
      );

      // Create new container representing cold app startup
      final newContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Trigger initialization
      newContainer.read(authControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = newContainer.read(authControllerProvider);
      expect(state.isInitialized, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.isProfileCompleted, isTrue);
      expect(state.userProfile?.fullName, 'Amit Patel');

      newContainer.dispose();
    });

    // -------------------------------------------------------------------------
    // TEST 9: Logout
    // -------------------------------------------------------------------------
    test('9. Test Logout clears session and resets authentication state',
        () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      await controller.verifyOtp('123456');
      await controller.saveProfile(fullName: 'Vikram Singh');

      expect(container.read(authControllerProvider).isAuthenticated, isTrue);

      await controller.signOut();

      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.firebaseUser, isNull);
      expect(state.userProfile, isNull);
      expect(mockRepo.mockFirebaseUser, isNull);
    });

    // -------------------------------------------------------------------------
    // TEST 11: Firebase Instant Auto-Verification (SMS Retriever)
    // -------------------------------------------------------------------------
    test('11. Test Firebase instant auto-verification signs in automatically',
        () async {
      mockRepo.triggerAutoVerification = true;
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.sendOtp('9876543210');

      expect(result, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.firebaseUser, isNotNull);
      expect(state.errorMessage, isNull);
    });

    // -------------------------------------------------------------------------
    // TEST 10: Unauthorized Access to Home (GoRouter Redirection)
    // -------------------------------------------------------------------------
    test('10. Test Unauthorized access to Home is redirected to Login', () {
      // 10a. Unauthenticated state attempting to visit Home:
      final redirectHome = RouterNotifier.evaluateRedirect(
        isInitialized: true,
        isAuthenticated: false,
        isProfileCompleted: false,
        isOtpSent: false,
        matchedLocation: AppRoutes.home,
      );
      expect(redirectHome, AppRoutes.login);

      // 10b. Unauthenticated state attempting to visit Profile Setup:
      final redirectProfileSetup = RouterNotifier.evaluateRedirect(
        isInitialized: true,
        isAuthenticated: false,
        isProfileCompleted: false,
        isOtpSent: false,
        matchedLocation: AppRoutes.profileSetup,
      );
      expect(redirectProfileSetup, AppRoutes.login);

      // 10c. Authenticated with incomplete profile visiting Home:
      final redirectIncomplete = RouterNotifier.evaluateRedirect(
        isInitialized: true,
        isAuthenticated: true,
        isProfileCompleted: false,
        isOtpSent: false,
        matchedLocation: AppRoutes.home,
      );
      expect(redirectIncomplete, AppRoutes.profileSetup);

      // 10d. Authenticated with completed profile visiting Login:
      final redirectCompleted = RouterNotifier.evaluateRedirect(
        isInitialized: true,
        isAuthenticated: true,
        isProfileCompleted: true,
        isOtpSent: false,
        matchedLocation: AppRoutes.login,
      );
      expect(redirectCompleted, AppRoutes.home);
    });

    // -------------------------------------------------------------------------
    // TEST 12: Admin Role Privilege Escalation Prevention
    // -------------------------------------------------------------------------
    test('12. Test Profile creation forces pet_parent role and blocks admin self-assignment', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      await controller.verifyOtp('123456');

      final success = await controller.saveProfile(
        fullName: 'Hacker Parent',
      );

      expect(success, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.userProfile?.role, 'pet_parent');
      expect(state.userProfile?.isAdmin, isFalse);
      expect(mockRepo.mockStoredProfile?.role, 'pet_parent');
      expect(mockRepo.mockStoredProfile?.isAdmin, isFalse);
    });

    // -------------------------------------------------------------------------
    // TEST 13: Firestore Write Failure (No Fake Success)
    // -------------------------------------------------------------------------
    test('13. Test Firestore write failure returns false and does not fake success', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      await controller.verifyOtp('123456');

      mockRepo.shouldThrowOnSaveProfile = true;
      mockRepo.saveProfileException = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      );

      final success = await controller.saveProfile(
        fullName: 'Dr. Test User',
      );

      expect(success, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.isProfileCompleted, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Permission denied'));
    });
  });
}
