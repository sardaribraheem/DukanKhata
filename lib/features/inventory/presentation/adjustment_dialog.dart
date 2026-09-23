import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../providers/inventory_provider.dart';

class AdjustmentDialog extends ConsumerStatefulWidget {
  final Product product;

  const AdjustmentDialog({super.key, required this.product});

  @override
  ConsumerState<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends ConsumerState<AdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Physical stock count correction');
  bool _isAddition = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final rawQty = int.tryParse(_qtyController.text.trim()) ?? 0;
    final quantityChange = _isAddition ? rawQty : -rawQty;
    final reason = _reasonController.text.trim();

    final success = await ref.read(inventoryListProvider.notifier).adjustInventory(
          productId: widget.product.id,
          quantityChange: quantityChange,
          reason: reason,
          currentStock: widget.product.stockQuantity,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسٹاک ایڈجسٹ ہو گیا / Stock adjusted successfully'),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ایڈجسٹمنٹ میں خرابی / Failed to adjust stock'),
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
                          'اسٹاک ایڈجسٹمنٹ: ${widget.product.name}',
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

                  // Addition or Subtraction Toggle
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('اضافہ / Add (+)'),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('تخفیف / Reduce (-)'),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                    ],
                    selected: {_isAddition},
                    onSelectionChanged: (val) {
                      setState(() => _isAddition = val.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'مقدار / Quantity Change',
                      prefixIcon: Icon(Icons.tune_rounded),
                    ),
                    validator: (val) {
                      if (val == null || int.tryParse(val) == null || int.parse(val) <= 0) {
                        return 'صحیح مقدار درج کریں';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reason
                  TextFormField(
                    controller: _reasonController,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'وجہ / Reason (Damage, Audit, etc.)',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'وجہ درج کریں';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    BigButton(
                      label: 'محفوظ کریں / Apply Adjustment',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: AppColors.primary,
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
