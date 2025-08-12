import 'package:flutter_test/flutter_test.dart';
import 'package:playground_app/models/item.dart';

void main() {
  group('Item Model Tests', () {
    const testItem = Item(
      id: '1',
      title: 'Test Item',
      description: 'Test Description',
    );

    test('should create an Item with all properties', () {
      expect(testItem.id, equals('1'));
      expect(testItem.title, equals('Test Item'));
      expect(testItem.description, equals('Test Description'));
    });

    test('should create copy with modified properties', () {
      final copiedItem = testItem.copyWith(
        title: 'Modified Title',
        description: 'Modified Description',
      );

      expect(copiedItem.id, equals('1'));
      expect(copiedItem.title, equals('Modified Title'));
      expect(copiedItem.description, equals('Modified Description'));
    });

    test('should create copy with same properties when no changes', () {
      final copiedItem = testItem.copyWith();

      expect(copiedItem.id, equals(testItem.id));
      expect(copiedItem.title, equals(testItem.title));
      expect(copiedItem.description, equals(testItem.description));
    });

    test('should be equal when ids are the same', () {
      const item1 = Item(
        id: '1',
        title: 'Item 1',
        description: 'Description 1',
      );
      const item2 = Item(
        id: '1',
        title: 'Item 2',
        description: 'Description 2',
      );

      expect(item1, equals(item2));
    });

    test('should not be equal when ids are different', () {
      const item1 = Item(
        id: '1',
        title: 'Same Title',
        description: 'Same Description',
      );
      const item2 = Item(
        id: '2',
        title: 'Same Title',
        description: 'Same Description',
      );

      expect(item1, isNot(equals(item2)));
    });

    test('should have same hashCode when ids are the same', () {
      const item1 = Item(
        id: '1',
        title: 'Item 1',
        description: 'Description 1',
      );
      const item2 = Item(
        id: '1',
        title: 'Item 2',
        description: 'Description 2',
      );

      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should have different hashCode when ids are different', () {
      const item1 = Item(id: '1', title: 'Item', description: 'Desc');
      const item2 = Item(id: '2', title: 'Item', description: 'Desc');

      expect(item1.hashCode, isNot(equals(item2.hashCode)));
    });
  });
}