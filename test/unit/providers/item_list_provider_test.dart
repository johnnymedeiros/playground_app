import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playground_app/presentation/providers/list/item_list_provider.dart';
import 'package:playground_app/data/services/item_service.dart';
import 'package:playground_app/presentation/providers/list/item_list_states.dart';
import 'package:playground_app/models/item.dart';

class MockItemService extends Mock implements ItemService {}

void main() {
  group('ItemListProvider Tests', () {
    late MockItemService mockItemService;
    late ItemListProvider provider;

    const testItems = [
      Item(id: '1', title: 'Item 1', description: 'Description 1'),
      Item(id: '2', title: 'Item 2', description: 'Description 2'),
      Item(id: '3', title: 'Item 3', description: 'Description 3'),
    ];

    setUp(() {
      mockItemService = MockItemService();
      provider = ItemListProvider(mockItemService);
    });

    group('Initial State', () {
      test('should start with ItemListInitialState', () {
        expect(provider.state, isA<ItemListInitialState>());
      });
    });

    group('loadItems', () {
      test('should emit loading then success states when items are loaded', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async => testItems);

        final states = <ItemListStates>[];
        provider.addListener(() {
          states.add(provider.state);
        });

        await provider.loadItems();

        expect(states.length, equals(2));
        expect(states[0], isA<ItemListLoadingState>());
        expect(states[1], isA<ItemListSuccessState>());
        
        final successState = states[1] as ItemListSuccessState;
        expect(successState.items, equals(testItems));
      });

      test('should emit loading then empty states when no items are returned', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async => []);

        final states = <ItemListStates>[];
        provider.addListener(() {
          states.add(provider.state);
        });

        await provider.loadItems();

        expect(states.length, equals(2));
        expect(states[0], isA<ItemListLoadingState>());
        expect(states[1], isA<ItemListEmptyState>());
      });

      test('should emit loading then failure states when service throws error', () async {
        const errorMessage = 'Service error';
        when(() => mockItemService.fetchItems())
            .thenThrow(Exception(errorMessage));

        final states = <ItemListStates>[];
        provider.addListener(() {
          states.add(provider.state);
        });

        await provider.loadItems();

        expect(states.length, equals(2));
        expect(states[0], isA<ItemListLoadingState>());
        expect(states[1], isA<ItemListFailureState>());
        
        final failureState = states[1] as ItemListFailureState;
        expect(failureState.message, contains(errorMessage));
      });

      test('should not emit loading state if already loading', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testItems;
        });

        final states = <ItemListStates>[];
        provider.addListener(() {
          states.add(provider.state);
        });

        final future1 = provider.loadItems();
        final future2 = provider.loadItems();

        await Future.wait([future1, future2]);

        expect(states.whereType<ItemListLoadingState>().length, equals(1));
      });
    });


    group('retry', () {
      test('should call loadItems when retry is called', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async => testItems);

        final states = <ItemListStates>[];
        provider.addListener(() {
          states.add(provider.state);
        });

        provider.retry();
        await Future.delayed(Duration.zero);

        expect(states.length, equals(2));
        expect(states[0], isA<ItemListLoadingState>());
        expect(states[1], isA<ItemListSuccessState>());
        verify(() => mockItemService.fetchItems()).called(1);
      });
    });

    group('Service Integration', () {
      test('should call service methods correctly', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async => testItems);

        await provider.loadItems();

        verify(() => mockItemService.fetchItems()).called(1);
      });

      test('should handle service timing correctly', () async {
        when(() => mockItemService.fetchItems())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testItems;
        });

        final stopwatch = Stopwatch()..start();
        await provider.loadItems();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(50));
        expect(provider.state, isA<ItemListSuccessState>());
      });
    });
  });
}