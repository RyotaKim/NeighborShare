/// Model representing a chat conversation between two users about an item
/// Maps to the 'conversations' table with joined data from
/// 'conversation_participants', 'messages', 'items', and 'profiles'
class ConversationModel {
  final String id;
  final String itemId;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  // Item information (joined)
  final String? itemTitle;
  final String? itemImageUrl;
  final String? itemThumbnailUrl;

  // Other participant information (joined)
  final String? otherUserId;
  final String? otherUsername;
  final String? otherFullName;
  final String? otherAvatarUrl;

  // Last message preview
  final String? lastMessageContent;
  final String? lastMessageSenderId;

  // Unread count for current user
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.itemId,
    required this.createdAt,
    required this.lastMessageAt,
    this.itemTitle,
    this.itemImageUrl,
    this.itemThumbnailUrl,
    this.otherUserId,
    this.otherUsername,
    this.otherFullName,
    this.otherAvatarUrl,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  /// Create ConversationModel from JSON (from Supabase query)
  factory ConversationModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse participants to find the "other" user
    String? otherUserId;
    String? otherUsername;
    String? otherFullName;
    String? otherAvatarUrl;

    final participants = json['participants'] as List<dynamic>?;
    if (participants != null && currentUserId != null) {
      for (final p in participants) {
        final participant = p as Map<String, dynamic>;
        final userId = participant['user_id'] as String?;
        if (userId != null && userId != currentUserId) {
          otherUserId = userId;
          // Profile info might be nested
          final profile = participant['profiles'] as Map<String, dynamic>?;
          if (profile != null) {
            otherUsername = profile['username'] as String?;
            otherFullName = profile['full_name'] as String?;
            otherAvatarUrl = profile['avatar_url'] as String?;
          }
          break;
        }
      }
    }

    // Fallback: direct fields (from custom view/query)
    otherUserId ??= json['other_user_id'] as String?;
    otherUsername ??= json['other_username'] as String?;
    otherFullName ??= json['other_full_name'] as String?;
    otherAvatarUrl ??= json['other_avatar_url'] as String?;

    // Parse item info (may be nested or flat)
    String? itemTitle;
    String? itemImageUrl;
    String? itemThumbnailUrl;

    final item = json['items'] as Map<String, dynamic>?;
    if (item != null) {
      itemTitle = item['title'] as String?;
      itemImageUrl = item['image_url'] as String?;
      itemThumbnailUrl = item['thumbnail_url'] as String?;
    } else {
      itemTitle = json['item_title'] as String?;
      itemImageUrl = json['item_image_url'] as String?;
      itemThumbnailUrl = json['item_thumbnail_url'] as String?;
    }

    // Parse last message
    String? lastMessageContent;
    String? lastMessageSenderId;
    final messages = json['messages'] as List<dynamic>?;
    if (messages != null && messages.isNotEmpty) {
      final lastMsg = messages.first as Map<String, dynamic>;
      lastMessageContent = lastMsg['content'] as String?;
      lastMessageSenderId = lastMsg['sender_id'] as String?;
    } else {
      lastMessageContent = json['last_message_content'] as String?;
      lastMessageSenderId = json['last_message_sender_id'] as String?;
    }

    return ConversationModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      itemTitle: itemTitle,
      itemImageUrl: itemImageUrl,
      itemThumbnailUrl: itemThumbnailUrl,
      otherUserId: otherUserId,
      otherUsername: otherUsername,
      otherFullName: otherFullName,
      otherAvatarUrl: otherAvatarUrl,
      lastMessageContent: lastMessageContent,
      lastMessageSenderId: lastMessageSenderId,
      unreadCount: (json['unread_count'] as int?) ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
    };
  }

  /// Get the display name of the other user
  String get otherDisplayName =>
      otherFullName?.isNotEmpty == true
          ? otherFullName!
          : otherUsername ?? 'Unknown';

  /// Get the best item image URL
  String? get itemDisplayImageUrl => itemThumbnailUrl ?? itemImageUrl;

  /// Check if the last message was sent by the current user
  bool isLastMessageMine(String currentUserId) =>
      lastMessageSenderId == currentUserId;

  /// Get a preview of the last message (truncated)
  String get lastMessagePreview {
    if (lastMessageContent == null || lastMessageContent!.isEmpty) {
      return 'No messages yet';
    }
    if (lastMessageContent!.length > 50) {
      return '${lastMessageContent!.substring(0, 50)}...';
    }
    return lastMessageContent!;
  }

  /// Create a copy with updated fields
  ConversationModel copyWith({
    String? id,
    String? itemId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? itemTitle,
    String? itemImageUrl,
    String? itemThumbnailUrl,
    String? otherUserId,
    String? otherUsername,
    String? otherFullName,
    String? otherAvatarUrl,
    String? lastMessageContent,
    String? lastMessageSenderId,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      itemTitle: itemTitle ?? this.itemTitle,
      itemImageUrl: itemImageUrl ?? this.itemImageUrl,
      itemThumbnailUrl: itemThumbnailUrl ?? this.itemThumbnailUrl,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUsername: otherUsername ?? this.otherUsername,
      otherFullName: otherFullName ?? this.otherFullName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationModel{id: $id, itemId: $itemId, '
        'otherUser: $otherDisplayName, lastMessage: $lastMessagePreview}';
  }
}
