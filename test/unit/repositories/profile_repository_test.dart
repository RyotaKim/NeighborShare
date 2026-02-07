import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/features/profile/data/models/profile_model.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'dart:io';

@GenerateMocks([
  SupabaseClient,
  StorageService,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
])
import 'profile_repository_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late MockStorageService mockStorageService;
  late ProfileRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockStorageService = MockStorageService();
    repository = ProfileRepository(mockSupabase, mockStorageService);
  });

  group('ProfileRepository - Get Profile', () {
    test('should return profile when it exists', () async {
      // Arrange
      final mockData = {
        'id': 'user-123',
        'username': 'testuser',
        'full_name': 'Test User',
        'avatar_url': 'https://example.com/avatar.jpg',
        'neighborhood': 'Downtown',
        'bio': 'Test bio',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'user-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getProfile('user-123');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('user-123'));
      expect(result.username, equals('testuser'));
      expect(result.fullName, equals('Test User'));
    });

    test('should return null when profile does not exist', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'nonexistent')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenThrow(
        PostgrestException(message: 'No rows found'),
      );

      // Act
      final result = await repository.getProfile('nonexistent');

      // Assert
      expect(result, isNull);
    });
  });

  group('ProfileRepository - Update Profile', () {
    test('should successfully update a profile', () async {
      // Arrange
      final updatedProfile = ProfileModel(
        id: 'user-123',
        username: 'testuser',
        fullName: 'Updated Name',
        avatarUrl: 'https://example.com/avatar.jpg',
        neighborhood: 'Uptown',
        bio: 'Updated bio',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', 'user-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => updatedProfile.toJson());

      // Act
      final result = await repository.updateProfile(updatedProfile);

      // Assert
      expect(result.id, equals('user-123'));
      expect(result.fullName, equals('Updated Name'));
      expect(result.neighborhood, equals('Uptown'));
      expect(result.bio, equals('Updated bio'));
    });

    test('should throw DatabaseException when update fails', () async {
      // Arrange
      final profile = ProfileModel(
        id: 'user-123',
        username: 'testuser',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any)).thenThrow(
        PostgrestException(message: 'Update failed'),
      );

      // Act & Assert
      expect(
        () => repository.updateProfile(profile),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('ProfileRepository - Upload Avatar', () {
    test('should successfully upload avatar and return URL', () async {
      // Arrange
      final testFile = File('test_avatar.jpg');
      final userId = 'user-123';
      final expectedUrl = 'https://example.com/avatars/user-123.jpg';

      when(mockStorageService.uploadAvatar(userId, testFile))
          .thenAnswer((_) async => expectedUrl);

      // Act
      final result = await repository.uploadAvatar(userId, testFile);

      // Assert
      expect(result, equals(expectedUrl));
      verify(mockStorageService.uploadAvatar(userId, testFile)).called(1);
    });

    test('should throw AppStorageException when upload fails', () async {
      // Arrange
      final testFile = File('test_avatar.jpg');
      final userId = 'user-123';

      when(mockStorageService.uploadAvatar(userId, testFile))
          .thenThrow(AppStorageException(message: 'Upload failed'));

      // Act & Assert
      expect(
        () => repository.uploadAvatar(userId, testFile),
        throwsA(isA<AppStorageException>()),
      );
    });
  });

  group('ProfileRepository - Delete Avatar', () {
    test('should successfully delete avatar', () async {
      // Arrange
      final avatarUrl = 'https://example.com/avatars/user-123.jpg';

      when(mockStorageService.deleteFile(avatarUrl))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteAvatar(avatarUrl);

      // Assert
      verify(mockStorageService.deleteFile(avatarUrl)).called(1);
    });

    test('should handle deletion errors gracefully', () async {
      // Arrange
      final avatarUrl = 'https://example.com/avatars/user-123.jpg';

      when(mockStorageService.deleteFile(avatarUrl))
          .thenThrow(AppStorageException(message: 'Delete failed'));

      // Act & Assert
      expect(
        () => repository.deleteAvatar(avatarUrl),
        throwsA(isA<AppStorageException>()),
      );
    });
  });

  group('ProfileRepository - Get User Statistics', () {
    test('should return correct item count for user', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockResponse = PostgrestResponse(data: [{}, {}, {}], count: 3);

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any, const FetchOptions(count: CountOption.exact)))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', 'user-123'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getUserItemsCount('user-123');

      // Assert
      expect(result, equals(3));
    });

    test('should return zero when user has no items', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockResponse = PostgrestResponse(data: [], count: 0);

      when(mockSupabase.from('items')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any, const FetchOptions(count: CountOption.exact)))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', 'user-123'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getUserItemsCount('user-123');

      // Assert
      expect(result, equals(0));
    });
  });

  group('ProfileRepository - Search Profiles', () {
    test('should return profiles matching search query', () async {
      // Arrange
      final mockData = [
        {
          'id': 'user-1',
          'username': 'john_doe',
          'full_name': 'John Doe',
          'neighborhood': 'Downtown',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'user-2',
          'username': 'john_smith',
          'full_name': 'John Smith',
          'neighborhood': 'Uptown',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.or(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(20)).thenAnswer((_) async => mockData);

      // Act
      final result = await repository.searchProfiles('john');

      // Assert
      expect(result, isA<List<ProfileModel>>());
      expect(result.length, equals(2));
      expect(result[0].username, equals('john_doe'));
      expect(result[1].username, equals('john_smith'));
    });

    test('should return empty list when no profiles match', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.or(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(20)).thenAnswer((_) async => []);

      // Act
      final result = await repository.searchProfiles('nonexistent');

      // Assert
      expect(result, isEmpty);
    });
  });

  group('ProfileRepository - Get Neighborhood Profiles', () {
    test('should return profiles from the same neighborhood', () async {
      // Arrange
      final mockData = [
        {
          'id': 'user-1',
          'username': 'neighbor1',
          'full_name': 'Neighbor One',
          'neighborhood': 'Downtown',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'user-2',
          'username': 'neighbor2',
          'full_name': 'Neighbor Two',
          'neighborhood': 'Downtown',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('neighborhood', 'Downtown')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('username')).thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getNeighborhoodProfiles('Downtown');

      // Assert
      expect(result, isA<List<ProfileModel>>());
      expect(result.length, equals(2));
      expect(result.every((p) => p.neighborhood == 'Downtown'), isTrue);
    });
  });
}
