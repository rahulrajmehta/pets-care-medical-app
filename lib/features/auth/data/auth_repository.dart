import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/firestore_provider.dart';
import '../domain/user_profile.dart';

/// Provider for FirebaseAuth instance singleton
final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

/// Repository handling Firebase Phone Authentication and Cloud Firestore profile persistence
class AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._firestore);

  /// Currently logged in Firebase user, or null if unauthenticated
  fb.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Backwards-compatible accessor for current Firebase user
  fb.User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of Firebase auth state changes
  Stream<fb.User?> get onAuthStateChange => _firebaseAuth.authStateChanges();

  /// Stream of Firebase auth state changes (alias)
  Stream<fb.User?> get onFirebaseAuthStateChange =>
      _firebaseAuth.authStateChanges();

  /// Request SMS OTP to the given phone number via Firebase Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(fb.PhoneAuthCredential credential) verificationCompleted,
    required void Function(fb.FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: timeout,
    );
  }

  /// Sign in with a PhoneAuthCredential (for automatic verification)
  Future<fb.UserCredential> signInWithCredential(
    fb.PhoneAuthCredential credential,
  ) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Verify 6-digit OTP code against Firebase Phone Auth
  Future<fb.UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Retrieve the user profile from Cloud Firestore users collection
  Future<UserProfile?> fetchProfile(String userId, {String? phone}) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = userId;
        return UserProfile.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching profile from Firestore: $e');
      rethrow;
    }
    return null;
  }

  /// Upsert profile into Cloud Firestore users collection
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final userDocRef = _firestore.collection('users').doc(profile.id);

    // Enforce role security: preserve existing role if already admin/doctor, otherwise force 'pet_parent'
    String assignedRole = 'pet_parent';
    try {
      final existingDoc = await userDocRef.get();
      if (existingDoc.exists && existingDoc.data() != null) {
        final existingRole = existingDoc.data()!['role'] as String?;
        if (existingRole == 'admin' || existingRole == 'doctor') {
          assignedRole = existingRole!;
        }
      }
    } catch (_) {
      // First-time write or initial creation
    }

    final sanitizedProfile = profile.copyWith(role: assignedRole);
    final payload = sanitizedProfile.toJson();
    payload['updatedAt'] = FieldValue.serverTimestamp();
    payload['role'] = assignedRole;

    // Direct write to Cloud Firestore
    await userDocRef.set(payload, SetOptions(merge: true));

    return sanitizedProfile;
  }

  /// Sign out current user from Firebase
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRepository(firebaseAuth, firestore);
});
