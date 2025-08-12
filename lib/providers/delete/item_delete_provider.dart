import 'package:flutter/material.dart';
import '../../services/item_service.dart';
import 'item_delete_states.dart';

class ItemDeleteProvider extends ChangeNotifier {
  final ItemService _itemService;
  ItemDeleteStates _state = ItemDeleteInitialState();

  ItemDeleteProvider(this._itemService);

  ItemDeleteStates get state => _state;

  void _setState(ItemDeleteStates newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> deleteItem(String itemId, {VoidCallback? onSuccess}) async {
    _setState(ItemDeleteLoadingState(itemId: itemId));

    try {
      await _itemService.deleteItem(itemId);
      _setState(ItemDeleteSuccessState(deletedItemId: itemId));
      
      // Chama callback para atualizar o provider de lista
      onSuccess?.call();
    } catch (e) {
      _setState(ItemDeleteFailureState(
        message: 'Erro ao deletar item: $e',
        itemId: itemId,
      ));
    }
  }

  void resetState() {
    _setState(ItemDeleteInitialState());
  }
}