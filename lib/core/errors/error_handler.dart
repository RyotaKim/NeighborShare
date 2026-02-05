import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';

/// Central error handler for the application
/// Converts various error types into user-friendly messages
class ErrorHandler {
  /// Convert any exception into a user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    // Handle our custom AppException types
    if (error is AppException) {
      return error.message;
    }

    // Handle Supabase-specific errors
    if (error is AppAuthException) {
      return _handleSupabaseAuthError(error);
    }

    if (error is AppStorageException) {
      return _handleSupabaseStorageError(error);
    }

    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    }

    // Handle standard Dart exceptions
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }

    if (error is TypeError) {
      return 'An unexpected error occurred. Please restart the app.';
    }

    // Fallback for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Convert Supabase auth errors to user-friendly messages
  static String _handleSupabaseAuthError(AppAuthException error) {
    final message = error.message.toLowerCase();

    // Email/Password errors
    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }

    if (message.contains('user already registered') ||
        message.contains('email already exists')) {
      return 'This email is already registered. Please log in instead.';
    }

    if (message.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }

    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    // Session errors
    if (message.contains('session expired') ||
        message.contains('refresh token not found')) {
      return 'Your session has expired. Please log in again.';
    }

    if (message.contains('not authenticated')) {
      return 'You need to log in to continue.';
    }

    // Rate limiting
    if (message.contains('email rate limit exceeded') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }

    // Password reset errors
    if (message.contains('unable to send email')) {
      return 'Could not send email. Please check the email address and try again.';
    }

    // Fallback
    return 'Authentication error: ${error.message}';
  }

  /// Convert Supabase storage errors to user-friendly messages
  static String _handleSupabaseStorageError(AppStorageException error) {
    final message = error.message.toLowerCase();

    // Upload errors
    if (message.contains('payload too large') || message.contains('file too large')) {
      return 'File is too large. Maximum size is 5MB for items and 2MB for avatars.';
    }

    if (message.contains('invalid mime type') || message.contains('unsupported file type')) {
      return 'Invalid file type. Please select a JPEG, PNG, or WebP image.';
    }

    if (message.contains('not found')) {
      return 'File not found. It may have been deleted.';
    }

    // Permission errors
    if (message.contains('permission denied') || message.contains('unauthorized')) {
      return 'You do not have permission to access this file.';
    }

    if (message.contains('bucket not found')) {
      return 'Storage configuration error. Please contact support.';
    }

    // Network errors
    if (message.contains('network') || message.contains('timeout')) {
      return 'Network error. Please check your connection and try again.';
    }

    // Fallback
    return 'Storage error: ${error.message}';
  }

  /// Convert Postgrest (database) errors to user-friendly messages
  static String _handlePostgrestError(PostgrestException error) {
    final message = error.message.toLowerCase();
    final code = error.code;

    // Row Level Security errors
    if (message.contains('row level security') ||
        message.contains('insufficient privilege') ||
        code == '42501') {
      return 'You do not have permission to perform this action.';
    }

    // Unique constraint violations
    if (message.contains('unique constraint') ||
        message.contains('duplicate key') ||
        code == '23505') {
      return 'This entry already exists. Please use a different value.';
    }

    // Foreign key violations
    if (message.contains('foreign key') || code == '23503') {
      return 'Cannot complete action. Related data may have been deleted.';
    }

    // Not null violations
    if (message.contains('not null') || code == '23502') {
      return 'Required information is missing. Please fill in all required fields.';
    }

    // Not found errors
    if (message.contains('not found') || code == 'PGRST116') {
      return 'The requested item was not found.';
    }

    // Invalid input
    if (message.contains('invalid input') || code == '22P02') {
      return 'Invalid data provided. Please check your input.';
    }

    // Timeout
    if (message.contains('timeout') || message.contains('canceling statement')) {
      return 'Request took too long. Please try again.';
    }

    // Fallback
    return 'Database error. Please try again later.';
  }

  /// Log error for debugging (can be extended with crash reporting)
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    print('═══════════════════════════════════════════════════════');
    print('ERROR${context != null ? ' in $context' : ''}:');
    print('Type: ${error.runtimeType}');
    print('Message: $error');
    if (stackTrace != null) {
      print('Stack trace:');
      print(stackTrace.toString());
    }
    print('═══════════════════════════════════════════════════════');

    // TODO: In production, send to crash reporting service (e.g., Sentry, Firebase Crashlytics)
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is NetworkException) return true;

    final message = error.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('host lookup failed') ||
        message.contains('no internet');
  }

  /// Check if error requires re-authentication
  static bool requiresReauth(dynamic error) {
    if (error is AppAuthException &&
        (error.code == 'session_expired' || error.code == 'unauthorized')) {
      return true;
    }

    if (error is NetworkException && error.code == 'unauthorized') {
      return true;
    }

    if (error is AppAuthException) {
      final message = error.message.toLowerCase();
      return message.contains('session expired') ||
          message.contains('not authenticated') ||
          message.contains('refresh token');
    }

    return false;
  }

  /// Convert error to AppException if not already
  static AppException toAppException(dynamic error) {
    if (error is AppException) return error;

    if (error is AppAuthException) {
      return AppAuthException(
        message: _handleSupabaseAuthError(error),
        originalError: error,
      );
    }

    if (error is AppStorageException) {
      return AppStorageException(
        message: _handleSupabaseStorageError(error),
        originalError: error,
      );
    }

    if (error is PostgrestException) {
      return DatabaseException(
        message: _handlePostgrestError(error),
        originalError: error,
      );
    }

    return UnknownException(
      message: getUserFriendlyMessage(error),
      originalError: error,
    );
  }
}

