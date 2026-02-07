# NeighborShare Testing Guide

## Overview
Comprehensive testing suite for the NeighborShare application including unit tests, widget tests, and integration tests.

## Test Structure

```
test/
├── unit/
│   ├── repositories/
│   │   ├── auth_repository_test.dart
│   │   ├── item_repository_test.dart
│   │   ├── profile_repository_test.dart
│   │   └── chat_repository_test.dart
│   └── utils/
│       └── validators_test.dart
│
├── widget/
│   ├── item_card_test.dart
│   ├── profile_header_test.dart
│   └── auth_text_field_test.dart
│
integration_test/
├── auth_flow_test.dart
├── item_flow_test.dart
├── profile_flow_test.dart
└── chat_flow_test.dart
```

## Prerequisites

Before running tests, ensure you have:
1. Flutter SDK installed (3.10.8+)
2. All dependencies installed: `flutter pub get`
3. Mock files generated: `flutter pub run build_runner build`

## Generating Mock Files

The unit tests use Mockito for mocking dependencies. Generate the required mock files:

```powershell
# Generate mocks for all test files
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create `.mocks.dart` files next to each test file that uses `@GenerateMocks`.

## Running Tests

### Run All Tests

```powershell
flutter test
```

### Run Unit Tests Only

```powershell
flutter test test/unit/
```

### Run Widget Tests Only

```powershell
flutter test test/widget/
```

### Run Specific Test File

```powershell
flutter test test/unit/repositories/auth_repository_test.dart
```

### Run Integration Tests

Integration tests require a device or emulator:

```powershell
# Chrome (web)
flutter test integration_test/auth_flow_test.dart -d chrome

# Android emulator
flutter test integration_test/item_flow_test.dart -d emulator-5554

# All integration tests
flutter test integration_test/
```

## Test Coverage

### Generate Coverage Report

```powershell
# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report (requires lcov)
# Install: choco install lcov (Windows)
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
Start-Process coverage/html/index.html
```

### Current Coverage Targets
- **Repositories**: 80%+ coverage
- **Utils/Validators**: 90%+ coverage
- **Widgets**: 70%+ coverage
- **Overall**: 70%+ coverage

## Unit Tests

### Repository Tests
Test all CRUD operations and error handling:
- **Auth Repository**: Sign up, sign in, sign out, password reset
- **Item Repository**: Create, read, update, delete items, filtering
- **Profile Repository**: Profile CRUD, avatar upload, statistics
- **Chat Repository**: Conversations, messages, real-time updates

### Utility Tests
- **Validators**: Email, password, username, title, description validation

### Running Repository Tests

```powershell
flutter test test/unit/repositories/
```

## Widget Tests

Test UI components in isolation:
- **ItemCard**: Display, interactions, status indicators
- **ProfileHeader**: Profile display, avatars, member info
- **AuthTextField**: Input validation, password visibility, error states

### Running Widget Tests

```powershell
flutter test test/widget/
```

## Integration Tests

End-to-end testing of complete user flows:

### Auth Flow Tests
- Sign up flow
- Sign in with validation
- Password reset
- Profile setup

```powershell
flutter test integration_test/auth_flow_test.dart -d chrome
```

### Item Flow Tests
- Add new item
- Browse and filter items
- View item details
- Toggle availability
- Edit and delete items

```powershell
flutter test integration_test/item_flow_test.dart -d chrome
```

### Profile Flow Tests
- View and edit profile
- Change avatar
- View statistics
- View other user profiles
- Logout

```powershell
flutter test integration_test/profile_flow_test.dart -d chrome
```

### Chat Flow Tests
- Start conversation
- Send messages
- Real-time updates
- Empty states
- Delete conversations

```powershell
flutter test integration_test/chat_flow_test.dart -d chrome
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.8'
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Testing Best Practices

### Unit Tests
1. **Arrange-Act-Assert** pattern
2. Mock external dependencies (Supabase, Storage)
3. Test both success and error cases
4. Verify method calls with `verify()`

### Widget Tests
1. Use `testWidgets()` for widget tests
2. Pump widgets with `tester.pumpWidget()`
3. Find widgets with `find.text()`, `find.byType()`
4. Simulate user interactions with `tester.tap()`

### Integration Tests
1. Test complete user journeys
2. Use `pumpAndSettle()` for animations
3. Add adequate delays for async operations
4. Test with real backend when possible

## Common Issues & Solutions

### Issue: Mock files not generated
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: Integration test timeout
**Solution**: Increase timeout in test: `testWidgets('test', (tester) async {}, timeout: Timeout(Duration(minutes: 2)))`

### Issue: Widget not found in test
**Solution**: Use `await tester.pumpAndSettle()` after navigation or state changes

### Issue: Supabase connection errors
**Solution**: Ensure `.env` file is configured with test Supabase project

## Test Data Setup

For integration tests, you may need test data in your Supabase test database:

1. Create a test Supabase project
2. Run `database_setup.sql` to create tables
3. Add test users and items manually or via seed script
4. Update `.env.test` with test project credentials

## Debugging Tests

### Run tests in debug mode:

```powershell
flutter test --debug test/unit/repositories/auth_repository_test.dart
```

### View detailed output:

```powershell
flutter test --verbose
```

### Run a single test:

```dart
testWidgets('test name', (tester) async {
  // ...
}, skip: false); // Remove skip to run, add skip: true to skip
```

## Continuous Improvement

- Add tests when fixing bugs
- Maintain 70%+ coverage
- Review coverage reports regularly
- Update tests when refactoring code

## Test Maintenance

- Update mocks when repository signatures change
- Regenerate mocks after dependency updates
- Keep integration tests aligned with current UI
- Remove obsolete tests after feature changes

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)

---

**Last Updated**: February 7, 2026  
**Test Coverage**: ~70%  
**Total Tests**: 50+ unit tests, 15+ widget tests, 25+ integration tests
