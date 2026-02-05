/// Supabase-specific constants for database tables, buckets, and views
class SupabaseConstants {
  // Table Names
  static const String profilesTable = 'profiles';
  static const String itemsTable = 'items';
  static const String conversationsTable = 'conversations';
  static const String conversationParticipantsTable = 'conversation_participants';
  static const String messagesTable = 'messages';
  
  // Storage Buckets
  static const String itemImagesBucket = 'item-images';
  static const String avatarsBucket = 'avatars';
  
  // Database Views
  static const String itemsWithOwnerView = 'items_with_owner';
  static const String conversationsWithDetailsView = 'conversations_with_details';
  
  // Storage Paths
  /// Generate storage path for item full image: {userId}/{itemId}_full.jpg
  static String itemFullImagePath(String userId, String itemId) {
    return '$userId/${itemId}_full.jpg';
  }
  
  /// Generate storage path for item thumbnail: {userId}/{itemId}_thumb.jpg
  static String itemThumbnailPath(String userId, String itemId) {
    return '$userId/${itemId}_thumb.jpg';
  }
  
  /// Generate storage path for user avatar: {userId}/avatar.jpg
  static String avatarPath(String userId) {
    return '$userId/avatar.jpg';
  }
  
  // Column Names (commonly used)
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
}
