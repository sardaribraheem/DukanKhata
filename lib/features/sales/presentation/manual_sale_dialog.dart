import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../providers/sales_provider.dart';

class ManualSaleDialog extends ConsumerStatefulWidget {
  final Product? initialProduct;

  const ManualSaleDialog({super.key, this.initialProduct});

  @override
  ConsumerState<ManualSaleDialog> createState() => _ManualSaleDialogState();
}

class _ManualSaleDialogState extends ConsumerState<ManualSaleDialog> {
  Product? _selectedProduct;
  int _quantity = 1;
  late final TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
    _priceController = TextEditingController(
      text: _selectedProduct?.defaultSalePrice.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _onProductChanged(Product? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _priceController.text = product.defaultSalePrice.toStringAsFixed(0);
      }
    });
  }

  Future<void> _confirmSale() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم پروڈکٹ منتخب کریں / Please select a product'),
          backgroundColor: AppColors.costRed,
        ),
      );
      return;
    }

    final salePrice = double.tryParse(_priceController.text.trim()) ?? _selectedProduct!.defaultSalePrice;
    if (salePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('صحیح فروخت قیمت درج کریں / Enter valid sale price'),
          backgroundColor: AppColors.costRed,
        ),
      );
      return;
    }

    if (_selectedProduct!.stockQuantity < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسٹاک میں اتنی مقدار موجود نہیں ہے / Not enough stock available'),
          backgroundColor: AppColors.costRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(todaySalesProvider.notifier).recordSale(
          productId: _selectedProduct!.id,
          quantity: _quantity,
          salePrice: salePrice,
          costPrice: _selectedProduct!.defaultCostPrice,
          inputMethod: 'manual',
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فروخت کامیابی سے درج ہو گئی / Sale recorded successfully'),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فروخت درج کرنے میں خرابی / Failed to record sale'),
          backgroundColor: AppColors.costRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(inventoryListProvider);
    final salePrice = double.tryParse(_priceController.text.trim()) ?? (_selectedProduct?.defaultSalePrice ?? 0.0);
    final totalRevenue = _quantity * salePrice;
    final totalCost = _quantity * (_selectedProduct?.defaultCostPrice ?? 0.0);
    final totalProfit = totalRevenue - totalCost;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ClayContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'دستی فروخت درج کریں\nManual Sale Entry',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Select Product Dropdown
                productsAsync.when(
                  data: (products) {
                    return DropdownButtonFormField<Product>(
                      initialValue: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'پروڈکٹ منتخب کریں / Select Product',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.name} (اسٹاک: ${p.stockQuantity})',
                            style: AppTypography.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: _onProductChanged,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading products: $e'),
                ),
                const SizedBox(height: 16),

                if (_selectedProduct != null) ...[
                  // Quantity increment/decrement buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('مقدار / Quantity:', style: AppTypography.bodyLarge),
                      Row(
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: AppColors.surface),
                            icon: const Icon(Icons.remove_rounded, color: AppColors.primary),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '$_quantity',
                              style: AppTypography.displayMedium.copyWith(fontSize: 22),
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: AppColors.surface),
                            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                            onPressed: _quantity < _selectedProduct!.stockQuantity
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Negotiated / Actual Sale Price Field
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'اصل فروخت قیمت / Sale Price (Rs.)',
                      helperText: 'معمول کی قیمت: Rs. ${_selectedProduct!.defaultSalePrice.toStringAsFixed(0)}',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Live Summary Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('کل رقم / Total Revenue:', style: AppTypography.bodyMedium),
                            Text(
                              'Rs. ${totalRevenue.toStringAsFixed(0)}',
                              style: AppTypography.headingMedium.copyWith(color: AppColors.sellGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('اندازاً منافع / Estimated Profit:', style: AppTypography.bodyMedium),
                            Text(
                              'Rs. ${totalProfit.toStringAsFixed(0)}',
                              style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  BigButton(
                    label: 'فروخت درج کریں / Confirm Sale',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: AppColors.sellGreen,
                    onPressed: _confirmSale,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
