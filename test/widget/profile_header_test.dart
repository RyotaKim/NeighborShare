import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_application_1/features/profile/data/models/profile_model.dart';

void main() {
  late ProfileModel testProfile;

  setUp(() {
    testProfile = ProfileModel(
      id: 'user-123',
      username: 'john_doe',
      fullName: 'John Doe',
      avatarUrl: 'https://example.com/avatar.jpg',
      neighborhood: 'Downtown',
      bio: 'Love sharing with my community!',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    );
  });

  group('ProfileHeader Widget Tests', () {
    testWidgets('should display profile information correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('@john_doe'), findsOneWidget);
      expect(find.text('Downtown'), findsOneWidget);
    });

    testWidgets('should show username when full name is null', (tester) async {
      // Arrange
      final profileWithoutName = testProfile.copyWith(fullName: null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: profileWithoutName),
          ),
        ),
      );

      // Assert
      expect(find.text('john_doe'), findsOneWidget);
      expect(find.text('@john_doe'), findsOneWidget);
    });

    testWidgets('should display avatar image when URL is provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show initials when avatar URL is null', (tester) async {
      // Arrange
      final profileWithoutAvatar = testProfile.copyWith(avatarUrl: null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: profileWithoutAvatar),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget); // Initials
    });

    testWidgets('should display bio when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('Love sharing with my community!'), findsOneWidget);
    });

    testWidgets('should not display bio section when bio is null', (tester) async {
      // Arrange
      final profileWithoutBio = testProfile.copyWith(bio: null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: profileWithoutBio),
          ),
        ),
      );

      // Assert
      expect(find.text('Love sharing with my community!'), findsNothing);
    });

    testWidgets('should display neighborhood with location icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('Downtown'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should display member since date', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Member since'), findsOneWidget);
      expect(find.textContaining('Jan'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });
  });

  group('ProfileHeader Layout Tests', () {
    testWidgets('should have proper spacing and padding', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: testProfile),
          ),
        ),
      );

      // Assert - Widget should exist and be laid out properly
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
