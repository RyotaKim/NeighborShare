import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Provider for AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for auth state changes stream
/// Listens to Supabase auth state changes (login/logout/session refresh)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider for current user
/// Returns UserModel if user is authenticated, null otherwise
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provider for checking if email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isEmailVerified();
});

/// Provider for username availability check
/// Use with family modifier: usernameAvailabilityProvider(username)
final usernameAvailabilityProvider = FutureProvider.family<bool, String>((ref, username) async {
  if (username.isEmpty || username.length < 3) return false;
  
  final repository = ref.watch(authRepositoryProvider);
  return repository.isUsernameAvailable(username);
});

/// StateNotifier for managing auth state and operations
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  /// Initialize auth state
  Future<void> _init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign up with email, password, and username
  /// Only creates auth user; profile is created on first sign-in
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      await _repository.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );
      
      // User is signed up but not yet verified — no profile yet
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      
      state = AsyncValue.data(user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Re-throw to allow UI to show specific error message
    }
  }

  /// Sign out current user
  Future<bool> signOut() async {
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? neighborhood,
    String? bio,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) {
        throw const AppAuthException(message: 'No user logged in');
      }

      state = const AsyncValue.loading();
      
      final updatedUser = await _repository.updateProfile(
        userId: currentUser.id,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        neighborhood: neighborhood,
        bio: bio,
      );
      
      state = AsyncValue.data(updatedUser);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Re-throw to allow UI to show specific error message
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _repository.updatePassword(newPassword);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _repository.resendVerificationEmail(email);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Refresh current user data
  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider for current authenticated user
/// Returns null if not authenticated or loading
final authenticatedUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authenticatedUserProvider);
  return user != null;
});
