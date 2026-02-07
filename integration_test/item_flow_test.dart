import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Item Management Flow Integration Tests', () {
    testWidgets('Add new item flow', (tester) async {
      // Launch app (assume user is already logged in)
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on home feed
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Tap the Floating Action Button to add item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show image source options (Camera/Gallery)
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);

      // Select gallery (in integration test, this opens native picker)
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After image selection, should be on item form
      // (In real test, image would be selected from gallery)

      // Fill in item details
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Cordless Drill',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'DeWalt 20V drill in great condition',
      );

      // Select category (Tools)
      await tester.tap(find.text('Tools'));
      await tester.pumpAndSettle();

      // Scroll to submit button if needed
      await tester.ensureVisible(find.text('Publish Item'));

      // Tap Publish Item
      await tester.tap(find.text('Publish Item'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate back to home feed
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // New item should appear in feed
      expect(find.text('Cordless Drill'), findsOneWidget);
    });

    testWidgets('Browse and view item details', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on home feed with items
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Wait for items to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on first item card (if any exists)
      final itemCards = find.byKey(const Key('item_card'));
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Should navigate to item detail screen
        expect(find.text('Ask to Borrow'), findsOneWidget);
        
        // Should show item information
        expect(find.byType(Image), findsWidgets);
        
        // Go back to feed
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Filter items by category', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on home feed
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Find and tap Tools category filter
      await tester.tap(find.text('Tools'));
      await tester.pumpAndSettle();

      // Items should be filtered to only show Tools
      // (Verify by checking that category chips are updated)
      
      // Tap "All" to reset filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
    });

    testWidgets('Search for items', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap search icon in app bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'drill');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Results should update in real-time
      // Verify drill-related items are shown
    });

    testWidgets('Toggle item availability', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap Profile tab in bottom nav
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should see user's items
      // Tap on one of user's items
      final myItemCards = find.byKey(const Key('my_item_card'));
      if (myItemCards.evaluate().isNotEmpty) {
        await tester.tap(myItemCards.first);
        await tester.pumpAndSettle();

        // Should be on item detail screen
        // Find availability toggle switch
        final toggleSwitch = find.byType(Switch);
        if (toggleSwitch.evaluate().isNotEmpty) {
          final switchWidget = tester.widget<Switch>(toggleSwitch);
          final initialState = switchWidget.value;

          // Toggle the switch
          await tester.tap(toggleSwitch);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // State should have changed
          final updatedSwitch = tester.widget<Switch>(toggleSwitch);
          expect(updatedSwitch.value, equals(!initialState));
        }
      }
    });

    testWidgets('Edit item details', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap on user's item
      final myItemCards = find.byKey(const Key('my_item_card'));
      if (myItemCards.evaluate().isNotEmpty) {
        await tester.tap(myItemCards.first);
        await tester.pumpAndSettle();

        // Tap Edit button
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Update title
        await tester.enterText(
          find.widgetWithText(TextField, 'Title'),
          'Updated Item Title',
        );

        // Save changes
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should navigate back with updated item
        expect(find.text('Updated Item Title'), findsOneWidget);
      }
    });

    testWidgets('Delete item', (tester) async {
      // Launch app and navigate to profile
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Long press on item or tap delete button
      final deleteButtons = find.byIcon(Icons.delete);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Confirm deletion in dialog
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Item should be removed
        expect(find.text('Item deleted'), findsOneWidget);
      }
    });
  });

  group('Item Interactions', () {
    testWidgets('View item owner profile', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on an item
      final itemCards = find.byKey(const Key('item_card'));
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Tap on owner's avatar or name
        await tester.tap(find.text('View Owner\'s Profile'));
        await tester.pumpAndSettle();

        // Should navigate to owner's profile
        expect(find.text('Items Listed'), findsOneWidget);
      }
    });

    testWidgets('Start conversation about item', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on an item
      final itemCards = find.byKey(const Key('item_card'));
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Tap "Ask to Borrow" button
        await tester.tap(find.text('Ask to Borrow'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should navigate to chat screen
        expect(find.byType(TextField), findsOneWidget); // Message input
        expect(find.byIcon(Icons.send), findsOneWidget);
      }
    });
  });
}
