import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/conversations_provider.dart';
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';
import '../providers/my_items_provider.dart';
import '../widgets/availability_toggle.dart';

/// Item detail screen matching the mockup:
/// - Full-width image with owner avatar overlay
/// - Large bold title
/// - Status pill badge (Available / On Loan) with icon
/// - Owner info: avatar + "Owner: Name" + "Neighborhood: Location"
/// - Description section
/// - Full-width green "Chat to Borrow" button at bottom
class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));

    return itemAsync.when(
      data: (item) => _ItemDetailContent(item: item),
      loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ErrorDisplay(
            message: 'Failed to load item',
            onRetry: () => ref.invalidate(itemByIdProvider(itemId)),
          ),
        ),
      ),
    );
  }
}

/// Content widget for item detail
class _ItemDetailContent extends ConsumerWidget {
  final ItemModel item;

  const _ItemDetailContent({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(authenticatedUserProvider);
    final currentUserId = currentUser?.id;
    final isOwner = currentUserId == item.ownerId;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image with back button and owner avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Item image
                      SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),

                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 12,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      // Owner avatar overlay (bottom-left of image)
                      Positioned(
                        bottom: -24,
                        left: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: item.ownerAvatarUrl != null
                                ? CachedNetworkImageProvider(
                                    item.ownerAvatarUrl!)
                                : null,
                            child: item.ownerAvatarUrl == null
                                ? Text(
                                    item.ownerDisplayName[0].toUpperCase(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Status badge
                        _StatusPill(status: item.status),

                        const SizedBox(height: 20),

                        // Owner info row
                        _OwnerInfoRow(item: item, isOwner: isOwner),

                        const SizedBox(height: 24),

                        // Description
                        if (item.description != null &&
                            item.description!.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Availability Toggle (Owner Only)
                        if (isOwner) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Availability',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AvailabilityToggle(
                                    item: item,
                                    onStatusChanged: () {
                                      ref.invalidate(
                                          itemByIdProvider(item.id));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom "Chat to Borrow" button
          if (!isOwner && item.isAvailable && currentUserId != null)
            _ChatToBorrowButton(
              item: item,
              currentUserId: currentUserId,
            ),
        ],
      ),
    );
  }
}

/// Green status pill badge with icon
class _StatusPill extends StatelessWidget {
  final ItemStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = theme_colors.StatusColors.getColor(status);
    final isAvailable = status == ItemStatus.available;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isAvailable ? 'Available' : 'On Loan',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isAvailable ? Icons.verified_outlined : Icons.lock_outline,
            size: 16,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Owner info row with avatar, name, and neighborhood
class _OwnerInfoRow extends ConsumerWidget {
  final ItemModel item;
  final bool isOwner;

  const _OwnerInfoRow({required this.item, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isOwner
          ? null
          : () {
              context.push('/profile/${item.ownerId}');
            },
      child: Row(
        children: [
          // Owner avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: item.ownerAvatarUrl != null
                ? CachedNetworkImageProvider(item.ownerAvatarUrl!)
                : null,
            child: item.ownerAvatarUrl == null
                ? Text(
                    item.ownerDisplayName[0].toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Owner details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Owner: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: item.ownerDisplayName,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.ownerNeighborhood != null) ...[
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'Neighborhood: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: item.ownerNeighborhood!,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Chat to Borrow" bottom button
class _ChatToBorrowButton extends ConsumerStatefulWidget {
  final ItemModel item;
  final String currentUserId;

  const _ChatToBorrowButton({
    required this.item,
    required this.currentUserId,
  });

  @override
  ConsumerState<_ChatToBorrowButton> createState() =>
      _ChatToBorrowButtonState();
}

class _ChatToBorrowButtonState extends ConsumerState<_ChatToBorrowButton> {
  bool _isLoading = false;

  Future<void> _chatToBorrow() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final conversation = await ref
          .read(conversationNotifierProvider.notifier)
          .getOrCreateConversation(
            itemId: widget.item.id,
            otherUserId: widget.item.ownerId,
          );

      if (mounted) {
        context.push('/chat/${conversation.id}', extra: conversation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start conversation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _chatToBorrow,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.chat_bubble_rounded, size: 20),
            label: Text(
              _isLoading ? 'Starting chat...' : 'Chat to Borrow',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
