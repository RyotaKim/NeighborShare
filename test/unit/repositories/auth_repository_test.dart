import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:flutter_application_1/core/errors/app_exception.dart';

// Generate mocks
@GenerateMocks([SupabaseClient, GoTrueClient, PostgrestQueryBuilder])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late AuthRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(mockSupabase.auth).thenReturn(mockAuth);
    repository = AuthRepository(mockSupabase);
  });

  group('AuthRepository - Sign Up', () {
    test('should successfully sign up a new user', () async {
      // Arrange
      final testEmail = 'test@example.com';
      final testPassword = 'password123';
      final testUsername = 'testuser';
      
      final mockAuthResponse = AuthResponse(
        user: User(
          id: 'user-id-123',
          appMetadata: {},
          userMetadata: {'username': testUsername},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: Session(
          accessToken: 'access-token',
          tokenType: 'bearer',
          user: User(
            id: 'user-id-123',
            appMetadata: {},
            userMetadata: {'username': testUsername},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
      );

      when(mockAuth.signUp(
        email: testEmail,
        password: testPassword,
        data: {'username': testUsername},
      )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await repository.signUp(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result.id, equals('user-id-123'));
      expect(result.username, equals(testUsername));
      verify(mockAuth.signUp(
        email: testEmail,
        password: testPassword,
        data: {'username': testUsername},
      )).called(1);
    });

    test('should throw AppAuthException when sign up fails', () async {
      // Arrange
      when(mockAuth.signUp(
        email: any,
        password: any,
        data: anyNamed('data'),
      )).thenThrow(AuthException('Email already registered'));

      // Act & Assert
      expect(
        () => repository.signUp(
          email: 'test@example.com',
          password: 'password123',
          username: 'testuser',
        ),
        throwsA(isA<AppAuthException>()),
      );
    });
  });

  group('AuthRepository - Sign In', () {
    test('should successfully sign in a user', () async {
      // Arrange
      final testEmail = 'test@example.com';
      final testPassword = 'password123';

      final mockAuthResponse = AuthResponse(
        user: User(
          id: 'user-id-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: Session(
          accessToken: 'access-token',
          tokenType: 'bearer',
          user: User(
            id: 'user-id-123',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
      );

      when(mockAuth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await repository.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.id, equals('user-id-123'));
      verify(mockAuth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should throw AppAuthException when credentials are invalid', () async {
      // Arrange
      when(mockAuth.signInWithPassword(
        email: any,
        password: any,
      )).thenThrow(AuthException('Invalid login credentials'));

      // Act & Assert
      expect(
        () => repository.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AppAuthException>()),
      );
    });
  });

  group('AuthRepository - Sign Out', () {
    test('should successfully sign out', () async {
      // Arrange
      when(mockAuth.signOut()).thenAnswer((_) async => {});

      // Act
      await repository.signOut();

      // Assert
      verify(mockAuth.signOut()).called(1);
    });

    test('should handle sign out errors gracefully', () async {
      // Arrange
      when(mockAuth.signOut()).thenThrow(AuthException('Network error'));

      // Act & Assert
      expect(
        () => repository.signOut(),
        throwsA(isA<AppAuthException>()),
      );
    });
  });

  group('AuthRepository - Get Current User', () {
    test('should return current user when session exists', () async {
      // Arrange
      final mockUser = User(
        id: 'user-id-123',
        appMetadata: {},
        userMetadata: {'username': 'testuser'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      when(mockAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('user-id-123'));
      expect(result.username, equals('testuser'));
    });

    test('should return null when no session exists', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthRepository - Password Reset', () {
    test('should send password reset email successfully', () async {
      // Arrange
      final testEmail = 'test@example.com';
      when(mockAuth.resetPasswordForEmail(testEmail)).thenAnswer((_) async => {});

      // Act
      await repository.resetPassword(testEmail);

      // Assert
      verify(mockAuth.resetPasswordForEmail(testEmail)).called(1);
    });

    test('should throw exception when email is invalid', () async {
      // Arrange
      when(mockAuth.resetPasswordForEmail(any))
          .thenThrow(AuthException('Email not found'));

      // Act & Assert
      expect(
        () => repository.resetPassword('invalid@example.com'),
        throwsA(isA<AppAuthException>()),
      );
    });
  });
}
