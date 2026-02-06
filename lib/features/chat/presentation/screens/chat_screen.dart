import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/conversation_model.dart';
import '../providers/messages_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

/// Chat screen for a specific conversation
///
/// Features:
/// - App bar with item thumbnail and title
/// - Real-time message stream
/// - Message bubbles (sent/received)
/// - Chat input with send button
/// - Auto-scroll to bottom on new messages
/// - Keyboard handling
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final ConversationModel? conversation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // If user scrolls up significantly, don't auto-scroll
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        _shouldAutoScroll = (maxScroll - currentScroll) < 100;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients && _shouldAutoScroll) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          if (animated) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(authenticatedUserProvider);
    final currentUserId = currentUser?.id ?? '';
    final messagesAsync = ref.watch(messagesStreamProvider(widget.conversationId));
    final sendState = ref.watch(sendMessageProvider);
    final isSending = sendState is AsyncLoading;

    // Get conversation info
    final conversation = widget.conversation;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // Item thumbnail
            if (conversation?.itemDisplayImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: conversation!.itemDisplayImageUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 36,
                    height: 36,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Title and user info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation?.itemTitle ?? 'Chat',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation != null)
                    Text(
                      conversation.otherDisplayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start the conversation!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Say hello and ask about this item.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Schedule scroll to bottom after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(animated: false);
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.isSentBy(currentUserId);

                    // Show avatar only for first message in a consecutive group
                    final showAvatar = !isMine &&
                        (index == 0 ||
                            messages[index - 1].senderId != message.senderId);

                    // Show timestamp for last message in a consecutive group
                    final showTimestamp = index == messages.length - 1 ||
                        messages[index + 1].senderId != message.senderId;

                    return MessageBubble(
                      message: message,
                      isMine: isMine,
                      showAvatar: showAvatar,
                      showTimestamp: showTimestamp,
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => Center(
                child: ErrorDisplay(
                  message: 'Failed to load messages',
                  onRetry: () =>
                      ref.invalidate(messagesStreamProvider(widget.conversationId)),
                ),
              ),
            ),
          ),

          // Chat input
          ChatInput(
            isSending: isSending,
            onSend: (content) async {
              await ref.read(sendMessageProvider.notifier).sendMessage(
                    conversationId: widget.conversationId,
                    content: content,
                  );
              _shouldAutoScroll = true;
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
