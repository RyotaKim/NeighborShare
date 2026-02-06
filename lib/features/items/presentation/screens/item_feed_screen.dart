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
/// Features:
/// - App bar with search icon
/// - Category filter chips (horizontal scroll)
/// - Grid view of items (2 columns)
/// - Pull-to-refresh functionality
/// - Empty state when no items
/// - Loading state
/// - FAB for adding item
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
  bool _isSearching = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create filter based on selected category and search query
    final filters = ItemsFilters(
      category: _selectedCategory,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );

    // Watch items with current filters
    final itemsAsync = ref.watch(itemsProvider(filters));

    return Scaffold(
      appBar: _isSearching ? _buildSearchBar(theme) : _buildNormalAppBar(),
      body: Column(
        children: [
          // Category Filter
          const SizedBox(height: 8),
          CategoryFilter(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            // Optional: Add item counts per category (future enhancement)
            itemCounts: null,
          ),
          const SizedBox(height: 8),

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
                        height: MediaQuery.of(context).size.height * 0.6,
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
                            // TODO: Navigate to add item screen in Phase 7
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add Item screen coming in Phase 7!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
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
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                      height: MediaQuery.of(context).size.height * 0.6,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-item');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        tooltip: 'Add a new item',
      ),
    );
  }

  /// Build normal app bar with search icon
  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('NeighborShare'),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            context.push('/conversations');
          },
          tooltip: 'Messages',
        ),
        IconButton(
          icon: const Icon(Icons.inventory_2_outlined),
          onPressed: () {
            context.push('/my-items');
          },
          tooltip: 'My Items',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          tooltip: 'Search items',
        ),
      ],
    );
  }

  /// Build search app bar
  PreferredSizeWidget _buildSearchBar(ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search items...',
          border: InputBorder.none,
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        style: theme.textTheme.titleMedium,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      actions: [
        if (_searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
            tooltip: 'Clear search',
          ),
      ],
    );
  }

  /// Build loading skeleton for grid
  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return _SkeletonCard();
      },
    );
  }
}

/// Skeleton card for loading state
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),
          
          // Info placeholder
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Owner placeholder
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
