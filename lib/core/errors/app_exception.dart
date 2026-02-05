/// Base class for all application exceptions
/// Provides a consistent structure for error handling across the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Authentication-related exceptions
/// Used for login, signup, password reset, and session errors
class AppAuthException extends AppException {
  const AppAuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Named constructors for common auth errors
  const AppAuthException.invalidCredentials()
      : super(
          message: 'Invalid email or password',
          code: 'invalid_credentials',
        );

  const AppAuthException.emailAlreadyInUse()
      : super(
          message: 'This email is already registered',
          code: 'email_already_in_use',
        );

  const AppAuthException.weakPassword()
      : super(
          message: 'Password is too weak. Use at least 8 characters with letters and numbers',
          code: 'weak_password',
        );

  const AppAuthException.userNotFound()
      : super(
          message: 'No user found with this email',
          code: 'user_not_found',
        );

  const AppAuthException.invalidEmail()
      : super(
          message: 'Please enter a valid email address',
          code: 'invalid_email',
        );

  const AppAuthException.emailNotVerified()
      : super(
          message: 'Please verify your email before continuing',
          code: 'email_not_verified',
        );

  const AppAuthException.sessionExpired()
      : super(
          message: 'Your session has expired. Please log in again',
          code: 'session_expired',
        );

  const AppAuthException.tooManyRequests()
      : super(
          message: 'Too many attempts. Please try again later',
          code: 'too_many_requests',
        );

  @override
  String toString() => 'AppAuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Storage-related exceptions
/// Used for file upload, download, and deletion errors
class AppStorageException extends AppException {
  const AppStorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Named constructors for common storage errors
  const AppStorageException.uploadFailed()
      : super(
          message: 'Failed to upload file. Please try again',
          code: 'upload_failed',
        );

  const AppStorageException.downloadFailed()
      : super(
          message: 'Failed to download file. Please try again',
          code: 'download_failed',
        );

  const AppStorageException.deleteFailed()
      : super(
          message: 'Failed to delete file. Please try again',
          code: 'delete_failed',
        );

  const AppStorageException.fileNotFound()
      : super(
          message: 'File not found',
          code: 'file_not_found',
        );

  const AppStorageException.fileTooLarge()
      : super(
          message: 'File is too large. Maximum size is 5MB',
          code: 'file_too_large',
        );

  const AppStorageException.invalidFileType()
      : super(
          message: 'Invalid file type. Please select an image file',
          code: 'invalid_file_type',
        );

  const AppStorageException.insufficientPermissions()
      : super(
          message: 'You do not have permission to access this file',
          code: 'insufficient_permissions',
        );

  const AppStorageException.bucketNotFound()
      : super(
          message: 'Storage bucket not found',
          code: 'bucket_not_found',
        );

  @override
  String toString() => 'AppStorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related exceptions
/// Used for connectivity and API request errors
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Named constructors for common network errors
  const NetworkException.noConnection()
      : super(
          message: 'No internet connection. Please check your network',
          code: 'no_connection',
        );

  const NetworkException.timeout()
      : super(
          message: 'Request timed out. Please try again',
          code: 'timeout',
        );

  const NetworkException.serverError()
      : super(
          message: 'Server error. Please try again later',
          code: 'server_error',
        );

  const NetworkException.badRequest()
      : super(
          message: 'Invalid request. Please try again',
          code: 'bad_request',
        );

  const NetworkException.unauthorized()
      : super(
          message: 'Unauthorized. Please log in again',
          code: 'unauthorized',
        );

  const NetworkException.forbidden()
      : super(
          message: 'You do not have permission to perform this action',
          code: 'forbidden',
        );

  const NetworkException.notFound()
      : super(
          message: 'Resource not found',
          code: 'not_found',
        );

  const NetworkException.conflict()
      : super(
          message: 'A conflict occurred. Please refresh and try again',
          code: 'conflict',
        );

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Database-related exceptions
/// Used for CRUD operation errors
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Named constructors for common database errors
  const DatabaseException.createFailed()
      : super(
          message: 'Failed to create record. Please try again',
          code: 'create_failed',
        );

  const DatabaseException.updateFailed()
      : super(
          message: 'Failed to update record. Please try again',
          code: 'update_failed',
        );

  const DatabaseException.deleteFailed()
      : super(
          message: 'Failed to delete record. Please try again',
          code: 'delete_failed',
        );

  const DatabaseException.fetchFailed()
      : super(
          message: 'Failed to fetch data. Please try again',
          code: 'fetch_failed',
        );

  const DatabaseException.notFound()
      : super(
          message: 'Record not found',
          code: 'not_found',
        );

  const DatabaseException.duplicateEntry()
      : super(
          message: 'This entry already exists',
          code: 'duplicate_entry',
        );

  @override
  String toString() => 'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Validation exceptions
/// Used for form and input validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  const ValidationException.invalidInput(String field)
      : fieldErrors = null,
        super(
          message: 'Invalid $field',
          code: 'invalid_input',
        );

  const ValidationException.requiredField(String field)
      : fieldErrors = null,
        super(
          message: '$field is required',
          code: 'required_field',
        );

  @override
  String toString() => 'ValidationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Unknown or unexpected exceptions
/// Fallback for unhandled errors
class UnknownException extends AppException {
  const UnknownException({
    String message = 'An unexpected error occurred',
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(message: message);

  @override
  String toString() => 'UnknownException: $message';
}
