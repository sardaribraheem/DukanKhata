import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../providers/inventory_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _saleController = TextEditingController();
  final _stockController = TextEditingController(text: '10');

  String _selectedCategory = 'Oils & Fluids';
  bool _isFavorite = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Oils & Fluids',
    'Parts',
    'Tires',
    'Batteries',
    'Small Items',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _saleController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    final sale = double.tryParse(_saleController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final success = await ref.read(inventoryListProvider.notifier).addProduct(
          name: name,
          category: _selectedCategory,
          defaultCostPrice: cost,
          defaultSalePrice: sale,
          initialStock: stock,
          isFavorite: _isFavorite,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نیا پروڈکٹ کامیابی سے شامل کر دیا گیا / Product added successfully'),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('پروڈکٹ شامل کرنے میں خرابی پیش آئی / Failed to add product'),
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                      Text(
                        'نیا پروڈکٹ شامل کریں\nAdd New Product',
                        style: AppTypography.headingMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'پروڈکٹ کا نام / Product Name',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'نام درج کریں / Enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'کیٹیگری / Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: AppTypography.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cost & Sale Prices
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'خرید قیمت / Cost (Rs.)',
                            prefixIcon: Icon(Icons.money_off_rounded),
                          ),
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) {
                              return 'خرید قیمت درج کریں';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _saleController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'فروخت قیمت / Sale (Rs.)',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                          ),
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) {
                              return 'فروخت قیمت درج کریں';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Initial Stock & Favorite
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'ابتدائی اسٹاک / Initial Stock',
                            prefixIcon: Icon(Icons.format_list_numbered_rounded),
                          ),
                          validator: (val) {
                            if (val == null || int.tryParse(val) == null) {
                              return 'اسٹاک درج کریں';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('پسندیدہ\nFavorite', style: AppTypography.bodyMedium),
                          value: _isFavorite,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _isFavorite = val ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    BigButton(
                      label: 'پروڈکٹ محفوظ کریں / Save Product',
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
