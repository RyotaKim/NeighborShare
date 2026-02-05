import '../constants/app_constants.dart';

/// Input validation utilities
/// Provides validation functions for forms and user input
class Validators {
  /// Validate email address format
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validate password confirmation matches
  /// Returns null if valid, error message if invalid
  static String? validatePasswordConfirm(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validate username format and length
  /// Returns null if valid, error message if invalid
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    
    if (value.length > AppConstants.maxUsernameLength) {
      return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
    }
    
    // Username can only contain letters, numbers, and underscores
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    // Username cannot start with a number
    if (RegExp(r'^[0-9]').hasMatch(value)) {
      return 'Username cannot start with a number';
    }
    
    return null;
  }
  
  /// Validate item title
  /// Returns null if valid, error message if invalid
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < AppConstants.minTitleLength) {
      return 'Title must be at least ${AppConstants.minTitleLength} characters';
    }
    
    if (trimmed.length > AppConstants.maxTitleLength) {
      return 'Title must be less than ${AppConstants.maxTitleLength} characters';
    }
    
    return null;
  }
  
  /// Validate description (optional field)
  /// Returns null if valid, error message if invalid
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Description is optional
    }
    
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    
    return null;
  }
  
  /// Validate bio (optional field)
  /// Returns null if valid, error message if invalid
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    
    if (value.length > AppConstants.maxBioLength) {
      return 'Bio must be less than ${AppConstants.maxBioLength} characters';
    }
    
    return null;
  }
  
  /// Validate message content
  /// Returns null if valid, error message if invalid
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (trimmed.length > AppConstants.maxMessageLength) {
      return 'Message must be less than ${AppConstants.maxMessageLength} characters';
    }
    
    return null;
  }
  
  /// Validate required text field
  /// Generic validator for any required text field
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    return null;
  }
  
  /// Validate required text field (single parameter version for TextFormField)
  /// Returns a validator function that can be used directly with TextFormField
  static String? Function(String?) requiredValidator(String fieldName) {
    return (value) => validateRequired(value, fieldName);
  }
  
  /// Check if string is a valid URL
  static bool isValidUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    
    try {
      final uri = Uri.parse(value);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
