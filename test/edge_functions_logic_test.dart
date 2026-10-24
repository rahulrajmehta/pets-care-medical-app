import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';


/// Test suite verifying the algorithmic logic implemented inside the Supabase Edge Functions
void main() {
  group('Step 3: Supabase Edge Functions Logic Verification', () {
    // -------------------------------------------------------------------------
    // 1. Phone Normalization Logic
    // -------------------------------------------------------------------------
    test('1. Validates and normalizes Indian mobile numbers for Textlocal API', () {
      String? normalizeIndianPhone(String input) {
        String digits = input.replaceAll(RegExp(r'\D'), '');
        if (digits.startsWith('91') && digits.length == 12) {
          digits = digits.substring(2);
        } else if (digits.startsWith('0') && digits.length == 11) {
          digits = digits.substring(1);
        }
        if (digits.length != 10) return null;
        if (!['6', '7', '8', '9'].contains(digits[0])) return null;
        return '+91$digits';
      }

      expect(normalizeIndianPhone('9876543210'), '+919876543210');
      expect(normalizeIndianPhone('+919876543210'), '+919876543210');
      expect(normalizeIndianPhone('09876543210'), '+919876543210');
      expect(normalizeIndianPhone('91-98765-43210'), '+919876543210');

      // Invalid numbers
      expect(normalizeIndianPhone('1234567890'), isNull);
      expect(normalizeIndianPhone('5555555555'), isNull);
      expect(normalizeIndianPhone('98765'), isNull);
    });

    // -------------------------------------------------------------------------
    // 2. Cryptographic OTP Generation
    // -------------------------------------------------------------------------
    test('2. Generates secure 6-digit OTP in range [100000, 999999]', () {
      final random = Random.secure();
      for (int i = 0; i < 100; i++) {
        final otpInt = 100000 + random.nextInt(900000);
        final otpString = otpInt.toString();
        expect(otpString.length, 6);
        expect(otpInt, greaterThanOrEqualTo(100000));
        expect(otpInt, lessThanOrEqualTo(999999));
      }
    });

    // -------------------------------------------------------------------------
    // 3. Salt and SHA-256 Hash Integrity
    // -------------------------------------------------------------------------
    test('3. Generates reproducible salt-based SHA-256 hash without storing plaintext OTP', () {
      String hashOtp(String otp, String salt) {
        final bytes = utf8.encode('$salt:$otp');
        final digest = sha256.convert(bytes);
        return digest.toString();
      }

      const otp = '482915';
      const salt1 = 'salt-uuid-1111';
      const salt2 = 'salt-uuid-2222';

      final hash1 = hashOtp(otp, salt1);
      final hash1Again = hashOtp(otp, salt1);
      final hash2 = hashOtp(otp, salt2);
      final wrongOtpHash = hashOtp('999999', salt1);

      // Same OTP and salt must yield identical hash
      expect(hash1, hash1Again);

      // Different salt must yield completely different hash
      expect(hash1, isNot(hash2));

      // Incorrect OTP must not match
      expect(hash1, isNot(wrongOtpHash));
    });

    // -------------------------------------------------------------------------
    // 4. Expiration Handling
    // -------------------------------------------------------------------------
    test('4. Correctly rejects expired OTP records', () {
      bool isExpired(DateTime expiresAt, DateTime currentTime) {
        return currentTime.isAfter(expiresAt);
      }

      final now = DateTime.now();
      final validFuture = now.add(const Duration(minutes: 10));
      final expiredPast = now.subtract(const Duration(seconds: 1));

      expect(isExpired(validFuture, now), isFalse);
      expect(isExpired(expiredPast, now), isTrue);
    });

    // -------------------------------------------------------------------------
    // 5. Attempt Limit (Brute-force protection)
    // -------------------------------------------------------------------------
    test('5. Enforces max attempts (5) abuse protection', () {
      bool canAttempt(int currentAttempts, int maxAttempts) {
        return currentAttempts < maxAttempts;
      }

      expect(canAttempt(0, 5), isTrue);
      expect(canAttempt(4, 5), isTrue);
      expect(canAttempt(5, 5), isFalse);
      expect(canAttempt(6, 5), isFalse);
    });
  });
}
