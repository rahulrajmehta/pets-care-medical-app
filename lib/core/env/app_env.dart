import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager for Supabase credentials.
/// Reads from .env file or --dart-define compilation flags.
class AppEnv {
  AppEnv._();

  static const String _defaultPlaceholderUrl = 'https://your-project-id.supabase.co';
  static const String _defaultPlaceholderKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key-placeholder';

  /// Testing override
  static bool bypassEnvCheckForTesting = false;

  /// Initialize environment by attempting to load .env file.
  /// If .env is absent or invalid, it gracefully falls back to compilation defines.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env file is optional if provided via --dart-define
    }
  }

  /// Supabase project URL
  static String get supabaseUrl {
    const defineUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;

    try {
      final envUrl = dotenv.env['SUPABASE_URL'];
      if (envUrl != null && envUrl.isNotEmpty) return envUrl.trim();
    } catch (_) {}

    return _defaultPlaceholderUrl;
  }

  /// Supabase anonymous public API key
  static String get supabaseAnonKey {
    const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) return defineKey;

    try {
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (envKey != null && envKey.isNotEmpty) return envKey.trim();
    } catch (_) {}

    return _defaultPlaceholderKey;
  }

  /// Check whether real Supabase credentials have been configured
  static bool get isConfigured {
    if (bypassEnvCheckForTesting) return true;

    final url = supabaseUrl;
    final key = supabaseAnonKey;

    final isUrlPlaceholder = url.isEmpty ||
        url.contains('your-project') ||
        url.contains('xyzcompany') ||
        url == _defaultPlaceholderUrl;

    final isKeyPlaceholder = key.isEmpty ||
        key.contains('dummy_anon_key') ||
        key.contains('your-anon-key') ||
        key == _defaultPlaceholderKey;

    return !isUrlPlaceholder && !isKeyPlaceholder;
  }

  /// Detailed human-readable guidance when Supabase credentials are missing
  static String get configurationErrorNotice {
    return 'Supabase credentials are not configured.\n\n'
        'Please update the `.env` file in the project root with your actual project URL and Anon key:\n'
        '• SUPABASE_URL=https://[YOUR_PROJECT_REF].supabase.co\n'
        '• SUPABASE_ANON_KEY=[YOUR_ANON_KEY]\n\n'
        'Also ensure Phone Auth and an SMS Provider (e.g., Twilio) are enabled in your Supabase Dashboard.';
  }
}
