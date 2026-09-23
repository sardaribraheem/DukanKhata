import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../../shared/widgets/big_button.dart';
import '../providers/inventory_provider.dart';
import 'add_product_dialog.dart';
import 'restock_dialog.dart';
import 'adjustment_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final onlyFavorites = ref.watch(onlyFavoritesProvider);

    final categories = [
      'All',
      'Oils & Fluids',
      'Parts',
      'Tires',
      'Batteries',
      'Small Items',
      'Other',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'اسٹاک مینجمنٹ / Inventory',
          style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: Icon(
              onlyFavorites ? Icons.star_rounded : Icons.star_border_rounded,
              color: onlyFavorites ? Colors.amber : AppColors.primary,
            ),
            tooltip: 'صرف پسندیدہ / Favorites Only',
            onPressed: () {
              ref.read(onlyFavoritesProvider.notifier).state = !onlyFavorites;
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ریش فریش / Refresh',
            onPressed: () {
              ref.read(inventoryListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'پروڈکٹ تلاش کریں / Search products...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Chips Horizontal Scroll
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = cat;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'کوئی پروڈکٹ نہیں ملا\nNo products found',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BigButton(
                          label: 'نیا پروڈکٹ شامل کریں / Add Product',
                          icon: Icons.add_rounded,
                          backgroundColor: AppColors.primary,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const AddProductDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isLowStock = product.stockQuantity <= 3;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ClayContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Favorite & Icon
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    product.isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: product.isFavorite
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(inventoryListProvider.notifier)
                                        .toggleFavorite(
                                          product.id,
                                          product.isFavorite,
                                        );
                                  },
                                ),
                                const Icon(
                                  Icons.build_circle_outlined,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTypography.headingMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'کیٹیگری: ${product.category}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLowStock
                                              ? AppColors.costRed.withValues(alpha: 0.1)
                                              : AppColors.sellGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isLowStock
                                                ? AppColors.costRed
                                                : AppColors.sellGreen,
                                          ),
                                        ),
                                        child: Text(
                                          'اسٹاک / Stock: ${product.stockQuantity}',
                                          style: AppTypography.caption.copyWith(
                                            color: isLowStock
                                                ? AppColors.costRed
                                                : AppColors.sellGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Rs. ${product.defaultSalePrice.toStringAsFixed(0)}',
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quick Actions (Restock & Adjust)
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.sellGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_shopping_cart,
                                      size: 18),
                                  label: const Text('ری اسٹاک'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => RestockDialog(
                                        product: product,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.tune_rounded, size: 18),
                                  label: const Text('ایڈجسٹ'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AdjustmentDialog(
                                        product: product,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'خرابی: $err',
                  style: const TextStyle(color: AppColors.costRed),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'نیا پروڈکٹ / Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddProductDialog(),
          );
        },
      ),
    );
  }
}
