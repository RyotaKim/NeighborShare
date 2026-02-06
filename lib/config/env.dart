import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class for managing environment variables
/// Loads values from .env file or compile-time constants (--dart-define)
class EnvConfig {
  /// Supabase project URL from environment variables
  static String get supabaseUrl {
    // First try compile-time environment variables (--dart-define)
    const compileTime = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (compileTime.isNotEmpty) return compileTime;
    
    // Fall back to .env file
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  /// Supabase anonymous/public key from environment variables
  static String get supabaseAnonKey {
    // First try compile-time environment variables (--dart-define)
    const compileTime = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (compileTime.isNotEmpty) return compileTime;
    
    // Fall back to .env file
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
  
  /// Load environment variables from .env file
  /// Should be called during app initialization before using any config values
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // .env file may not exist on web or in certain builds — that's OK
      // if --dart-define values are provided
      if (!kIsWeb) {
        print('⚠️ Could not load .env file: $e');
      }
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
    
    // Validate Supabase anon key format (should be a JWT token: 3 parts separated by dots)
    final parts = supabaseAnonKey.split('.');
    if (parts.length != 3 || !supabaseAnonKey.startsWith('eyJ')) {
      throw Exception(
        'Invalid SUPABASE_ANON_KEY format!\n\n'
        'Your anon key should be a JWT token starting with "eyJ" and having 3 parts separated by dots.\n\n'
        'To fix this:\n'
        '1. Go to your Supabase Dashboard > Project Settings > API\n'
        '2. Copy the "anon" "public" key\n'
        '3. Replace SUPABASE_ANON_KEY in your .env file\n'
      );
    }
    
    return true;
  }
}
