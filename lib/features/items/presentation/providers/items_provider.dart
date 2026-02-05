import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/item_repository.dart';

/// Provider for ItemRepository
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for fetching all items with optional filters
/// 
/// Returns a FutureProvider that fetches items from the repository
final itemsProvider = FutureProvider.autoDispose
    .family<List<ItemModel>, ItemsFilters>((ref, filters) async {
  final repository = ref.watch(itemRepositoryProvider);
  
  return repository.fetchItems(
    limit: filters.limit,
    offset: filters.offset,
    category: filters.category,
    status: filters.status,
    searchQuery: filters.searchQuery,
  );
});

/// Stream provider for real-time item updates
/// 
/// Note: Currently uses polling. For true real-time, implement
/// Supabase Realtime subscriptions in the repository
final itemsStreamProvider = StreamProvider.autoDispose
    .family<List<ItemModel>, ItemsFilters>((ref, filters) {
  final repository = ref.watch(itemRepositoryProvider);
  
  return repository.watchItems(
    category: filters.category,
    status: filters.status,
  );
});

/// Provider for fetching a single item by ID
final itemByIdProvider = FutureProvider.autoDispose
    .family<ItemModel, String>((ref, itemId) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getItemById(itemId);
});

/// Provider for searching items
final itemSearchProvider = FutureProvider.autoDispose
    .family<List<ItemModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(itemRepositoryProvider);
  return repository.searchItems(query);
});

/// Provider for items by category
final itemsByCategoryProvider = FutureProvider.autoDispose
    .family<List<ItemModel>, ItemCategory>((ref, category) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getItemsByCategory(category);
});

/// State notifier for managing item operations (create, update, delete)
class ItemNotifier extends StateNotifier<AsyncValue<ItemModel?>> {
  final ItemRepository _repository;
  final StorageService _storageService;
  final String? _userId;

  ItemNotifier(
    this._repository,
    this._storageService,
    this._userId,
  ) : super(const AsyncValue.data(null));

  /// Create a new item with image upload
  Future<ItemModel?> createItem({
    required String title,
    required ItemCategory category,
    String? description,
    required File fullImage,
    required File thumbnail,
  }) async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('User not authenticated'),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncValue.loading();
    
    try {
      // Generate unique item ID
      final itemId = const Uuid().v4();
      
      // Upload images to storage
      final urls = await _storageService.uploadItemImage(
        userId: _userId,
        itemId: itemId,
        fullImage: fullImage,
        thumbnail: thumbnail,
      );
      
      // Create item model
      final item = ItemModel(
        id: itemId,
        ownerId: _userId,
        title: title,
        description: description,
        category: category,
        imageUrl: urls['imageUrl']!,
        thumbnailUrl: urls['thumbnailUrl']!,
        status: ItemStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to database
      final newItem = await _repository.createItem(item);
      state = AsyncValue.data(newItem);
      return newItem;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Create a new item (legacy method for backward compatibility)
  Future<ItemModel?> createItemFromModel(ItemModel item) async {
    state = const AsyncValue.loading();
    
    try {
      final newItem = await _repository.createItem(item);
      state = AsyncValue.data(newItem);
      return newItem;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update an existing item
  Future<ItemModel?> updateItem(String itemId, ItemModel item) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedItem = await _repository.updateItem(itemId, item);
      state = AsyncValue.data(updatedItem);
      return updatedItem;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update item status
  Future<bool> updateItemStatus(String itemId, ItemStatus status) async {
    try {
      await _repository.updateItemStatus(itemId, status);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Delete an item
  Future<bool> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Clear the current state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for ItemNotifier
final itemNotifierProvider =
    StateNotifierProvider<ItemNotifier, AsyncValue<ItemModel?>>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id;
  
  return ItemNotifier(repository, storageService, userId);
});

/// Filters class for item queries
class ItemsFilters {
  final int limit;
  final int offset;
  final ItemCategory? category;
  final ItemStatus? status;
  final String? searchQuery;

  const ItemsFilters({
    this.limit = 20,
    this.offset = 0,
    this.category,
    this.status,
    this.searchQuery,
  });

  /// Create filters with only available items
  factory ItemsFilters.availableOnly({
    int limit = 20,
    int offset = 0,
    ItemCategory? category,
  }) {
    return ItemsFilters(
      limit: limit,
      offset: offset,
      category: category,
      status: ItemStatus.available,
    );
  }

  /// Create filters for a specific category
  factory ItemsFilters.byCategory(
    ItemCategory category, {
    int limit = 20,
    int offset = 0,
  }) {
    return ItemsFilters(
      limit: limit,
      offset: offset,
      category: category,
    );
  }

  /// Create filters for search
  factory ItemsFilters.search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) {
    return ItemsFilters(
      limit: limit,
      offset: offset,
      searchQuery: query,
    );
  }

  /// Copy with modifications
  ItemsFilters copyWith({
    int? limit,
    int? offset,
    ItemCategory? category,
    ItemStatus? status,
    String? searchQuery,
  }) {
    return ItemsFilters(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      category: category ?? this.category,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsFilters &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          category == other.category &&
          status == other.status &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      limit.hashCode ^
      offset.hashCode ^
      category.hashCode ^
      status.hashCode ^
      searchQuery.hashCode;
}
