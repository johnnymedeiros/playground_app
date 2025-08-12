import 'package:flutter/material.dart';
import '../../../services/item_service.dart';
import 'item_list_states.dart';

class ItemListProvider extends ChangeNotifier {
  final ItemService _itemService;
  ItemListStates _state = ItemListInitialState();

  ItemListProvider(this._itemService);

  ItemListStates get state => _state;

  void _setState(ItemListStates newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadItems() async {
    if (_state is ItemListLoadingState) return;

    _setState(ItemListLoadingState());

    try {
      final items = await _itemService.fetchItems();
      
      if (items.isEmpty) {
        _setState(ItemListEmptyState());
      } else {
        _setState(ItemListSuccessState(items: items));
      }
    } catch (e) {
      _setState(ItemListFailureState(message: 'Erro ao carregar itens: $e'));
    }
  }


  void retry() {
    loadItems();
  }

  void refreshAfterDelete() {
    loadItems();
  }
}