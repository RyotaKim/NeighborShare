import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/presentation/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField Widget Tests', () {
    testWidgets('should display label and hint text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      // Arrange
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              controller: controller,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'test@example.com');

      // Assert
      expect(controller.text, equals('test@example.com'));
    });

    testWidgets('should obscure text when isPassword is true', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          ),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          ),
        ),
      );

      // Act - Tap the visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Assert - Password should now be visible
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);

      // Act - Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Assert - Password should be hidden again
      final textField2 = tester.widget<TextField>(find.byType(TextField));
      expect(textField2.obscureText, isTrue);
    });

    testWidgets('should display error text when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              controller: TextEditingController(),
              errorText: 'Invalid email address',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('should call validator function', (tester) async {
      // Arrange
      var validatorCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthTextField(
                label: 'Email',
                controller: TextEditingController(),
                validator: (value) {
                  validatorCalled = true;
                  return value?.isEmpty ?? true ? 'Required' : null;
                },
              ),
            ),
          ),
        ),
      );

      // Act - Enter text to trigger validation
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Find the Form and validate it
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();

      // Assert
      expect(validatorCalled, isTrue);
    });

    testWidgets('should show prefix icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              controller: TextEditingController(),
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should respect keyboard type', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              controller: TextEditingController(),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('should disable field when enabled is false', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              controller: TextEditingController(),
              enabled: false,
            ),
          ),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });

  group('AuthTextField Validation', () {
    testWidgets('should display error when validation fails', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AuthTextField(
                label: 'Email',
                controller: TextEditingController(),
                validator: (value) => 'Email is required',
              ),
            ),
          ),
        ),
      );

      // Act - Trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pump();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
    });
  });
}
