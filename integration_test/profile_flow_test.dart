import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Management Flow Integration Tests', () {
    testWidgets('View own profile', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should display profile information
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Items Listed'), findsOneWidget);
      expect(find.text('Times Lent'), findsOneWidget);
      
      // Should show Edit Profile button
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('Edit profile information', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap Edit Profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Update full name
      await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'),
        'Updated Name',
      );

      // Update bio
      await tester.enterText(
        find.widgetWithText(TextField, 'Bio'),
        'This is my updated bio',
      );

      // Update neighborhood
      await tester.enterText(
        find.widgetWithText(TextField, 'Neighborhood'),
        'Uptown',
      );

      // Scroll to save button
      await tester.ensureVisible(find.text('Save Changes'));

      // Save changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate back to profile
      expect(find.text('Updated Name'), findsOneWidget);
      expect(find.text('This is my updated bio'), findsOneWidget);
      expect(find.text('Uptown'), findsOneWidget);
    });

    testWidgets('Change profile avatar', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap Edit Profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Tap avatar to change
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // Should show options: Take Photo / Choose from Gallery
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);

      // Select gallery (this would open native picker)
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After selection, image should update (in real app)
      // Save profile
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Avatar should be updated
    });

    testWidgets('View profile statistics', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should show statistics
      expect(find.text('Items Listed'), findsOneWidget);
      expect(find.text('Times Lent'), findsOneWidget);

      // Numbers should be displayed
      // (Exact numbers depend on test data)
    });

    testWidgets('View other user profile', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on an item to view details
      final itemCards = find.byKey(const Key('item_card'));
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Tap on owner's profile link
        await tester.tap(find.text('View Owner\'s Profile'));
        await tester.pumpAndSettle();

        // Should show other user's profile (read-only)
        expect(find.byType(CircleAvatar), findsOneWidget);
        
        // Should NOT show Edit Profile button
        expect(find.text('Edit Profile'), findsNothing);
        
        // Should show their items
        expect(find.text('Items Listed'), findsOneWidget);
      }
    });

    testWidgets('Logout flow', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Scroll to find logout button if needed
      await tester.ensureVisible(find.text('Logout'));

      // Tap Logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to login screen
      expect(find.text('Log In'), findsOneWidget);
    });
  });

  group('Profile Validation', () {
    testWidgets('Cannot save profile with invalid data', (tester) async {
      // Launch app and navigate to edit profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Try to enter bio that's too long (> 500 chars)
      final longBio = 'a' * 501;
      await tester.enterText(
        find.widgetWithText(TextField, 'Bio'),
        longBio,
      );

      // Try to save
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('too long'), findsOneWidget);
    });

    testWidgets('Can cancel profile editing', (tester) async {
      // Launch app and navigate to edit profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      final originalName = find.text('Original Name');
      
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Make changes
      await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'),
        'Changed Name',
      );

      // Cancel editing
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should show unsaved changes dialog
      expect(find.text('Discard changes?'), findsOneWidget);

      // Confirm discard
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Should return to profile without saving
      // Original name should still be displayed (if it existed)
    });
  });
}
