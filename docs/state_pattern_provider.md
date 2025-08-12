# Provider com State Pattern

Este documento explica a implementação do padrão State usando Provider no Flutter para gerenciamento de estado reativo e previsível.

## 📋 Visão Geral

O projeto demonstra como implementar o **State Pattern** com **Provider** para criar uma aplicação com estados bem definidos e UI reativa.

### Funcionalidades
- ✅ **Listagem de itens** com estados de loading, sucesso, erro e vazio
- ✅ **Exclusão de itens** com feedback visual e atualização da lista
- ✅ **Estados tipados** usando sealed classes
- ✅ **UI reativa** com switch expressions modernas

## 🔄 Provider com State Pattern

### Como Funciona
```dart
class ItemListProvider extends ChangeNotifier {
  final ItemService _itemService;
  ItemListStates _state = ItemListInitialState();

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

  void retry() => loadItems();
  void refreshAfterDelete() => loadItems();
}
```

### Características
- **Uma única classe** que herda de `ChangeNotifier`
- **Estado encapsulado** com getter público e setter privado
- **Transições controladas** através do método `_setState`
- **Métodos específicos** para cada ação (load, retry, refresh)

## 🎯 State Pattern Implementado

### Estrutura dos Estados
```dart
abstract class ItemListStates {}

final class ItemListInitialState implements ItemListStates {}

final class ItemListLoadingState implements ItemListStates {}

final class ItemListSuccessState implements ItemListStates {
  final List<Item> items;
  const ItemListSuccessState({required this.items});
  
  ItemListSuccessState copyWith({List<Item>? items}) {
    return ItemListSuccessState(items: items ?? this.items);
  }
}

final class ItemListFailureState implements ItemListStates {
  final String message;
  const ItemListFailureState({required this.message});
}

final class ItemListEmptyState implements ItemListStates {}
```

### Estados de Delete
```dart
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
```

## 📁 Estrutura do Projeto

```
lib/
├── data/
│   └── services/
│       └── item_service.dart            # Camada de serviços
├── models/
│   └── item.dart                        # Modelos de dados
├── presentation/
│   ├── providers/
│   │   ├── list/                        # 📂 Provider de listagem
│   │   │   ├── item_list_provider.dart      # Provider com lógica
│   │   │   └── item_list_states.dart        # Estados da listagem
│   │   └── delete/                      # 📂 Provider de delete
│   │       ├── item_delete_provider.dart    # Provider de exclusão
│   │       └── item_delete_states.dart      # Estados do delete
│   └── screens/
│       ├── home_screen.dart             # Tela inicial
│       └── item_list_screen.dart        # Tela com lista de itens
├── di/
│   └── service_locator.dart             # Injeção de dependências
└── main.dart                            # Ponto de entrada
```

### Vantagens dessa Organização

**📂 Separação por Camadas**:
- `data/` - Serviços (acesso a dados)
- `models/` - Modelos de dados
- `presentation/` - UI e providers (apresentação)
- `di/` - Injeção de dependências

**🔍 Fácil Localização**:
- Cada funcionalidade tem sua pasta dedicada
- Estados próximos dos providers que os usam

**📈 Escalabilidade**:
- Novas funcionalidades seguem o mesmo padrão
- Fácil adicionar novos providers e estados

## ⚙️ Configuração com GetIt

```dart
void setupServiceLocator() {
  // Serviço singleton
  getIt.registerLazySingleton<ItemService>(() => ItemServiceImpl());
  
  // Providers factory (nova instância a cada uso)
  getIt.registerFactory<ItemListProvider>(
    () => ItemListProvider(getIt<ItemService>()),
  );
  
  getIt.registerFactory<ItemDeleteProvider>(
    () => ItemDeleteProvider(getIt<ItemService>()),
  );
}
```

### Uso na UI
```dart
MultiProvider(
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
      return _buildUI(listProvider.state, deleteProvider.state);
    },
  ),
)
```

## 🎯 Switch Expression para Estados

A UI usa o moderno **switch expression** do Dart 3 para renderização reativa:

```dart
Widget _buildStateWidget(ItemListStates state) {
  return switch (state) {
    ItemListInitialState() => const Center(
      child: Text('Inicializando...'),
    ),
    ItemListLoadingState() => const Center(
      child: CircularProgressIndicator(),
    ),
    ItemListSuccessState(:final items) => _buildItemList(items),
    ItemListFailureState(:final message) => _buildError(message),
    ItemListEmptyState() => _buildEmpty(),
    _ => const Text('Estado desconhecido'),
  };
}
```

### Vantagens do Switch Expression
✅ **Exhaustividade**: Garantia de tratar todos os estados
✅ **Pattern Matching**: Extração direta de propriedades com `(:final items)`
✅ **Legibilidade**: Código mais limpo e expressivo
✅ **Performance**: Otimizado pelo compilador

## 🔄 Fluxo de Estados

### Estados da Lista
```
ItemListInitialState
         ↓ loadItems()
ItemListLoadingState
         ↓
    ┌────────────────┐
    ↓                ↓
ItemListSuccessState  ItemListFailureState
    ↓                ↓
ItemListEmptyState   retry() → volta ao Loading
```

### Estados do Delete
```
ItemDeleteInitialState
         ↓ deleteItem()
ItemDeleteLoadingState(itemId)
         ↓
    ┌────────────────────┐
    ↓                    ↓
ItemDeleteSuccessState   ItemDeleteFailureState
    ↓                    
refresh da lista
```

## ✅ Melhores Práticas Implementadas

### 1. **Estados Imutáveis**
```dart
final class ItemListSuccessState implements ItemListStates {
  final List<Item> items;
  const ItemListSuccessState({required this.items});
}
```

### 2. **Encapsulamento de Estado**
```dart
class ItemListProvider extends ChangeNotifier {
  ItemListStates _state = ItemListInitialState(); // Privado
  ItemListStates get state => _state;              // Público apenas leitura

  void _setState(ItemListStates newState) {        // Controle centralizado
    _state = newState;
    notifyListeners();
  }
}
```

### 3. **Carregamento no Create**
```dart
ChangeNotifierProvider(
  create: (_) => getIt<ItemListProvider>()..loadItems(), // Uma única vez
  child: Consumer<ItemListProvider>(...),
)
```

### 4. **Prevenção de Múltiplas Chamadas**
```dart
Future<void> loadItems() async {
  if (_state is ItemListLoadingState) return; // Evita chamadas paralelas
  
  _setState(ItemListLoadingState());
  // ... resto da implementação
}
```

### 5. **Tratamento de Erro Consistente**
```dart
try {
  final items = await _itemService.fetchItems();
  _setState(ItemListSuccessState(items: items));
} catch (e) {
  _setState(ItemListFailureState(message: 'Erro ao carregar: $e'));
}
```

## 🧪 Benefícios do State Pattern

### Para o Desenvolvimento
✅ **Previsibilidade**: Estados bem definidos eliminam bugs de estado inconsistente
✅ **Debuging**: Fácil rastrear qual estado causou um problema
✅ **Manutenibilidade**: Adicionar novos estados é simples e seguro
✅ **Testabilidade**: Estados são objetos testáveis isoladamente

### Para a UI
✅ **UI Reativa**: Interface sempre reflete o estado atual
✅ **Loading States**: Feedback visual durante operações assíncronas
✅ **Error Handling**: Tratamento consistente de erros
✅ **Empty States**: UX melhorada para listas vazias

## 📊 Resumo da Implementação

| Aspecto | Implementação |
|---------|---------------|
| **Pattern** | State Pattern |
| **Framework** | Provider + ChangeNotifier |
| **Estados** | Sealed classes com final |
| **UI** | Switch expressions |
| **DI** | GetIt com factory registration |
| **Estrutura** | Separação por camadas |
| **Performance** | Carregamento único + prevenção de calls paralelas |
| **Manutenibilidade** | Estados tipados + encapsulamento |

## 🎯 Conclusão

Esta implementação demonstra como usar o **State Pattern com Provider** de forma eficiente no Flutter:

- **Estados bem definidos** garantem previsibilidade
- **Provider simples** oferece performance e simplicidade  
- **Switch expressions** proporcionam UI reativa e legível
- **Estrutura organizada** facilita manutenção e escalabilidade

O resultado é uma aplicação robusta, testável e fácil de manter, seguindo as melhores práticas do Flutter e Dart moderno.