abstract class ItemDeleteStates {}

final class ItemDeleteInitialState implements ItemDeleteStates {}

final class ItemDeleteLoadingState implements ItemDeleteStates {
  final String itemId;
  const ItemDeleteLoadingState({required this.itemId});
}

final class ItemDeleteSuccessState implements ItemDeleteStates {
  final String deletedItemId;
  const ItemDeleteSuccessState({required this.deletedItemId});
}

final class ItemDeleteFailureState implements ItemDeleteStates {
  final String message;
  final String itemId;
  const ItemDeleteFailureState({required this.message, required this.itemId});
}