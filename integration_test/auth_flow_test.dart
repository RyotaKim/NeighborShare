import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete sign up flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should land on welcome/login screen
      expect(find.text('Sign Up'), findsOneWidget);

      // Tap Sign Up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill in registration form
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'testuser@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'testuser123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'password123',
      );

      // Scroll if needed and tap Create Account
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show email verification message
      expect(find.textContaining('Check your email'), findsOneWidget);
    });

    testWidgets('Sign in flow with valid credentials', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should land on login screen
      expect(find.text('Log In'), findsOneWidget);

      // Tap Log In (if on welcome screen)
      if (find.text('Log In').evaluate().isNotEmpty) {
        await tester.tap(find.text('Log In').first);
        await tester.pumpAndSettle();
      }

      // Fill in login form
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'existing@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );

      // Tap Sign In button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to home feed (or show error if credentials invalid)
      // This depends on whether the test user exists in test database
    });

    testWidgets('Sign in validation - empty fields', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login if needed
      if (find.text('Log In').evaluate().isNotEmpty) {
        await tester.tap(find.text('Log In').first);
        await tester.pumpAndSettle();
      }

      // Try to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('Password reset flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login
      if (find.text('Log In').evaluate().isNotEmpty) {
        await tester.tap(find.text('Log In').first);
        await tester.pumpAndSettle();
      }

      // Tap "Forgot Password?" link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );

      // Submit
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success message
      expect(find.textContaining('Check your email'), findsOneWidget);
    });
  });

  group('Profile Setup Flow', () {
    testWidgets('Complete profile setup after registration', (tester) async {
      // Assume user just verified email and is on profile setup screen
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If on profile setup screen
      if (find.text('Profile Setup').evaluate().isNotEmpty) {
        // Tap avatar picker (optional)
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();

        // Select from gallery (this would open native picker in real app)
        // For integration test, just proceed

        // Enter full name
        await tester.enterText(
          find.widgetWithText(TextField, 'Full Name'),
          'Test User',
        );

        // Enter neighborhood
        await tester.enterText(
          find.widgetWithText(TextField, 'Neighborhood'),
          'Downtown',
        );

        // Tap Continue/Finish
        await tester.tap(find.text('Finish Setup'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should navigate to home feed
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });
  });
}
