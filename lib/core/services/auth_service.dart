import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for handling user authentication operations
/// Wraps Supabase Auth functionality with app-specific logic
class AuthService {
  final SupabaseClient _supabase;
  
  AuthService() : _supabase = SupabaseService.client;
  
  /// Sign up a new user with email and password
  /// Creates auth user and profile record
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          if (fullName != null) 'full_name': fullName,
        },
        emailRedirectTo: null, // Configure for deep linking if needed
      );
      
      return response;
    } catch (e) {
      print('[Auth] Sign up failed: $e');
      rethrow;
    }
  }
  
  /// Sign in an existing user with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response;
    } catch (e) {
      print('[Auth] Sign in failed: $e');
      rethrow;
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('[Auth] Sign out failed: $e');
      rethrow;
    }
  }
  
  /// Request password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: null, // Configure for deep linking if needed
      );
    } catch (e) {
      print('[Auth] Password reset failed: $e');
      rethrow;
    }
  }
  
  /// Update user password (when user is logged in)
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return response;
    } catch (e) {
      print('[Auth] Update password failed: $e');
      rethrow;
    }
  }
  
  /// Get the current authenticated user
  User? get currentUser => _supabase.auth.currentUser;
  
  /// Get the current user's ID (convenience getter)
  String? get currentUserId => _supabase.auth.currentUser?.id;
  
  /// Get the current session
  Session? get currentSession => _supabase.auth.currentSession;
  
  /// Check if user is currently authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Stream of authentication state changes
  /// Emits whenever user signs in, signs out, or token refreshes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  /// Resend verification email to current user
  Future<void> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: user.email!,
      );
    } catch (e) {
      print('[Auth] Resend verification email failed: $e');
      rethrow;
    }
  }
  
  /// Verify if user's email is confirmed
  bool get isEmailVerified {
    final user = currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }
}
