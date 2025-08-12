import 'package:get_it/get_it.dart';
import '../services/item_service.dart';
import '../providers/list/item_list_provider.dart';
import '../providers/list/item_list_proxy_provider.dart';
import '../providers/delete/item_delete_provider.dart';
import '../providers/delete/item_delete_proxy_provider.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ItemService>(() => ItemServiceImpl());
  
  getIt.registerFactory<ItemListProvider>(
    () => ItemListProvider(getIt<ItemService>()),
  );
  
  getIt.registerFactory<ItemListNotifier>(() => ItemListNotifier());
  
  getIt.registerFactory<ItemListController>(
    () => ItemListController(
      getIt<ItemService>(),
      getIt<ItemListNotifier>(),
    ),
  );
  
  // Delete providers - Provider Simples
  getIt.registerFactory<ItemDeleteProvider>(
    () => ItemDeleteProvider(getIt<ItemService>()),
  );
  
  // Delete providers - ProxyProvider
  getIt.registerFactory<ItemDeleteNotifier>(() => ItemDeleteNotifier());
  
  getIt.registerFactory<ItemDeleteController>(
    () => ItemDeleteController(
      getIt<ItemService>(),
      getIt<ItemDeleteNotifier>(),
    ),
  );
}

void resetServiceLocator() {
  getIt.reset();
}