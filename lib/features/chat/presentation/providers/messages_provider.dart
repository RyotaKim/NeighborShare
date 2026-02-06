import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'conversations_provider.dart';

/// Stream provider for messages in a conversation (real-time)
/// Messages are sorted chronologically (oldest first)
final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(conversationId);
});

/// Future provider for fetching messages (non-realtime, for initial load)
final messagesProvider = FutureProvider.autoDispose
    .family<List<MessageModel>, String>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(conversationId: conversationId);
});

/// StateNotifier for sending messages
class SendMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;

  SendMessageNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Send a message to a conversation
  Future<MessageModel?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      state = const AsyncValue.loading();

      final message = await _repository.sendMessage(
        conversationId: conversationId,
        content: content,
      );

      state = const AsyncValue.data(null);
      return message;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}

/// Provider for sending messages
final sendMessageProvider =
    StateNotifierProvider.autoDispose<SendMessageNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessageNotifier(repository);
});
