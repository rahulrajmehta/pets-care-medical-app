import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error message mapper for Firebase Auth, Cloud Firestore and network operations
class ErrorHandler {
  ErrorHandler._();

  /// Translates an exception into a clean, actionable message for the user.
  static String getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuthException(error);
    }

    if (error is FirebaseException) {
      return _mapFirebaseException(error);
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('failed host lookup')) {
      return 'Network connection issue. Please check your internet connection.';
    }

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'An unexpected error occurred: ${error.toString()}';
  }

  static String _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'The mobile number entered is invalid. Please check the digits and try again.';
      case 'invalid-verification-code':
        return 'The 6-digit OTP entered is incorrect. Please check the code and try again.';
      case 'session-expired':
      case 'invalid-verification-id':
        return 'The OTP code has expired. Please tap "Resend Code" to receive a fresh verification code.';
      case 'quota-exceeded':
      case 'too-many-requests':
        return 'Too many OTP attempts or SMS quota exceeded. For security, please wait a few minutes before trying again.';
      case 'missing-client-identifier':
      case 'app-not-authorized':
        return 'Firebase safety verification failed. Please verify that your device has internet access and Google Play Services enabled.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Phone authentication is disabled in Firebase Console. Please enable Phone sign-in under Authentication > Sign-in method.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact customer support.';
      default:
        if (error.message != null && error.message!.isNotEmpty) {
          return error.message!;
        }
        return 'Authentication failed (${error.code}). Please try again.';
    }
  }

  static String _mapFirebaseException(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied: You do not have access to perform this operation.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please check your connection and try again.';
      case 'not-found':
        return 'The requested record was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'deadline-exceeded':
        return 'The operation timed out. Please try again.';
      default:
        if (error.message != null && error.message!.isNotEmpty) {
          return error.message!;
        }
        return 'Database operation failed (${error.code}). Please try again.';
    }
  }
}
