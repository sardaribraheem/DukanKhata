import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/sale.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(Supabase.instance.client);
});

class SalesRepository {
  final SupabaseClient _client;

  SalesRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch sales recorded today for the current user
  Future<List<Sale>> fetchTodaySales() async {
    if (_userId == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final response = await _client
        .from('sales')
        .select('*, products(name)')
        .eq('user_id', _userId!)
        .gte('sold_at', startOfDay)
        .lte('sold_at', endOfDay)
        .order('sold_at', ascending: false);

    return (response as List).map((json) {
      final pName = json['products'] != null ? json['products']['name'] as String? : null;
      return Sale.fromJson(json, productName: pName);
    }).toList();
  }

  /// Record a new sale transaction and update product stock
  Future<void> recordSale({
    required String productId,
    required int quantity,
    required double salePrice,
    required double costPrice,
    required String inputMethod, // 'manual' or 'voice'
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final revenue = quantity * salePrice;
    final totalCost = quantity * costPrice;
    final profit = revenue - totalCost;

    // 1. Insert sale record
    await _client.from('sales').insert({
      'user_id': _userId,
      'product_id': productId,
      'quantity': quantity,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'revenue': revenue,
      'profit': profit,
      'input_method': inputMethod,
      'sold_at': DateTime.now().toIso8601String(),
    });

    // 2. Fetch current stock and decrement
    final productRes = await _client
        .from('products')
        .select('stock_quantity')
        .eq('id', productId)
        .single();

    final currentStock = productRes['stock_quantity'] as int? ?? 0;
    final newStock = (currentStock - quantity) < 0 ? 0 : (currentStock - quantity);

    await _client.from('products').update({
      'stock_quantity': newStock,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', productId);
  }
}
