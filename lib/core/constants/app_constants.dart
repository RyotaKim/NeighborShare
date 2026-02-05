/// Application-wide constants for NeighborShare
class AppConstants {
  // App Information
  static const String appName = 'NeighborShare';
  static const String appVersion = '1.0.0';
  
  // Text Length Limits
  static const int maxTitleLength = 60;
  static const int minTitleLength = 3;
  static const int maxDescriptionLength = 500;
  static const int maxBioLength = 500;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 8;
  static const int maxMessageLength = 1000;
  
  // Image Size Limits (in bytes)
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxAvatarSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int thumbnailSize = 300; // 300x300 pixels
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int messagesPerPage = 50;
  static const int conversationsPerPage = 30;
  
  // Delays & Timeouts
  static const int searchDebounceMs = 300; // Milliseconds
  static const int resendEmailCooldownSeconds = 30;
  
  // Image Quality
  static const int imageCompressionQuality = 85; // 0-100
  static const int thumbnailCompressionQuality = 80;
  
  // Session
  static const int jwtExpirySeconds = 3600; // 1 hour
  static const int inactivityLogoutDays = 30;
}
