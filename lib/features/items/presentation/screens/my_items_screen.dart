import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';
import '../providers/my_items_provider.dart';
import '../widgets/availability_toggle.dart';

/// Screen displaying all items owned by the current user
/// 
/// Features:
/// - List of user's items with status indicators
/// - Quick availability toggle on each item
/// - Swipe actions for edit and delete
/// - Filter by status (All, Available, On Loan)
/// - Empty state when no items
class MyItemsScreen extends ConsumerStatefulWidget {
  const MyItemsScreen({super.key});

  @override
  ConsumerState<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends ConsumerState<MyItemsScreen> {
  ItemStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(myItemsStreamProvider(_selectedFilter));

    return Scaffold(
      appBar: const BackAppBar(title: 'My Items'),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Items list
          Expanded(
            child: itemsAsync.when(
              data: (items) => items.isEmpty
                  ? _buildEmptyState()
                  : _buildItemsList(items),
              loading: () => const LoadingIndicator(message: 'Loading your items...'),
              error: (error, stack) => ErrorDisplay(
                message: 'Failed to load your items',
                onRetry: () => ref.invalidate(myItemsStreamProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Available',
            isSelected: _selectedFilter == ItemStatus.available,
            color: theme_colors.AppColors.available,
            onTap: () => setState(() => _selectedFilter = ItemStatus.available),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'On Loan',
            isSelected: _selectedFilter == ItemStatus.onLoan,
            color: theme_colors.AppColors.onLoan,
            onTap: () => setState(() => _selectedFilter = ItemStatus.onLoan),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_selectedFilter != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedFilter == ItemStatus.available ? 'available' : 'on loan'} items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing the filter to see all your items',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _selectedFilter = null),
              child: const Text('Show All'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No items yet',
            description: 'Share your first item with the community!',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/add-item'),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<ItemModel> items) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myItemsStreamProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MyItemCard(
            item: item,
            onDeleted: () => ref.invalidate(myItemsStreamProvider),
          );
        },
      ),
    );
  }
}

/// Individual item card for My Items screen
class _MyItemCard extends ConsumerWidget {
  final ItemModel item;
  final VoidCallback? onDeleted;

  const _MyItemCard({
    required this.item,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit action
          context.push('/edit-item/${item.id}');
          return false;
        } else {
          // Delete action
          return await _showDeleteDialog(context);
        }
      },
      onDismissed: (direction) async {
        // Delete the item
        final success = await ref
            .read(itemNotifierProvider.notifier)
            .deleteItem(item.id);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
            onDeleted?.call();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to delete item'),
                backgroundColor: theme_colors.AppColors.error,
              ),
            );
          }
        }
      },
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: theme_colors.AppColors.primary,
        icon: Icons.edit,
        label: 'Edit',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: theme_colors.AppColors.error,
        icon: Icons.delete,
        label: 'Delete',
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/items/${item.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.thumbnailUrl ?? item.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Item details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with status badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(status: item.status),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Category
                          Row(
                            children: [
                              Text(
                                item.category.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.category.label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme_colors.CategoryColors.getColor(item.category),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Edit and Delete buttons (compact)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/edit-item/${item.id}'),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(0, 36),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleDelete(context, ref),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme_colors.AppColors.error,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(0, 36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Availability toggle
                CompactAvailabilityToggle(
                  item: item,
                  onStatusChanged: onDeleted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteDialog(context);
    if (!confirmed) return;

    final success = await ref
        .read(itemNotifierProvider.notifier)
        .deleteItem(item.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        onDeleted?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete item'),
            backgroundColor: theme_colors.AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme_colors.AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

/// Status badge showing availability
class _StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = status == ItemStatus.available;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Available' : 'On Loan',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip for status selection
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : theme.colorScheme.outline,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}
