import '../../../models/item.dart';

sealed class ItemListStates {}

final class ItemListInitialState implements ItemListStates {}

final class ItemListLoadingState implements ItemListStates {}

final class ItemListSuccessState implements ItemListStates {
  final List<Item> items;

  const ItemListSuccessState({required this.items});

  ItemListSuccessState copyWith({List<Item>? items}) {
    return ItemListSuccessState(items: items ?? this.items);
  }
}

final class ItemListFailureState implements ItemListStates {
  final String message;

  const ItemListFailureState({required this.message});
}

final class ItemListEmptyState implements ItemListStates {}

final class ItemDeletingState implements ItemListStates {
  final String itemId;
  final List<Item> items;

  const ItemDeletingState({
    required this.itemId,
    required this.items,
  });
}