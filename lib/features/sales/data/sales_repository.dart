import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/storage/local_database.dart';
import '../../../shared/models/sale.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(LocalDatabase.instance);
});

class SalesRepository {
  final LocalDatabase _localDatabase;

  SalesRepository(this._localDatabase);

  Future<List<Sale>> fetchSalesForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return fetchSalesForRange(start, end);
  }

  Future<List<Sale>> fetchTodaySales() => fetchSalesForDay(DateTime.now());

  Future<List<Sale>> fetchSalesForLast30Days([DateTime? endDate]) {
    final endDay = endDate ?? DateTime.now();
    final end = DateTime(endDay.year, endDay.month, endDay.day + 1);
    return fetchSalesForRange(end.subtract(const Duration(days: 30)), end);
  }

  Future<List<Sale>> fetchSalesForRange(DateTime start, DateTime end) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'sales',
      where: 'sold_at >= ? AND sold_at < ?',
      whereArgs: [
        start.toUtc().toIso8601String(),
        end.toUtc().toIso8601String(),
      ],
      orderBy: 'sold_at DESC',
    );
    final sales = rows.map(Sale.fromJson).toList();
    await _localDatabase.log('KHATA LOADED', {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'transactions': sales.length,
    });
    return sales;
  }

  Future<void> recordSale({
    required String productId,
    required int quantity,
    required double salePrice,
    required double costPrice,
    required String inputMethod,
  }) async {
    if (quantity <= 0 || salePrice <= 0 || costPrice < 0) {
      throw ArgumentError('Invalid sale values');
    }
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc();
    final revenue = quantity * salePrice;
    final totalCost = quantity * costPrice;
    final profit = revenue - totalCost;
    await db.transaction((txn) async {
      final products = await txn.query(
        'products',
        columns: ['name', 'stock_quantity'],
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      if (products.isEmpty) throw StateError('Product not found');
      final product = products.single;
      final stock = (product['stock_quantity'] as num?)?.toInt() ?? 0;
      if (stock < quantity) throw StateError('Insufficient stock');
      await txn.insert('sales', {
        'id': 'sale-${now.microsecondsSinceEpoch}',
        'user_id': localUserId,
        'product_id': productId,
        'product_name_snapshot': product['name'],
        'quantity': quantity,
        'cost_price': costPrice,
        'sale_price': salePrice,
        'revenue': revenue,
        'profit': profit,
        'input_method': inputMethod,
        'sold_at': now.toIso8601String(),
      });
      await txn.update(
        'products',
        {
          'stock_quantity': stock - quantity,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    });
    final values = {
      'product_id': productId,
      'quantity': quantity,
      'sale_price': salePrice,
      'revenue': revenue,
      'cost': totalCost,
      'profit': profit,
      'timestamp': now.toIso8601String(),
    };
    AppLogger.saved('SALE', values);
    await _localDatabase.log('SALE SAVED', values);
  }
}
