import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/env.dart';

/// Service for managing Supabase client instance
/// Provides singleton access to the Supabase client throughout the app
class SupabaseService {
  // Private constructor for singleton pattern
  SupabaseService._();
  
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._();
  
  /// Get the singleton instance
  static SupabaseService get instance => _instance;
  
  /// Get the Supabase client instance (static)
  /// Returns the initialized Supabase client
  static SupabaseClient get client {
    return Supabase.instance.client;
  }
  
  /// Initialize Supabase with environment configuration
  /// Should be called once during app startup
  static Future<void> initialize() async {
    try {
      // Validate environment variables first
      EnvConfig.validate();
      
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
      );
      
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }
}
