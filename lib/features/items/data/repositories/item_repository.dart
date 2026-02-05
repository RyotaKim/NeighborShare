import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/item_model.dart';

/// Repository for item-related data operations
/// Handles CRUD operations for items with Supabase
class ItemRepository {
  final SupabaseClient _client;

  ItemRepository() : _client = SupabaseService.client;

  /// Fetch items with pagination and optional filters
  /// 
  /// [limit] - Number of items to fetch (default: 20)
  /// [offset] - Number of items to skip for pagination
  /// [category] - Filter by category (optional)
  /// [status] - Filter by status (optional)
  /// [ownerId] - Filter by owner ID (optional)
  /// [searchQuery] - Search in title and description (optional)
  Future<List<ItemModel>> fetchItems({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
    ItemCategory? category,
    ItemStatus? status,
    String? ownerId,
    String? searchQuery,
  }) async {
    try {
      // Start with the items_with_owner view to get owner information
      var query = _client.from(SupabaseConstants.itemsWithOwnerView).select();

      // Apply filters
      if (category != null) {
        query = query.eq('category', category.toDbString());
      }

      if (status != null) {
        query = query.eq('status', status.toDbString());
      }

      if (ownerId != null) {
        query = query.eq('owner_id', ownerId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Search in title and description using ilike (case-insensitive)
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch items: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch items. Please try again.',
        originalError: e,
      );
    }
  }

  /// Get a single item by ID with owner information
  Future<ItemModel> getItemById(String itemId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.itemsWithOwnerView)
          .select()
          .eq('id', itemId)
          .maybeSingle();

      if (response == null) {
        throw const DatabaseException.notFound();
      }

      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to fetch item: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch item. Please try again.',
        originalError: e,
      );
    }
  }

  /// Create a new item
  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final response = await _client
          .from(SupabaseConstants.itemsTable)
          .insert(item.toCreateJson())
          .select()
          .single();

      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to create item: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create item. Please try again.',
        originalError: e,
      );
    }
  }

  /// Update an existing item
  Future<ItemModel> updateItem(String itemId, ItemModel item) async {
    try {
      final response = await _client
          .from(SupabaseConstants.itemsTable)
          .update(item.toUpdateJson())
          .eq('id', itemId)
          .select()
          .single();

      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to update item: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update item. Please try again.',
        originalError: e,
      );
    }
  }

  /// Update item status (available/on loan)
  Future<void> updateItemStatus(String itemId, ItemStatus status) async {
    try {
      await _client
          .from(SupabaseConstants.itemsTable)
          .update({'status': status.toDbString()})
          .eq('id', itemId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to update item status: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update item status. Please try again.',
        originalError: e,
      );
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _client
          .from(SupabaseConstants.itemsTable)
          .delete()
          .eq('id', itemId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Failed to delete item: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete item. Please try again.',
        originalError: e,
      );
    }
  }

  /// Get items owned by a specific user
  Future<List<ItemModel>> getMyItems({
    required String userId,
    ItemStatus? status,
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    return fetchItems(
      ownerId: userId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  /// Search items by query
  Future<List<ItemModel>> searchItems(
    String query, {
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    return fetchItems(
      searchQuery: query,
      limit: limit,
      offset: offset,
    );
  }

  /// Get items by category
  Future<List<ItemModel>> getItemsByCategory(
    ItemCategory category, {
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    return fetchItems(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  /// Stream of items (for real-time updates)
  /// Note: This uses polling instead of true real-time for simplicity
  /// In production, you'd use Supabase Realtime subscriptions
  Stream<List<ItemModel>> watchItems({
    ItemCategory? category,
    ItemStatus? status,
    String? ownerId,
  }) {
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => fetchItems(
              category: category,
              status: status,
              ownerId: ownerId,
            ))
        .handleError((error) {
      throw DatabaseException(
        message: 'Failed to watch items',
        originalError: error,
      );
    });
  }
}
