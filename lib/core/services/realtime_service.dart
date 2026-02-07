import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../constants/supabase_constants.dart';

/// Service for managing real-time subscriptions
/// Handles live updates for items, messages, and conversations
class RealtimeService {
  final SupabaseClient _supabase;
  
  RealtimeService() : _supabase = SupabaseService.client;
  
  /// Subscribe to items table changes
  /// Returns a stream of all items, updated in real-time
  Stream<List<Map<String, dynamic>>> subscribeToItems({
    String? category,
    String? status,
  }) {
    try {
      var query = _supabase
          .from(SupabaseConstants.itemsTable)
          .stream(primaryKey: ['id']);
      
      // Apply filters if provided
      // Note: Filters should be applied in the initial query, not in stream
      // The stream will update based on changes to matching records
      
      return query;
    } catch (e) {
      print('[Realtime] Failed to subscribe to items: $e');
      rethrow;
    }
  }
  
  /// Subscribe to messages in a specific conversation
  /// Returns a stream of messages, updated in real-time
  Stream<List<Map<String, dynamic>>> subscribeToMessages({
    required String conversationId,
  }) {
    try {
      return _supabase
          .from(SupabaseConstants.messagesTable)
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
    } catch (e) {
      print('[Realtime] Failed to subscribe to messages: $e');
      rethrow;
    }
  }
  
  /// Subscribe to conversations for a specific user
  /// Returns a stream of conversations, updated in real-time
  Stream<List<Map<String, dynamic>>> subscribeToConversations({
    required String userId,
  }) {
    try {
      // First, get conversation IDs where user is a participant
      // Then subscribe to those conversations
      // Note: This requires a more complex query with joins
      // For now, we'll subscribe to all conversations and filter in the app
      
      return _supabase
          .from(SupabaseConstants.conversationsTable)
          .stream(primaryKey: ['id'])
          .order('last_message_at', ascending: false);
    } catch (e) {
      print('[Realtime] Failed to subscribe to conversations: $e');
      rethrow;
    }
  }
  
  /// Subscribe to a specific item by ID
  /// Returns a stream with real-time updates for that item
  Stream<List<Map<String, dynamic>>> subscribeToItem({
    required String itemId,
  }) {
    try {
      return _supabase
          .from(SupabaseConstants.itemsTable)
          .stream(primaryKey: ['id'])
          .eq('id', itemId);
    } catch (e) {
      print('[Realtime] Failed to subscribe to item: $e');
      rethrow;
    }
  }
  
  /// Subscribe to items by a specific user
  /// Returns a stream of items owned by the user
  Stream<List<Map<String, dynamic>>> subscribeToUserItems({
    required String userId,
  }) {
    try {
      return _supabase
          .from(SupabaseConstants.itemsTable)
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('[Realtime] Failed to subscribe to user items: $e');
      rethrow;
    }
  }
  
  /// Subscribe to conversation participants
  /// Useful for tracking who's in a conversation
  Stream<List<Map<String, dynamic>>> subscribeToConversationParticipants({
    required String conversationId,
  }) {
    try {
      return _supabase
          .from(SupabaseConstants.conversationParticipantsTable)
          .stream(primaryKey: ['conversation_id', 'user_id'])
          .eq('conversation_id', conversationId);
    } catch (e) {
      print('[Realtime] Failed to subscribe to conversation participants: $e');
      rethrow;
    }
  }
  
  /// Unsubscribe from all active channels
  /// Call this when disposing of widgets or cleaning up
  Future<void> unsubscribeAll() async {
    try {
      await _supabase.removeAllChannels();
    } catch (e) {
      print('[Realtime] Failed to unsubscribe from channels: $e');
      rethrow;
    }
  }
}
