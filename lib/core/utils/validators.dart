/// Form input validation utilities
class Validators {
  Validators._();

  /// Validates an Indian mobile number.
  /// Indian numbers must have 10 digits and start with 6, 7, 8, or 9.
  static String? validateIndianPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }

    final cleaned = extract10DigitPhone(value);
    if (cleaned.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }

    final firstDigit = cleaned[0];
    if (!['6', '7', '8', '9'].contains(firstDigit)) {
      return 'Indian mobile numbers must start with 6, 7, 8, or 9';
    }

    return null;
  }

  /// Extracts the 10-digit mobile number from input that might contain +91 or spaces.
  static String extract10DigitPhone(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// Formats a 10-digit number to E.164 (+91XXXXXXXXXX) for Supabase Phone Auth
  static String toE164IndianPhone(String phone) {
    final tenDigits = extract10DigitPhone(phone);
    return '+91$tenDigits';
  }

  /// Formats phone for friendly UI display (+91 98765 43210)
  static String formatForDisplay(String phone) {
    final tenDigits = extract10DigitPhone(phone);
    if (tenDigits.length == 10) {
      return '+91 ${tenDigits.substring(0, 5)} ${tenDigits.substring(5)}';
    }
    return phone;
  }

  /// Validates a 6-digit OTP token
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit verification code';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 6) {
      return 'OTP code must be 6 digits';
    }
    return null;
  }

  /// Validates user's full name (required, min 2 characters)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(trimmed)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  /// Validates email address (optional, but must be valid if entered)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
