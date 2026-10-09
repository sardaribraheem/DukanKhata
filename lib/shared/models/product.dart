import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? photoUrl;
  final double defaultCostPrice;
  final double defaultSalePrice;
  final int stockQuantity;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.photoUrl,
    required this.defaultCostPrice,
    required this.defaultSalePrice,
    required this.stockQuantity,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Other',
      photoUrl: json['photo_url'] as String?,
      defaultCostPrice: (json['default_cost_price'] as num?)?.toDouble() ?? 0.0,
      defaultSalePrice: (json['default_sale_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      isFavorite: json['is_favorite'] is bool
          ? json['is_favorite'] as bool
          : (json['is_favorite'] as num?)?.toInt() == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'photo_url': photoUrl,
      'default_cost_price': defaultCostPrice,
      'default_sale_price': defaultSalePrice,
      'stock_quantity': stockQuantity,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? photoUrl,
    double? defaultCostPrice,
    double? defaultSalePrice,
    int? stockQuantity,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      photoUrl: photoUrl ?? this.photoUrl,
      defaultCostPrice: defaultCostPrice ?? this.defaultCostPrice,
      defaultSalePrice: defaultSalePrice ?? this.defaultSalePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
