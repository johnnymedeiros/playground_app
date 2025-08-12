import '../models/item.dart';

abstract class ItemService {
  Future<List<Item>> fetchItems();
  Future<void> deleteItem(String itemId);
}

class ItemServiceImpl implements ItemService {
  final List<Item> _items = [
    const Item(
      id: '1',
      title: 'Tarefa 1',
      description: 'Primeira tarefa da lista',
    ),
    const Item(
      id: '2',
      title: 'Tarefa 2',
      description: 'Segunda tarefa da lista',
    ),
    const Item(
      id: '3',
      title: 'Tarefa 3',
      description: 'Terceira tarefa da lista',
    ),
    const Item(
      id: '4',
      title: 'Tarefa 4',
      description: 'Quarta tarefa da lista',
    ),
    const Item(
      id: '5',
      title: 'Tarefa 5',
      description: 'Quinta tarefa da lista',
    ),
  ];

  @override
  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_items);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _items.removeWhere((item) => item.id == itemId);
  }
}