import 'package:flutter/material.dart';
import '../../services/item_service.dart';
import 'item_list_states.dart';

class ItemListNotifier extends ChangeNotifier {
  ItemListStates _state = ItemListInitialState();

  ItemListStates get state => _state;

  void setState(ItemListStates newState) {
    _state = newState;
    notifyListeners();
  }
}

class ItemListController {
  final ItemService _itemService;
  final ItemListNotifier _notifier;

  ItemListController(this._itemService, this._notifier) {
    // Carrega dados automaticamente quando o controller é criado
    // Evita carregar no build() que causaria múltiplas chamadas
    loadItems();
  }

  ItemListStates get state => _notifier.state;

  Future<void> loadItems() async {
    if (_notifier.state is ItemListLoadingState) return;

    _notifier.setState(ItemListLoadingState());

    try {
      final items = await _itemService.fetchItems();
      
      if (items.isEmpty) {
        _notifier.setState(ItemListEmptyState());
      } else {
        _notifier.setState(ItemListSuccessState(items: items));
      }
    } catch (e) {
      _notifier.setState(ItemListFailureState(message: 'Erro ao carregar itens: $e'));
    }
  }


  void retry() {
    loadItems();
  }

  void refreshAfterDelete() {
    loadItems();
  }
}