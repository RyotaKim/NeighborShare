import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Repository for chat-related data operations
/// Handles conversations, messages, and real-time subscriptions
class ChatRepository {
  final SupabaseClient _client;

  ChatRepository() : _client = SupabaseService.client;

  /// Get the current authenticated user's ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  // ─── CONVERSATIONS ────────────────────────────────────────────────

  /// Fetch all conversations for the current user
  /// Includes item info, other participant info, and last message
  Future<List<ConversationModel>> getConversations() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: 'User not authenticated');
    }

    try {
      // Get conversation IDs where user is a participant
      final participantRows = await _client
          .from(SupabaseConstants.conversationParticipantsTable)
          .select('conversation_id')
          .eq('user_id', userId);

      final conversationIds = (participantRows as List)
          .map((row) => row['conversation_id'] as String)
          .toList();

      if (conversationIds.isEmpty) {
        return [];
      }

      // Fetch conversations with item info and participants
      final response = await _client
          .from(SupabaseConstants.conversationsTable)
          .select('''
            *,
            items!conversations_item_id_fkey (
              id, title, image_url, thumbnail_url
            ),
            conversation_participants (
              user_id,
              profiles (
                id, username, full_name, avatar_url
              )
            )
          ''')
          .inFilter('id', conversationIds)
          .order('last_message_at', ascending: false);

      final conversations = <ConversationModel>[];
      for (final json in (response as List)) {
        final conv = ConversationModel.fromJson(
          json as Map<String, dynamic>,
          currentUserId: userId,
        );
        conversations.add(conv);
      }

      // Fetch last message for each conversation
      final enrichedConversations = <ConversationModel>[];
      for (final conv in conversations) {
        final msgResponse = await _client
            .from(SupabaseConstants.messagesTable)
            .select('content, sender_id')
            .eq('conversation_id', conv.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (msgResponse != null) {
          enrichedConversations.add(conv.copyWith(
            lastMessageContent: msgResponse['content'] as String?,
            lastMessageSenderId: msgResponse['sender_id'] as String?,
          ));
        } else {
          enrichedConversations.add(conv);
        }
      }

      return enrichedConversations;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch conversations: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch conversations',
        originalError: e,
      );
    }
  }

  /// Find an existing conversation between current user and another user about an item
  Future<ConversationModel?> findConversation({
    required String itemId,
    required String otherUserId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: 'User not authenticated');
    }

    try {
      // Find conversations for this item where both users are participants
      final response = await _client
          .from(SupabaseConstants.conversationsTable)
          .select('''
            *,
            items!conversations_item_id_fkey (
              id, title, image_url, thumbnail_url
            ),
            conversation_participants (
              user_id,
              profiles (
                id, username, full_name, avatar_url
              )
            )
          ''')
          .eq('item_id', itemId);

      for (final json in (response as List)) {
        final conv = json as Map<String, dynamic>;
        final participants =
            conv['conversation_participants'] as List<dynamic>?;
        if (participants != null) {
          final userIds = participants
              .map((p) => (p as Map<String, dynamic>)['user_id'] as String)
              .toSet();
          if (userIds.contains(userId) && userIds.contains(otherUserId)) {
            return ConversationModel.fromJson(conv, currentUserId: userId);
          }
        }
      }

      return null;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to find conversation: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to find conversation',
        originalError: e,
      );
    }
  }

  /// Create a new conversation between two users about an item
  Future<ConversationModel> createConversation({
    required String itemId,
    required String otherUserId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: 'User not authenticated');
    }

    try {
      // Check if conversation already exists
      final existing = await findConversation(
        itemId: itemId,
        otherUserId: otherUserId,
      );
      if (existing != null) return existing;

      // Create the conversation
      final convResponse = await _client
          .from(SupabaseConstants.conversationsTable)
          .insert({
            'item_id': itemId,
          })
          .select()
          .single();

      final conversationId = convResponse['id'] as String;

      // Add both users as participants
      await _client.from(SupabaseConstants.conversationParticipantsTable).insert([
        {
          'conversation_id': conversationId,
          'user_id': userId,
        },
        {
          'conversation_id': conversationId,
          'user_id': otherUserId,
        },
      ]);

      // Fetch the full conversation with relations
      final fullResponse = await _client
          .from(SupabaseConstants.conversationsTable)
          .select('''
            *,
            items!conversations_item_id_fkey (
              id, title, image_url, thumbnail_url
            ),
            conversation_participants (
              user_id,
              profiles (
                id, username, full_name, avatar_url
              )
            )
          ''')
          .eq('id', conversationId)
          .single();

      return ConversationModel.fromJson(
        fullResponse,
        currentUserId: userId,
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to create conversation: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to create conversation',
        originalError: e,
      );
    }
  }

  // ─── MESSAGES ─────────────────────────────────────────────────────

  /// Fetch messages for a conversation (paginated)
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from(SupabaseConstants.messagesTable)
          .select('''
            *,
            profiles!messages_sender_id_fkey (
              username, full_name, avatar_url
            )
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch messages: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch messages',
        originalError: e,
      );
    }
  }

  /// Send a message in a conversation
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: 'User not authenticated');
    }

    if (content.trim().isEmpty) {
      throw const DatabaseException(
        message: 'Message content cannot be empty',
        code: 'empty_message',
      );
    }

    try {
      // Insert message
      final response = await _client
          .from(SupabaseConstants.messagesTable)
          .insert({
            'conversation_id': conversationId,
            'sender_id': userId,
            'content': content.trim(),
          })
          .select('''
            *,
            profiles!messages_sender_id_fkey (
              username, full_name, avatar_url
            )
          ''')
          .single();

      // Update conversation's last_message_at
      await _client
          .from(SupabaseConstants.conversationsTable)
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);

      return MessageModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to send message: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to send message',
        originalError: e,
      );
    }
  }

  // ─── REAL-TIME SUBSCRIPTIONS ──────────────────────────────────────

  /// Subscribe to new messages in a conversation (real-time)
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    final controller = StreamController<List<MessageModel>>();
    List<MessageModel> messages = [];

    // Initial fetch
    getMessages(conversationId: conversationId).then((initial) {
      messages = initial;
      if (!controller.isClosed) {
        controller.add(List.from(messages));
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // Subscribe to real-time inserts
    final channel = _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            try {
              // Fetch the full message with profile info
              final response = await _client
                  .from(SupabaseConstants.messagesTable)
                  .select('''
                    *,
                    profiles!messages_sender_id_fkey (
                      username, full_name, avatar_url
                    )
                  ''')
                  .eq('id', payload.newRecord['id'] as String)
                  .single();

              final newMessage = MessageModel.fromJson(response);

              // Avoid duplicates
              if (!messages.any((m) => m.id == newMessage.id)) {
                messages.add(newMessage);
                if (!controller.isClosed) {
                  controller.add(List.from(messages));
                }
              }
            } catch (e) {
              // Silently handle fetch errors for individual messages
              print('Failed to fetch new message details: $e');
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }

  /// Subscribe to conversation updates (new messages, etc.)
  Stream<List<ConversationModel>> watchConversations() {
    final controller = StreamController<List<ConversationModel>>();

    // Initial fetch
    getConversations().then((initial) {
      if (!controller.isClosed) {
        controller.add(initial);
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // Periodically refresh conversations (every 10 seconds)
    // Real-time subscription for conversations is complex with joins,
    // so we use polling as a simple approach
    final timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!controller.isClosed) {
        getConversations().then((conversations) {
          if (!controller.isClosed) {
            controller.add(conversations);
          }
        }).catchError((e) {
          // Silently handle refresh errors
          print('Failed to refresh conversations: $e');
        });
      }
    });

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // ─── UNREAD COUNT ─────────────────────────────────────────────────

  /// Get total unread message count across all conversations
  /// For now, returns 0 as we don't track read status yet
  /// This can be enhanced with a read_at column in conversation_participants
  Future<int> getUnreadCount() async {
    // TODO: Implement proper unread tracking with read_at timestamps
    return 0;
  }
}
