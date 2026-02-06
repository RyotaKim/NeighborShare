/// Model representing a chat message
/// Maps to the 'messages' table in Supabase
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  // Sender information (joined from profiles)
  final String? senderUsername;
  final String? senderFullName;
  final String? senderAvatarUrl;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderUsername,
    this.senderFullName,
    this.senderAvatarUrl,
  });

  /// Create MessageModel from JSON (from Supabase query)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Sender profile info might be nested
    String? senderUsername;
    String? senderFullName;
    String? senderAvatarUrl;

    final profile = json['profiles'] as Map<String, dynamic>?;
    if (profile != null) {
      senderUsername = profile['username'] as String?;
      senderFullName = profile['full_name'] as String?;
      senderAvatarUrl = profile['avatar_url'] as String?;
    } else {
      senderUsername = json['sender_username'] as String?;
      senderFullName = json['sender_full_name'] as String?;
      senderAvatarUrl = json['sender_avatar_url'] as String?;
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: senderUsername,
      senderFullName: senderFullName,
      senderAvatarUrl: senderAvatarUrl,
    );
  }

  /// Convert to JSON for creating a new message
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
    };
  }

  /// Get sender display name
  String get senderDisplayName =>
      senderFullName?.isNotEmpty == true
          ? senderFullName!
          : senderUsername ?? 'Unknown';

  /// Check if this message was sent by the given user
  bool isSentBy(String userId) => senderId == userId;

  /// Format the timestamp for display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  /// Format time as HH:MM
  String get timeOfDay {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    String? senderUsername,
    String? senderFullName,
    String? senderAvatarUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderUsername: senderUsername ?? this.senderUsername,
      senderFullName: senderFullName ?? this.senderFullName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $senderDisplayName, '
        'content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content}}';
  }
}
