import 'package:flutter/material.dart';
import '../../services/item_service.dart';
import 'item_delete_states.dart';

class ItemDeleteNotifier extends ChangeNotifier {
  ItemDeleteStates _state = ItemDeleteInitialState();

  ItemDeleteStates get state => _state;

  void setState(ItemDeleteStates newState) {
    _state = newState;
    notifyListeners();
  }
}

class ItemDeleteController {
  final ItemService _itemService;
  final ItemDeleteNotifier _notifier;

  ItemDeleteController(this._itemService, this._notifier);

  ItemDeleteStates get state => _notifier.state;

  Future<void> deleteItem(String itemId, {VoidCallback? onSuccess}) async {
    _notifier.setState(ItemDeleteLoadingState(itemId: itemId));

    try {
      await _itemService.deleteItem(itemId);
      _notifier.setState(ItemDeleteSuccessState(deletedItemId: itemId));
      
      // Chama callback para atualizar o controller de lista
      onSuccess?.call();
    } catch (e) {
      _notifier.setState(ItemDeleteFailureState(
        message: 'Erro ao deletar item: $e',
        itemId: itemId,
      ));
    }
  }

  void resetState() {
    _notifier.setState(ItemDeleteInitialState());
  }
}