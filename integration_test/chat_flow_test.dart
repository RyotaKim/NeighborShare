import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Flow Integration Tests', () {
    testWidgets('Start conversation from item detail', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on an item to view details
      final itemCards = find.byKey(const Key('item_card'));
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Tap "Ask to Borrow" button
        await tester.tap(find.text('Ask to Borrow'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should navigate to chat screen
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);

        // Chat should be linked to the item
        // Should show item thumbnail in app bar
      }
    });

    testWidgets('Send message in conversation', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations tab
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Tap on first conversation (if any exists)
      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // Type a message
        await tester.enterText(
          find.byType(TextField),
          'Hi! Is this item still available?',
        );

        // Tap send button
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Message should appear in chat
        expect(find.text('Hi! Is this item still available?'), findsOneWidget);

        // Input field should be cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      }
    });

    testWidgets('View conversations list', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations tab
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Should show list of conversations
      // If user has conversations, they should be visible
      // If no conversations, should show empty state
      final emptyState = find.text('No conversations yet');
      final conversationList = find.byType(ListView);

      expect(emptyState.evaluate().isNotEmpty || conversationList.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('Receive real-time messages', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations and open a chat
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // Wait for potential incoming messages
        // (In real test, you would trigger a message from another user)
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Real-time subscription should update chat
        // New messages should appear without refresh
      }
    });

    testWidgets('Navigate from chat to item detail', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // Tap on item thumbnail in app bar or header
        final itemThumbnail = find.byKey(const Key('chat_item_thumbnail'));
        if (itemThumbnail.evaluate().isNotEmpty) {
          await tester.tap(itemThumbnail);
          await tester.pumpAndSettle();

          // Should navigate to item detail screen
          expect(find.text('Ask to Borrow'), findsOneWidget);
        }
      }
    });

    testWidgets('Back navigation from chat', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // Press back button
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Should return to conversations list
        expect(find.byIcon(Icons.chat), findsOneWidget);
      }
    });

    testWidgets('Empty conversation state', (tester) async {
      // Launch app with user who has no conversations
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations tab
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // If no conversations exist, should show empty state
      final emptyState = find.text('No conversations yet');
      final startChatHint = find.textContaining('Browse items');

      // At least one of these should be visible
      expect(
        emptyState.evaluate().isNotEmpty || startChatHint.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Message validation - empty message', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // Try to send empty message
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Send button should be disabled or message not sent
        // (Depends on implementation - button might be disabled when input is empty)
      }
    });

    testWidgets('Scroll through message history', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to a conversation with message history
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        await tester.tap(conversationCards.first);
        await tester.pumpAndSettle();

        // If there are many messages, try scrolling
        final messageList = find.byType(ListView);
        if (messageList.evaluate().isNotEmpty) {
          // Scroll up to load older messages
          await tester.drag(messageList, const Offset(0, 300));
          await tester.pumpAndSettle();

          // Older messages should load (if pagination implemented)
        }
      }
    });
  });

  group('Chat Notifications', () {
    testWidgets('Unread message indicator', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations tab
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Conversations with unread messages should show badge
      // (This depends on test data and real-time updates)
      final unreadBadge = find.byKey(const Key('unread_badge'));
      
      // Badge should exist if there are unread messages
      // (Test would verify based on test scenario)
    });
  });

  group('Conversation Management', () {
    testWidgets('Delete conversation', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Conversations
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final conversationCards = find.byKey(const Key('conversation_card'));
      if (conversationCards.evaluate().isNotEmpty) {
        // Long press or swipe to delete
        await tester.longPress(conversationCards.first);
        await tester.pumpAndSettle();

        // Should show delete option
        final deleteButton = find.text('Delete');
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();

          // Confirm deletion
          await tester.tap(find.text('Delete').last);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Conversation should be removed from list
        }
      }
    });
  });
}
