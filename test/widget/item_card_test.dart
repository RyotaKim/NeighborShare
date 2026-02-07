import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/items/presentation/widgets/item_card.dart';
import 'package:flutter_application_1/features/items/data/models/item_model.dart';
import 'package:flutter_application_1/core/constants/category_constants.dart';

void main() {
  late ItemModel testItem;

  setUp(() {
    testItem = ItemModel(
      id: 'item-123',
      userId: 'user-123',
      title: 'Cordless Drill',
      description: 'DeWalt 20V drill in great condition',
      category: ItemCategory.tools,
      imageUrl: 'https://example.com/drill.jpg',
      thumbnailUrl: 'https://example.com/drill_thumb.jpg',
      status: ItemStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('ItemCard Widget Tests', () {
    testWidgets('should display item information correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cordless Drill'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      // Arrange
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should show available status indicator', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Look for available status (green indicator)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show on loan status for borrowed items', (tester) async {
      // Arrange
      final onLoanItem = testItem.copyWith(status: ItemStatus.onLoan);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: onLoanItem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Look for on loan status (red/locked indicator)
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display category badge', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Should show Tools category
      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('should show placeholder when image fails to load', (tester) async {
      // Arrange
      final itemWithoutImage = testItem.copyWith(
        imageUrl: null,
        thumbnailUrl: null,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: itemWithoutImage,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.image), findsOneWidget);
    });
  });

  group('ItemCard Grid Layout', () {
    testWidgets('should render multiple items in grid', (tester) async {
      // Arrange
      final items = List.generate(
        4,
        (index) => testItem.copyWith(
          id: 'item-$index',
          title: 'Item $index',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => ItemCard(
                item: items[index],
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ItemCard), findsNWidgets(4));
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
