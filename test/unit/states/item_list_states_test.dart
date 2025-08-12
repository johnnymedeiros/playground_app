import 'package:flutter_test/flutter_test.dart';
import 'package:playground_app/providers/list/item_list_states.dart';
import 'package:playground_app/models/item.dart';

void main() {
  group('ItemListStates Tests', () {
    const testItems = [
      Item(id: '1', title: 'Item 1', description: 'Description 1'),
      Item(id: '2', title: 'Item 2', description: 'Description 2'),
    ];

    group('ItemListInitialState', () {
      test('should be instance of ItemListStates', () {
        final state = ItemListInitialState();
        expect(state, isA<ItemListStates>());
      });

      test('should be equal for different instances', () {
        final state1 = ItemListInitialState();
        final state2 = ItemListInitialState();
        expect(state1, equals(state2));
      });
    });

    group('ItemListLoadingState', () {
      test('should be instance of ItemListStates', () {
        final state = ItemListLoadingState();
        expect(state, isA<ItemListStates>());
      });

      test('should be equal for different instances', () {
        final state1 = ItemListLoadingState();
        final state2 = ItemListLoadingState();
        expect(state1, equals(state2));
      });
    });

    group('ItemListSuccessState', () {
      test('should be instance of ItemListStates', () {
        const state = ItemListSuccessState(items: testItems);
        expect(state, isA<ItemListStates>());
      });

      test('should store items correctly', () {
        const state = ItemListSuccessState(items: testItems);
        expect(state.items, equals(testItems));
        expect(state.items.length, equals(2));
      });

      test('should create copy with new items', () {
        const originalState = ItemListSuccessState(items: testItems);
        const newItems = [
          Item(id: '3', title: 'Item 3', description: 'Description 3'),
        ];
        final copiedState = originalState.copyWith(items: newItems);

        expect(copiedState.items, equals(newItems));
        expect(copiedState.items.length, equals(1));
        expect(originalState.items, equals(testItems));
      });

      test('should create copy with same items when no changes', () {
        const originalState = ItemListSuccessState(items: testItems);
        final copiedState = originalState.copyWith();

        expect(copiedState.items, equals(originalState.items));
      });

      test('should handle empty items list', () {
        const state = ItemListSuccessState(items: []);
        expect(state.items, isEmpty);
      });
    });

    group('ItemListFailureState', () {
      const errorMessage = 'Test error message';

      test('should be instance of ItemListStates', () {
        const state = ItemListFailureState(message: errorMessage);
        expect(state, isA<ItemListStates>());
      });

      test('should store error message correctly', () {
        const state = ItemListFailureState(message: errorMessage);
        expect(state.message, equals(errorMessage));
      });

      test('should be equal when messages are the same', () {
        const state1 = ItemListFailureState(message: errorMessage);
        const state2 = ItemListFailureState(message: errorMessage);
        expect(state1.message, equals(state2.message));
      });

      test('should handle empty error message', () {
        const state = ItemListFailureState(message: '');
        expect(state.message, equals(''));
      });
    });

    group('ItemListEmptyState', () {
      test('should be instance of ItemListStates', () {
        final state = ItemListEmptyState();
        expect(state, isA<ItemListStates>());
      });

      test('should be equal for different instances', () {
        final state1 = ItemListEmptyState();
        final state2 = ItemListEmptyState();
        expect(state1, equals(state2));
      });
    });

    group('ItemDeletingState', () {
      const itemId = '1';

      test('should be instance of ItemListStates', () {
        const state = ItemDeletingState(itemId: itemId, items: testItems);
        expect(state, isA<ItemListStates>());
      });

      test('should store itemId and items correctly', () {
        const state = ItemDeletingState(itemId: itemId, items: testItems);
        expect(state.itemId, equals(itemId));
        expect(state.items, equals(testItems));
      });

      test('should handle empty items list', () {
        const state = ItemDeletingState(itemId: itemId, items: []);
        expect(state.itemId, equals(itemId));
        expect(state.items, isEmpty);
      });

      test('should store different itemIds correctly', () {
        const state1 = ItemDeletingState(itemId: '1', items: testItems);
        const state2 = ItemDeletingState(itemId: '2', items: testItems);
        
        expect(state1.itemId, equals('1'));
        expect(state2.itemId, equals('2'));
        expect(state1.itemId, isNot(equals(state2.itemId)));
      });
    });

    group('State Type Checking', () {
      test('should distinguish between different state types', () {
        final initial = ItemListInitialState();
        final loading = ItemListLoadingState();
        const success = ItemListSuccessState(items: testItems);
        const failure = ItemListFailureState(message: 'Error');
        final empty = ItemListEmptyState();
        const deleting = ItemDeletingState(itemId: '1', items: testItems);

        expect(initial, isA<ItemListInitialState>());
        expect(loading, isA<ItemListLoadingState>());
        expect(success, isA<ItemListSuccessState>());
        expect(failure, isA<ItemListFailureState>());
        expect(empty, isA<ItemListEmptyState>());
        expect(deleting, isA<ItemDeletingState>());

        expect(initial, isNot(isA<ItemListLoadingState>()));
        expect(success, isNot(isA<ItemListFailureState>()));
        expect(deleting, isNot(isA<ItemListEmptyState>()));
      });
    });
  });
}