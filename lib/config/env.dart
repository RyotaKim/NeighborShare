import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class for managing environment variables
/// Loads values from .env file (mobile) or compile-time constants (web)
class EnvConfig {
  /// Supabase project URL from environment variables
  static String get supabaseUrl {
    if (kIsWeb) {
      // For web, use compile-time environment variables
      return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  /// Supabase anonymous/public key from environment variables
  static String get supabaseAnonKey {
    if (kIsWeb) {
      // For web, use compile-time environment variables
      return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
  
  /// Load environment variables from .env file
  /// Should be called during app initialization before using any config values
  /// On web, this is a no-op as environment variables are loaded at compile-time
  static Future<void> load() async {
    if (!kIsWeb) {
      await dotenv.load(fileName: ".env");
    }
  }
  
  /// Validate that all required environment variables are present
  static bool validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set in .env file');
    }
    return true;
  }
}
