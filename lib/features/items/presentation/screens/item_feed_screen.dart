import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/items_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/category_filter.dart';

/// Main feed screen showing browsable items
///
/// Layout matches mockup:
/// - App bar: "NeighborShare" title + profile icon
/// - Persistent search bar below app bar
/// - Circular category filter icons (Tools, Kitchen, Outdoor, Games)
/// - 2-column item grid with rounded cards
/// - Circular FAB (+) at bottom-right
class ItemFeedScreen extends ConsumerStatefulWidget {
  const ItemFeedScreen({super.key});

  @override
  ConsumerState<ItemFeedScreen> createState() => _ItemFeedScreenState();
}

class _ItemFeedScreenState extends ConsumerState<ItemFeedScreen> {
  ItemCategory? _selectedCategory;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Create filter based on selected category and search query
    final filters = ItemsFilters(
      category: _selectedCategory,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );

    // Watch items with current filters
    final itemsAsync = ref.watch(itemsProvider(filters));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'NeighborShare',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          // Profile icon
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for items...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: false,
                ),
                style: theme.textTheme.bodyMedium,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Category Filter (circular icons)
          CategoryFilter(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemCounts: null,
          ),

          const SizedBox(height: 4),

          // Items Grid
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                // Empty State
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(itemsProvider(filters));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: _selectedCategory == null
                              ? 'No items yet'
                              : 'No ${_selectedCategory!.label.toLowerCase()} items',
                          description: _selectedCategory == null
                              ? 'Be the first to share an item with your neighbors!'
                              : 'Try selecting a different category or add your own items.',
                          actionButtonText: 'Add Item',
                          onActionPressed: () {
                            context.push('/add-item');
                          },
                        ),
                      ),
                    ),
                  );
                }

                // Items Grid
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(itemsProvider(filters));
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        item: item,
                        onTap: () {
                          context.push('/item/${item.id}');
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => _buildLoadingSkeleton(),
              error: (error, stack) {
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(itemsProvider(filters));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ErrorDisplay(
                        message: 'Failed to load items',
                        onRetry: () {
                          ref.invalidate(itemsProvider(filters));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-item');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// Build loading skeleton for grid
  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const _SkeletonCard();
      },
    );
  }
}

/// Skeleton card for loading state
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Info placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
