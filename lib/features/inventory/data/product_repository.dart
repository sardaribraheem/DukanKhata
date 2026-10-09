import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/storage/local_database.dart';
import '../../../shared/models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(LocalDatabase.instance);
});

class ProductRepository {
  final LocalDatabase _localDatabase;

  ProductRepository(this._localDatabase);

  Future<List<Product>> fetchProducts({
    String? category,
    String? searchQuery,
    bool onlyFavorites = false,
  }) async {
    final db = await _localDatabase.database;
    final filters = <String>[];
    final args = <Object?>[];
    if (category != null && category != 'All') {
      filters.add('category = ?');
      args.add(category);
    }
    if (onlyFavorites) filters.add('is_favorite = 1');
    final rows = await db.query(
      'products',
      where: filters.isEmpty ? null : filters.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    final products = rows.map(Product.fromJson).toList();
    final query = searchQuery?.trim().toLowerCase();
    if (query == null || query.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList();
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
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'product-${DateTime.now().microsecondsSinceEpoch}';
    await db.transaction((txn) async {
      await txn.insert('products', {
        'id': id,
        'user_id': localUserId,
        'name': name.trim(),
        'category': category,
        'photo_url': photoUrl,
        'default_cost_price': defaultCostPrice,
        'default_sale_price': defaultSalePrice,
        'stock_quantity': initialStock,
        'is_favorite': isFavorite ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      });
      if (initialStock > 0) {
        await txn.insert('stock_purchases', {
          'product_id': id,
          'quantity': initialStock,
          'purchase_price': defaultCostPrice,
          'total_cost': initialStock * defaultCostPrice,
          'created_at': now,
        });
      }
    });
    await _log('PRODUCT CREATED', {'product_id': id, 'name': name.trim()});
    if (initialStock > 0) {
      await _log('RESTOCK SAVED', {'product_id': id, 'quantity': initialStock});
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
    final db = await _localDatabase.database;
    await db.update(
      'products',
      {
        'name': name.trim(),
        'category': category,
        'photo_url': photoUrl,
        'default_cost_price': defaultCostPrice,
        'default_sale_price': defaultSalePrice,
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _log('PRODUCT EDITED', {'product_id': id, 'name': name.trim()});
  }

  Future<void> toggleFavorite(String id, bool currentStatus) async {
    final db = await _localDatabase.database;
    await db.update(
      'products',
      {
        'is_favorite': currentStatus ? 0 : 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restockProduct({
    required String productId,
    required int quantity,
    required double purchasePrice,
  }) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        columns: ['stock_quantity'],
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Product not found');
      final currentStock =
          (rows.single['stock_quantity'] as num?)?.toInt() ?? 0;
      await txn.insert('stock_purchases', {
        'product_id': productId,
        'quantity': quantity,
        'purchase_price': purchasePrice,
        'total_cost': quantity * purchasePrice,
        'created_at': now,
      });
      await txn.update(
        'products',
        {'stock_quantity': currentStock + quantity, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [productId],
      );
    });
    await _log('RESTOCK SAVED', {
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> adjustInventory({
    required String productId,
    required int quantityChange,
    required String reason,
  }) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        columns: ['stock_quantity'],
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Product not found');
      final currentStock =
          (rows.single['stock_quantity'] as num?)?.toInt() ?? 0;
      await txn.insert('inventory_adjustments', {
        'product_id': productId,
        'quantity_change': quantityChange,
        'reason': reason,
        'created_at': now,
      });
      await txn.update(
        'products',
        {
          'stock_quantity': (currentStock + quantityChange).clamp(0, 1 << 30),
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    });
    await _log('INVENTORY ADJUSTMENT SAVED', {
      'product_id': productId,
      'quantity_change': quantityChange,
    });
  }

  Future<void> _log(String event, Map<String, Object?> values) async {
    AppLogger.business(event, values);
    await _localDatabase.log(event, values);
  }
}
