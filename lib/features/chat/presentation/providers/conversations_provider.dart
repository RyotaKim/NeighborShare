import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';

/// Provider for ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Stream provider for user's conversations (real-time updates)
/// Sorted by most recent message
final conversationsStreamProvider =
    StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations();
});

/// Future provider you can manually refresh
final conversationsProvider =
    FutureProvider.autoDispose<List<ConversationModel>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getConversations();
});

/// Provider for total unread message count
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUnreadCount();
});

/// StateNotifier for conversation operations (create, find)
class ConversationNotifier extends StateNotifier<AsyncValue<ConversationModel?>> {
  final ChatRepository _repository;

  ConversationNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Find or create a conversation for an item with another user
  Future<ConversationModel> getOrCreateConversation({
    required String itemId,
    required String otherUserId,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Check for existing conversation
      var conversation = await _repository.findConversation(
        itemId: itemId,
        otherUserId: otherUserId,
      );

      // Create if not found
      conversation ??= await _repository.createConversation(
        itemId: itemId,
        otherUserId: otherUserId,
      );

      state = AsyncValue.data(conversation);
      return conversation;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for conversation operations
final conversationNotifierProvider =
    StateNotifierProvider.autoDispose<ConversationNotifier, AsyncValue<ConversationModel?>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ConversationNotifier(repository);
});
