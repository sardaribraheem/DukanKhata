import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Product>> fetchProducts({
    String? category,
    String? searchQuery,
    bool onlyFavorites = false,
  }) async {
    var query = _client.from('products').select();

    if (_userId != null) {
      query = query.eq('user_id', _userId!);
    }

    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }

    if (onlyFavorites) {
      query = query.eq('is_favorite', true);
    }

    final response = await query.order('name', ascending: true);
    final list = (response as List).map((e) => Product.fromJson(e)).toList();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      return list.where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  Future<void> addProduct({
    required String name,
    required String category,
    String? photoUrl,
    required double defaultCostPrice,
    required double defaultSalePrice,
    required int initialStock,
    required bool isFavorite,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _client.from('products').insert({
      'user_id': _userId,
      'name': name.trim(),
      'category': category,
      'photo_url': photoUrl,
      'default_cost_price': defaultCostPrice,
      'default_sale_price': defaultSalePrice,
      'stock_quantity': initialStock,
      'is_favorite': isFavorite,
    });

    // If initial stock > 0, also record an initial stock purchase
    if (initialStock > 0) {
      // Get the newly inserted product ID
      final res = await _client
          .from('products')
          .select('id')
          .eq('user_id', _userId!)
          .eq('name', name.trim())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        final productId = res['id'] as String;
        await _client.from('stock_purchases').insert({
          'user_id': _userId,
          'product_id': productId,
          'quantity': initialStock,
          'purchase_price': defaultCostPrice,
          'total_cost': initialStock * defaultCostPrice,
        });
      }
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String category,
    String? photoUrl,
    required double defaultCostPrice,
    required double defaultSalePrice,
    required bool isFavorite,
  }) async {
    await _client.from('products').update({
      'name': name.trim(),
      'category': category,
      'photo_url': photoUrl,
      'default_cost_price': defaultCostPrice,
      'default_sale_price': defaultSalePrice,
      'is_favorite': isFavorite,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> toggleFavorite(String id, bool currentStatus) async {
    await _client.from('products').update({
      'is_favorite': !currentStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> restockProduct({
    required String productId,
    required int quantity,
    required double purchasePrice,
    required int currentStock,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    // 1. Insert stock purchase
    await _client.from('stock_purchases').insert({
      'user_id': _userId,
      'product_id': productId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'total_cost': quantity * purchasePrice,
    });

    // 2. Update stock quantity on product
    final newStock = currentStock + quantity;
    await _client.from('products').update({
      'stock_quantity': newStock,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', productId);
  }

  Future<void> adjustInventory({
    required String productId,
    required int quantityChange,
    required String reason,
    required int currentStock,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    // 1. Insert inventory adjustment
    await _client.from('inventory_adjustments').insert({
      'user_id': _userId,
      'product_id': productId,
      'quantity_change': quantityChange,
      'reason': reason,
    });

    // 2. Update stock quantity
    final newStock = currentStock + quantityChange;
    await _client.from('products').update({
      'stock_quantity': newStock < 0 ? 0 : newStock,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', productId);
  }
}
