import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/product.dart';
import '../data/product_repository.dart';

// Filter providers
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');
final onlyFavoritesProvider = StateProvider<bool>((ref) => false);

// Inventory product list provider
final inventoryListProvider = AsyncNotifierProvider<InventoryListNotifier, List<Product>>(
  InventoryListNotifier.new,
);

class InventoryListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    final search = ref.watch(searchQueryProvider);
    final favorites = ref.watch(onlyFavoritesProvider);

    final repo = ref.watch(productRepositoryProvider);
    return repo.fetchProducts(
      category: category,
      searchQuery: search,
      onlyFavorites: favorites,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final category = ref.read(selectedCategoryProvider);
      final search = ref.read(searchQueryProvider);
      final favorites = ref.read(onlyFavoritesProvider);

      final repo = ref.read(productRepositoryProvider);
      return repo.fetchProducts(
        category: category,
        searchQuery: search,
        onlyFavorites: favorites,
      );
    });
  }

  Future<bool> addProduct({
    required String name,
    required String category,
    String? photoUrl,
    required double defaultCostPrice,
    required double defaultSalePrice,
    required int initialStock,
    required bool isFavorite,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.addProduct(
        name: name,
        category: category,
        photoUrl: photoUrl,
        defaultCostPrice: defaultCostPrice,
        defaultSalePrice: defaultSalePrice,
        initialStock: initialStock,
        isFavorite: isFavorite,
      );
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String category,
    String? photoUrl,
    required double defaultCostPrice,
    required double defaultSalePrice,
    required bool isFavorite,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(
        id: id,
        name: name,
        category: category,
        photoUrl: photoUrl,
        defaultCostPrice: defaultCostPrice,
        defaultSalePrice: defaultSalePrice,
        isFavorite: isFavorite,
      );
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFavorite(String id, bool currentStatus) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.toggleFavorite(id, currentStatus);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restockProduct({
    required String productId,
    required int quantity,
    required double purchasePrice,
    required int currentStock,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.restockProduct(
        productId: productId,
        quantity: quantity,
        purchasePrice: purchasePrice,
        currentStock: currentStock,
      );
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> adjustInventory({
    required String productId,
    required int quantityChange,
    required String reason,
    required int currentStock,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.adjustInventory(
        productId: productId,
        quantityChange: quantityChange,
        reason: reason,
        currentStock: currentStock,
      );
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}
