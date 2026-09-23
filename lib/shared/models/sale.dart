import 'package:flutter/foundation.dart';

@immutable
class Sale {
  final String id;
  final String userId;
  final String productId;
  final String? productName; // Joined or fetched for display
  final int quantity;
  final double costPrice;
  final double salePrice;
  final double revenue;
  final double profit;
  final String inputMethod; // 'manual' or 'voice'
  final DateTime soldAt;

  const Sale({
    required this.id,
    required this.userId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.costPrice,
    required this.salePrice,
    required this.revenue,
    required this.profit,
    required this.inputMethod,
    required this.soldAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json, {String? productName}) {
    return Sale(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      productName: productName ?? (json['products'] != null ? json['products']['name'] as String? : null),
      quantity: json['quantity'] as int? ?? 1,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      inputMethod: json['input_method'] as String? ?? 'manual',
      soldAt: json['sold_at'] != null
          ? DateTime.parse(json['sold_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'revenue': revenue,
      'profit': profit,
      'input_method': inputMethod,
      'sold_at': soldAt.toIso8601String(),
    };
  }
}
