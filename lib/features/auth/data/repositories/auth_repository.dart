import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Repository for authentication operations
/// Handles all auth-related data operations with Supabase
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository() : _client = SupabaseService.client;

  /// Sign up a new user with email and password
  /// Creates auth user; profile will be created on first login
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      // Sign up user with Supabase Auth
      // Store username/fullName in user metadata for later profile creation
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Failed to create account');
      }

      // Profile will be created on first sign-in after email verification
      // because RLS requires an authenticated session (auth.uid() = id)
    } on AuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to sign up: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign in an existing user with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Failed to sign in');
      }

      // Ensure profile exists (create if first login after signup)
      final profile = await _ensureProfileExists(response.user!);
      return profile;
    } on AuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode,
        originalError: e,
      );
    } on AppAuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to sign in: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to sign out. Please try again.',
        originalError: e,
      );
    }
  }

  /// Get current authenticated user
  User? getCurrentAuthUser() {
    return _client.auth.currentUser;
  }

  /// Get current user's profile
  /// If user is authenticated but has no profile, creates one
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = getCurrentAuthUser();
      if (user == null) return null;

      return await _ensureProfileExists(user);
    } catch (e) {
      return null;
    }
  }

  /// Ensure a profile exists for the given auth user
  /// Creates the profile from user metadata if it doesn't exist yet
  Future<UserModel> _ensureProfileExists(User user) async {
    try {
      // Try to fetch existing profile
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }

      // Profile doesn't exist — create it from auth metadata
      final metadata = user.userMetadata ?? {};
      final username = metadata['username'] as String? ??
          user.email?.split('@').first ??
          'user_${user.id.substring(0, 8)}';
      final fullName = metadata['full_name'] as String?;

      final profileData = {
        'id': user.id,
        'username': username,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final profileResponse = await _client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return UserModel.fromJson(profileResponse);
    } on PostgrestException catch (e) {
      // If unique constraint violation on username, add a suffix and retry
      if (e.code == '23505') {
        final metadata = user.userMetadata ?? {};
        final baseUsername = metadata['username'] as String? ??
            user.email?.split('@').first ??
            'user';
        final uniqueUsername = '${baseUsername}_${DateTime.now().millisecondsSinceEpoch % 10000}';

        final profileData = {
          'id': user.id,
          'username': uniqueUsername,
          'full_name': metadata['full_name'] as String?,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final profileResponse = await _client
            .from('profiles')
            .insert(profileData)
            .select()
            .single();

        return UserModel.fromJson(profileResponse);
      }
      throw DatabaseException(
        message: 'Failed to create user profile',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Get user profile by ID
  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch user profile',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch user profile',
        originalError: e,
      );
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? neighborhood,
    String? bio,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (fullName != null) updateData['full_name'] = fullName;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (neighborhood != null) updateData['neighborhood'] = neighborhood;
      if (bio != null) updateData['bio'] = bio;

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Check for unique constraint violation (duplicate username)
      if (e.code == '23505') {
        throw const ValidationException(
          message: 'Username is already taken',
          code: 'duplicate_username',
        );
      }

      throw DatabaseException(
        message: 'Failed to update profile',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update profile',
        originalError: e,
      );
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      // If error occurs, assume username might not be available
      return false;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AppAuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to send password reset email',
        originalError: e,
      );
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AppAuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to update password',
        originalError: e,
      );
    }
  }

  /// Resend email verification
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AppAuthException catch (e) {
      throw AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to resend verification email',
        originalError: e,
      );
    }
  }

  /// Check if current user's email is verified
  bool isEmailVerified() {
    final user = getCurrentAuthUser();
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// Delete user account
  /// Note: This requires admin privileges or RPC function in Supabase
  Future<void> deleteAccount() async {
    try {
      // First delete user's profile and related data
      final user = getCurrentAuthUser();
      if (user == null) {
        throw const AppAuthException(message: 'No user logged in');
      }

      // Delete profile (cascades to items, conversations, messages)
      await _client.from('profiles').delete().eq('id', user.id);

      // Sign out
      await signOut();
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to delete account',
        originalError: e,
      );
    }
  }
}

