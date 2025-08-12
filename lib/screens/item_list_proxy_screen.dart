import 'package:flutter/material.dart';
import 'package:playground_app/services/item_service.dart';
import 'package:provider/provider.dart';
import '../di/service_locator.dart';
import '../models/item.dart';
import '../providers/list/item_list_proxy_provider.dart';
import '../providers/delete/item_delete_proxy_provider.dart';
import '../providers/list/item_list_states.dart';
import '../providers/delete/item_delete_states.dart';

class ItemListProxyScreen extends StatelessWidget {
  const ItemListProxyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Itens - ProxyProvider'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: MultiProvider(
        providers: [
          // List providers
          ChangeNotifierProvider(
            create: (_) => getIt<ItemListNotifier>(),
          ),
          ProxyProvider<ItemListNotifier, ItemListController>(
            update: (_, notifier, __) => ItemListController(
              getIt<ItemService>(),
              notifier,
            ),
          ),
          // Delete providers
          ChangeNotifierProvider(
            create: (_) => getIt<ItemDeleteNotifier>(),
          ),
          ProxyProvider<ItemDeleteNotifier, ItemDeleteController>(
            update: (_, notifier, __) => ItemDeleteController(
              getIt<ItemService>(),
              notifier,
            ),
          ),
        ],
        child: Consumer2<ItemListController, ItemDeleteController>(
          builder: (context, listController, deleteController, child) {
            return _buildStateWidget(context, listController.state, listController, deleteController);
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget(
    BuildContext context,
    ItemListStates state,
    ItemListController listController,
    ItemDeleteController deleteController,
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
        _buildItemList(context, items, listController, deleteController),
      
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
                onPressed: listController.retry,
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
                onPressed: listController.retry,
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
    ItemListController listController,
    ItemDeleteController deleteController,
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
            trailing: _buildDeleteButton(context, item, deleteController, listController),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    Item item,
    ItemDeleteController deleteController,
    ItemListController listController,
  ) {
    return switch (deleteController.state) {
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
          deleteController,
          listController,
        ),
      ),
    };
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Item item,
    ItemDeleteController deleteController,
    ItemListController listController,
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
              'Demonstração: ProxyProvider conectado',
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
              deleteController.deleteItem(
                item.id,
                onSuccess: listController.refreshAfterDelete,
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}