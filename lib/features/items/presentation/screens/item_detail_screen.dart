import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';
import '../providers/my_items_provider.dart';
import '../widgets/availability_toggle.dart';

/// Item detail screen showing full item information
///
/// Features:
/// - Large item image
/// - Item title, category, status
/// - Full description
/// - Owner information section
/// - "Ask to Borrow" button (if not owner)
/// - "Edit" and availability toggle (if owner)
class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));

    return Scaffold(
      body: itemAsync.when(
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
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.session?.user.id;
    final isOwner = currentUserId == item.ownerId;

    return CustomScrollView(
      slivers: [
        // App Bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Image unavailable',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _CategoryBadge(category: item.category),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Availability Status
                    _StatusBadge(status: item.status),

                    const SizedBox(height: 24),

                    // Description
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AvailabilityToggle(
                                item: item,
                                onStatusChanged: () {
                                  // Refresh the item to show updated status
                                  ref.invalidate(itemByIdProvider(item.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Owner Information Section
                    Text(
                      isOwner ? 'Your Information' : 'Owner Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _OwnerInfoCard(item: item, isOwner: isOwner),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Category badge widget
class _CategoryBadge extends StatelessWidget {
  final ItemCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = theme_colors.CategoryColors.getColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme_colors.StatusColors.getColor(status);
    final isAvailable = status == ItemStatus.available;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          isAvailable ? 'Available to borrow' : 'Currently on loan',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Owner information card
class _OwnerInfoCard extends ConsumerWidget {
  final ItemModel item;
  final bool isOwner;

  const _OwnerInfoCard({required this.item, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get owner's item count
    final itemCountAsync = ref.watch(myItemsCountProvider(item.ownerId));

    return Card(
      child: InkWell(
        onTap: isOwner
            ? null
            : () {
                // TODO: Navigate to owner's profile/items in future phase
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View owner profile coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: item.ownerAvatarUrl != null
                    ? CachedNetworkImageProvider(item.ownerAvatarUrl!)
                    : null,
                child: item.ownerAvatarUrl == null
                    ? Text(
                        item.ownerDisplayName[0].toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Owner details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ownerDisplayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.ownerNeighborhood != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.ownerNeighborhood!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    itemCountAsync.when(
                      data: (count) => Text(
                        '${count.total} ${count.total == 1 ? 'item' : 'items'} shared',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => Text(
                        'Loading...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              if (!isOwner)
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

