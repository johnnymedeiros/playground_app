import 'package:flutter_test/flutter_test.dart';
import 'package:playground_app/data/services/item_service.dart';

void main() {
  group('ItemServiceImpl Tests', () {
    late ItemServiceImpl itemService;

    setUp(() {
      itemService = ItemServiceImpl();
    });

    test('should fetch initial list of items', () async {
      final items = await itemService.fetchItems();

      expect(items, isNotEmpty);
      expect(items.length, equals(5));
      expect(items.first.id, equals('1'));
      expect(items.first.title, equals('Tarefa 1'));
      expect(items.last.id, equals('5'));
      expect(items.last.title, equals('Tarefa 5'));
    });

    test('should return items with correct structure', () async {
      final items = await itemService.fetchItems();

      for (final item in items) {
        expect(item.id, isNotEmpty);
        expect(item.title, isNotEmpty);
        expect(item.description, isNotEmpty);
      }
    });

    test('should delete item successfully', () async {
      final initialItems = await itemService.fetchItems();
      final initialCount = initialItems.length;
      final itemToDelete = initialItems.first;

      await itemService.deleteItem(itemToDelete.id);

      final updatedItems = await itemService.fetchItems();
      expect(updatedItems.length, equals(initialCount - 1));
      expect(
        updatedItems.any((item) => item.id == itemToDelete.id),
        isFalse,
      );
    });

    test('should delete multiple items successfully', () async {
      final initialItems = await itemService.fetchItems();
      final firstItem = initialItems[0];
      final secondItem = initialItems[1];

      await itemService.deleteItem(firstItem.id);
      await itemService.deleteItem(secondItem.id);

      final updatedItems = await itemService.fetchItems();
      expect(updatedItems.length, equals(initialItems.length - 2));
      expect(
        updatedItems.any((item) => item.id == firstItem.id),
        isFalse,
      );
      expect(
        updatedItems.any((item) => item.id == secondItem.id),
        isFalse,
      );
    });

    test('should not throw error when deleting non-existent item', () async {
      expect(
        () => itemService.deleteItem('non-existent-id'),
        returnsNormally,
      );
    });

    test('should maintain data integrity after multiple operations', () async {
      final initialItems = await itemService.fetchItems();
      final itemToDelete = initialItems[2];

      await itemService.deleteItem(itemToDelete.id);
      final afterDelete = await itemService.fetchItems();

      expect(afterDelete.length, equals(initialItems.length - 1));
      
      final remainingItems = initialItems
          .where((item) => item.id != itemToDelete.id)
          .toList();
      
      for (final remainingItem in remainingItems) {
        expect(
          afterDelete.any((item) => item.id == remainingItem.id),
          isTrue,
        );
      }
    });

    test('should handle concurrent delete operations', () async {
      final initialItems = await itemService.fetchItems();
      final firstItemId = initialItems[0].id;
      final secondItemId = initialItems[1].id;

      await Future.wait([
        itemService.deleteItem(firstItemId),
        itemService.deleteItem(secondItemId),
      ]);

      final updatedItems = await itemService.fetchItems();
      expect(updatedItems.length, equals(initialItems.length - 2));
    });

    test('should preserve order of remaining items after deletion', () async {
      final initialItems = await itemService.fetchItems();
      final middleItem = initialItems[2];

      await itemService.deleteItem(middleItem.id);
      final updatedItems = await itemService.fetchItems();

      final expectedItems = initialItems
          .where((item) => item.id != middleItem.id)
          .toList();

      expect(updatedItems.length, equals(expectedItems.length));
      for (int i = 0; i < updatedItems.length; i++) {
        expect(updatedItems[i].id, equals(expectedItems[i].id));
      }
    });
  });
}