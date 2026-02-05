import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import 'items_provider.dart';

/// Provider for fetching the current user's items
/// 
/// Requires authentication - returns empty list if not authenticated
final myItemsProvider = FutureProvider.autoDispose
    .family<List<ItemModel>, MyItemsFilters>((ref, filters) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id;

  if (userId == null) {
    return [];
  }

  final repository = ref.watch(itemRepositoryProvider);
  
  return repository.getMyItems(
    userId: userId,
    status: filters.status,
    limit: filters.limit,
    offset: filters.offset,
  );
});

/// Stream provider for real-time updates of current user's items
final myItemsStreamProvider = StreamProvider.autoDispose
    .family<List<ItemModel>, ItemStatus?>((ref, status) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id;

  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(itemRepositoryProvider);
  
  return repository.watchItems(
    ownerId: userId,
    status: status,
  );
});

/// Provider for counting user's items by status
final myItemsCountProvider = FutureProvider.autoDispose
    .family<MyItemsCount, String>((ref, userId) async {
  final repository = ref.watch(itemRepositoryProvider);
  
  // Fetch items with different statuses
  final allItems = await repository.getMyItems(userId: userId, limit: 1000);
  final availableItems = allItems.where((item) => item.isAvailable).length;
  final onLoanItems = allItems.where((item) => item.isOnLoan).length;
  
  return MyItemsCount(
    total: allItems.length,
    available: availableItems,
    onLoan: onLoanItems,
  );
});

/// Provider for getting current user's items count
final currentUserItemsCountProvider = FutureProvider.autoDispose<MyItemsCount>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id;

  if (userId == null) {
    return const MyItemsCount(total: 0, available: 0, onLoan: 0);
  }

  return ref.watch(myItemsCountProvider(userId).future);
});

/// Provider for checking if current user owns an item
final isMyItemProvider = Provider.autoDispose
    .family<bool, String>((ref, itemId) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id;

  if (userId == null) {
    return false;
  }

  // Watch the item and check if it belongs to the current user
  final itemAsync = ref.watch(itemByIdProvider(itemId));
  
  return itemAsync.when(
    data: (item) => item.ownerId == userId,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Filters for my items queries
class MyItemsFilters {
  final int limit;
  final int offset;
  final ItemStatus? status;

  const MyItemsFilters({
    this.limit = 100,
    this.offset = 0,
    this.status,
  });

  /// Get only available items
  factory MyItemsFilters.availableOnly() {
    return const MyItemsFilters(status: ItemStatus.available);
  }

  /// Get only items on loan
  factory MyItemsFilters.onLoanOnly() {
    return const MyItemsFilters(status: ItemStatus.onLoan);
  }

  /// Get all items
  factory MyItemsFilters.all() {
    return const MyItemsFilters();
  }

  MyItemsFilters copyWith({
    int? limit,
    int? offset,
    ItemStatus? status,
  }) {
    return MyItemsFilters(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyItemsFilters &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          status == other.status;

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode ^ status.hashCode;
}

/// Model for items count
class MyItemsCount {
  final int total;
  final int available;
  final int onLoan;

  const MyItemsCount({
    required this.total,
    required this.available,
    required this.onLoan,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyItemsCount &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          available == other.available &&
          onLoan == other.onLoan;

  @override
  int get hashCode => total.hashCode ^ available.hashCode ^ onLoan.hashCode;

  @override
  String toString() {
    return 'MyItemsCount{total: $total, available: $available, onLoan: $onLoan}';
  }
}

