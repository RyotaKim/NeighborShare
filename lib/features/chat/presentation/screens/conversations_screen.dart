import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/conversations_provider.dart';
import '../widgets/conversation_tile.dart';

/// Conversations list screen (Messages inbox)
///
/// Features:
/// - List of all conversations sorted by most recent
/// - Each tile shows item thumbnail, other user, last message, timestamp
/// - Pull-to-refresh
/// - Empty state when no conversations
/// - Tap to open chat
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final currentUser = ref.watch(authenticatedUserProvider);
    final currentUserId = currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(conversationsStreamProvider);
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const EmptyState(
                      title: 'No conversations yet',
                      description:
                          'Start a conversation by tapping "Ask to Borrow" on any item.',
                      icon: Icons.chat_bubble_outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationsStreamProvider);
            },
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 84,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  currentUserId: currentUserId,
                  onTap: () {
                    context.push(
                      '/chat/${conversation.id}',
                      extra: conversation,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: ErrorDisplay(
            message: 'Failed to load conversations',
            onRetry: () => ref.invalidate(conversationsStreamProvider),
          ),
        ),
      ),
    );
  }
}
