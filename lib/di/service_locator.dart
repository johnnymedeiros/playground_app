import 'package:get_it/get_it.dart';
import '../services/item_service.dart';
import '../providers/list/item_list_provider.dart';
import '../providers/delete/item_delete_provider.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ItemService>(() => ItemServiceImpl());
  
  getIt.registerFactory<ItemListProvider>(
    () => ItemListProvider(getIt<ItemService>()),
  );
  
  getIt.registerFactory<ItemDeleteProvider>(
    () => ItemDeleteProvider(getIt<ItemService>()),
  );
}

void resetServiceLocator() {
  getIt.reset();
}