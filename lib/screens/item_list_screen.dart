import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../di/service_locator.dart';
import '../models/item.dart';
import '../providers/list/item_list_provider.dart';
import '../providers/delete/item_delete_provider.dart';
import '../providers/list/item_list_states.dart';
import '../providers/delete/item_delete_states.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Itens - Provider'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => getIt<ItemListProvider>()..loadItems(),
          ),
          ChangeNotifierProvider(
            create: (_) => getIt<ItemDeleteProvider>(),
          ),
        ],
        child: Consumer2<ItemListProvider, ItemDeleteProvider>(
          builder: (context, listProvider, deleteProvider, child) {
            return _buildStateWidget(context, listProvider.state, listProvider, deleteProvider);
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget(
    BuildContext context,
    ItemListStates state,
    ItemListProvider listProvider,
    ItemDeleteProvider deleteProvider,
  ) {
    return switch (state) {
      ItemListInitialState() => const Center(
          child: Text('Inicializando...'),
        ),
      
      ItemListLoadingState() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando itens...'),
            ],
          ),
        ),
      
      ItemListSuccessState(:final items) => 
        _buildItemList(context, items, listProvider, deleteProvider),
      
      ItemListEmptyState() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text('Nenhum item encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: listProvider.retry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      
      ItemListFailureState(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: listProvider.retry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      
      
      _ => const Center(
          child: Text('Estado desconhecido'),
        ),
    };
  }

  Widget _buildItemList(
    BuildContext context,
    List<Item> items,
    ItemListProvider listProvider,
    ItemDeleteProvider deleteProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            trailing: _buildDeleteButton(context, item, deleteProvider, listProvider),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    Item item,
    ItemDeleteProvider deleteProvider,
    ItemListProvider listProvider,
  ) {
    return switch (deleteProvider.state) {
      ItemDeleteLoadingState(:final itemId) when itemId == item.id => 
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      _ => IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteConfirmation(
          context,
          item,
          deleteProvider,
          listProvider,
        ),
      ),
    };
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Item item,
    ItemDeleteProvider deleteProvider,
    ItemListProvider listProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja excluir "${item.title}"?'),
            const SizedBox(height: 8),
            const Text(
              'Demonstração: Provider Simples conectado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteProvider.deleteItem(
                item.id,
                onSuccess: listProvider.refreshAfterDelete,
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}