import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/features/items/data/repositories/item_repository.dart';
import 'package:flutter_application_1/features/items/data/models/item_model.dart';
import 'package:flutter_application_1/core/constants/category_constants.dart';
import 'package:flutter_application_1/core/errors/app_exception.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'item_repository_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late ItemRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = ItemRepository(mockSupabase);
  });

  group('ItemRepository - Create Item', () {
    test('should successfully create a new item', () async {
      // Arrange
      final testItem = ItemModel(
        id: 'item-id-123',
        userId: 'user-id-123',
        title: 'Test Drill',
        description: 'A test drill',
        category: ItemCategory.tools,
        imageUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        status: ItemStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => testItem.toJson());

      // Act
      final result = await repository.createItem(testItem);

      // Assert
      expect(result.id, equals('item-id-123'));
      expect(result.title, equals('Test Drill'));
      expect(result.category, equals(ItemCategory.tools));
      verify(mockSupabase.from('items')).called(1);
    });

    test('should throw DatabaseException when creation fails', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      
      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenThrow(
        PostgrestException(message: 'Database error'),
      );

      final testItem = ItemModel(
        id: 'item-id-123',
        userId: 'user-id-123',
        title: 'Test Drill',
        description: 'A test drill',
        category: ItemCategory.tools,
        imageUrl: 'https://example.com/image.jpg',
        status: ItemStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => repository.createItem(testItem),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('ItemRepository - Get All Items', () {
    test('should return list of items', () async {
      // Arrange
      final mockData = [
        {
          'id': 'item-1',
          'user_id': 'user-1',
          'title': 'Drill',
          'description': 'Power drill',
          'category': 'tools',
          'image_url': 'https://example.com/drill.jpg',
          'status': 'available',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'item-2',
          'user_id': 'user-2',
          'title': 'Mixer',
          'description': 'Stand mixer',
          'category': 'kitchen',
          'image_url': 'https://example.com/mixer.jpg',
          'status': 'available',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getAllItems();

      // Assert
      expect(result, isA<List<ItemModel>>());
      expect(result.length, equals(2));
      expect(result[0].title, equals('Drill'));
      expect(result[1].title, equals('Mixer'));
    });

    test('should return empty list when no items exist', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getAllItems();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('ItemRepository - Get Item by ID', () {
    test('should return item when it exists', () async {
      // Arrange
      final mockData = {
        'id': 'item-123',
        'user_id': 'user-123',
        'title': 'Test Item',
        'description': 'Test description',
        'category': 'tools',
        'image_url': 'https://example.com/image.jpg',
        'status': 'available',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'item-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getItemById('item-123');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('item-123'));
      expect(result.title, equals('Test Item'));
    });

    test('should return null when item does not exist', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'nonexistent')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenThrow(
        PostgrestException(message: 'No rows found'),
      );

      // Act
      final result = await repository.getItemById('nonexistent');

      // Assert
      expect(result, isNull);
    });
  });

  group('ItemRepository - Update Item', () {
    test('should successfully update an item', () async {
      // Arrange
      final updatedItem = ItemModel(
        id: 'item-123',
        userId: 'user-123',
        title: 'Updated Title',
        description: 'Updated description',
        category: ItemCategory.tools,
        imageUrl: 'https://example.com/image.jpg',
        status: ItemStatus.onLoan,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'item-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => updatedItem.toJson());

      // Act
      final result = await repository.updateItem(updatedItem);

      // Assert
      expect(result.id, equals('item-123'));
      expect(result.title, equals('Updated Title'));
      expect(result.status, equals(ItemStatus.onLoan));
    });
  });

  group('ItemRepository - Delete Item', () {
    test('should successfully delete an item', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'item-123')).thenAnswer((_) async => {});

      // Act
      await repository.deleteItem('item-123');

      // Assert
      verify(mockSupabase.from('items')).called(1);
      verify(mockQueryBuilder.delete()).called(1);
    });
  });

  group('ItemRepository - Filter by Category', () {
    test('should return items filtered by category', () async {
      // Arrange
      final mockData = [
        {
          'id': 'item-1',
          'user_id': 'user-1',
          'title': 'Drill',
          'description': 'Power drill',
          'category': 'tools',
          'image_url': 'https://example.com/drill.jpg',
          'status': 'available',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('category', 'tools')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getItemsByCategory(ItemCategory.tools);

      // Assert
      expect(result, isA<List<ItemModel>>());
      expect(result.length, equals(1));
      expect(result[0].category, equals(ItemCategory.tools));
    });
  });

  group('ItemRepository - Get User Items', () {
    test('should return items belonging to a specific user', () async {
      // Arrange
      final mockData = [
        {
          'id': 'item-1',
          'user_id': 'user-123',
          'title': 'My Drill',
          'description': 'My drill',
          'category': 'tools',
          'image_url': 'https://example.com/drill.jpg',
          'status': 'available',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', 'user-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getUserItems('user-123');

      // Assert
      expect(result, isA<List<ItemModel>>());
      expect(result.length, equals(1));
      expect(result[0].userId, equals('user-123'));
    });
  });
}
