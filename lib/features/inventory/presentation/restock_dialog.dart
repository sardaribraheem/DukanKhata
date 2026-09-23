import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../providers/inventory_provider.dart';

class RestockDialog extends ConsumerStatefulWidget {
  final Product product;

  const RestockDialog({super.key, required this.product});

  @override
  ConsumerState<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends ConsumerState<RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '10');
    _priceController = TextEditingController(
      text: widget.product.defaultCostPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final success = await ref.read(inventoryListProvider.notifier).restockProduct(
          productId: widget.product.id,
          quantity: qty,
          purchasePrice: price,
          currentStock: widget.product.stockQuantity,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسٹاک کامیابی سے بڑھا دیا گیا / Restocked successfully'),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ری اسٹاک میں خرابی / Failed to restock'),
          backgroundColor: AppColors.costRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClayContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'ری اسٹاک: ${widget.product.name}',
                          style: AppTypography.headingMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'موجودہ اسٹاک / Current Stock: ${widget.product.stockQuantity}',
                    style: AppTypography.bodyMedium,
                  ),
                  const Divider(height: 24),

                  // Quantity to add
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'کتنا نیا اسٹاک آیا؟ / Quantity to Add',
                      prefixIcon: Icon(Icons.add_box_rounded),
                    ),
                    validator: (val) {
                      if (val == null || int.tryParse(val) == null || int.parse(val) <= 0) {
                        return 'صحیح مقدار درج کریں';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Purchase Price per unit
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'فی یونٹ خرید قیمت / Purchase Price (Rs.)',
                      prefixIcon: Icon(Icons.money_rounded),
                    ),
                    validator: (val) {
                      if (val == null || double.tryParse(val) == null) {
                        return 'قیمت درج کریں';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    BigButton(
                      label: 'اسٹاک میں شامل کریں / Confirm Restock',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: AppColors.sellGreen,
                      onPressed: _submit,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
