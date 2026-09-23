import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../sales/providers/sales_provider.dart';

class VoiceSaleDialog extends ConsumerStatefulWidget {
  const VoiceSaleDialog({super.key});

  @override
  ConsumerState<VoiceSaleDialog> createState() => _VoiceSaleDialogState();
}

class _VoiceSaleDialogState extends ConsumerState<VoiceSaleDialog> {
  bool _isListening = false;
  bool _isAnalyzing = false;
  String _spokenText = '';

  // Extracted preview state
  Product? _matchedProduct;
  int _extractedQuantity = 1;
  double _extractedPrice = 0.0;
  bool _hasExtracted = false;
  bool _isLoading = false;

  final List<String> _sampleVoicePhrases = [
    'تین انجن آئل 900 روپے کے بیچے',
    'دو آئل فلٹر 500 روپے کے بیچے',
    'ایک ٹائر 3500 روپے کا بیچا',
    'چار پٹرول فلٹر 300 روپے',
  ];

  void _startListeningSimulator() {
    setState(() {
      _isListening = true;
      _spokenText = '';
      _hasExtracted = false;
    });

    // Simulate listening delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final phrase = _sampleVoicePhrases[DateTime.now().second % _sampleVoicePhrases.length];
      setState(() {
        _isListening = false;
        _isAnalyzing = true;
        _spokenText = phrase;
      });

      // Simulate AI extraction after listening
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _parseSpokenPhrase(phrase);
      });
    });
  }

  void _parseSpokenPhrase(String phrase) {
    final products = ref.read(inventoryListProvider).value ?? [];

    Product? found;
    for (final p in products) {
      if (phrase.contains('انجن آئل') && p.name.toLowerCase().contains('oil')) {
        found = p;
        break;
      } else if (phrase.contains('آئل فلٹر') && p.name.toLowerCase().contains('filter')) {
        found = p;
        break;
      } else if (phrase.contains('ٹائر') && p.name.toLowerCase().contains('tire')) {
        found = p;
        break;
      } else if (p.name.toLowerCase().contains(phrase.split(' ').last.toLowerCase())) {
        found = p;
        break;
      }
    }

    found ??= products.isNotEmpty ? products.first : null;

    int qty = 1;
    if (phrase.contains('تین')) {
      qty = 3;
    } else if (phrase.contains('دو')) {
      qty = 2;
    } else if (phrase.contains('چار')) {
      qty = 4;
    } else if (phrase.contains('ایک')) {
      qty = 1;
    }

    double price = found?.defaultSalePrice ?? 1000.0;
    if (phrase.contains('900')) {
      price = 900.0;
    } else if (phrase.contains('500')) {
      price = 500.0;
    } else if (phrase.contains('3500')) {
      price = 3500.0;
    } else if (phrase.contains('300')) {
      price = 300.0;
    }

    setState(() {
      _isAnalyzing = false;
      _matchedProduct = found;
      _extractedQuantity = qty;
      _extractedPrice = price;
      _hasExtracted = true;
    });
  }

  Future<void> _commitVoiceSale() async {
    if (_matchedProduct == null) return;

    setState(() => _isLoading = true);

    final success = await ref.read(todaySalesProvider.notifier).recordSale(
          productId: _matchedProduct!.id,
          quantity: _extractedQuantity,
          salePrice: _extractedPrice,
          costPrice: _matchedProduct!.defaultCostPrice,
          inputMethod: 'voice',
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('آواز سے فروخت کامیابی سے درج ہو گئی / Voice Sale Recorded'),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خرابی پیش آئی / Failed to record voice sale'),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'آواز سے فروخت • Voice Entry',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Microphone State UI
                if (!_hasExtracted) ...[
                  Center(
                    child: GestureDetector(
                      onTap: _isListening ? null : _startListeningSimulator,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: _isListening ? AppColors.costRed : AppColors.micAmber,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? AppColors.costRed : AppColors.micAmber)
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      _isListening
                          ? 'سن رہے ہیں... بولیں / Listening... Speak now'
                          : _isAnalyzing
                              ? 'AI تجزیہ کر رہا ہے... / AI is extracting...'
                              : 'مائیکروفون دبائیں اور اردو میں بولیں\nTap mic and speak in Urdu',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isListening || _isAnalyzing)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    const SizedBox(height: 8),
                    Text(
                      'یا نقلی آواز کے لیے نیچے کلک کریں:',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('آواز کی نقل کریں / Simulate Voice'),
                      onPressed: _startListeningSimulator,
                    ),
                  ],
                ] else ...[
                  // Extracted Result Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sellGreen),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('پہچانی گئی بات / Recognized Speech:', style: AppTypography.caption),
                        Text('“$_spokenText”', style: AppTypography.bodyLarge.copyWith(fontStyle: FontStyle.italic)),
                        const Divider(height: 20),
                        Text('پروڈکٹ / Product: ${_matchedProduct?.name ?? "نامعلوم"}', style: AppTypography.headingMedium),
                        const SizedBox(height: 6),
                        Text('مقدار / Quantity: $_extractedQuantity', style: AppTypography.bodyMedium),
                        Text('قیمت / Price: Rs. ${_extractedPrice.toStringAsFixed(0)} each', style: AppTypography.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          'کل رقم / Total: Rs. ${(_extractedQuantity * _extractedPrice).toStringAsFixed(0)}',
                          style: AppTypography.headingMedium.copyWith(color: AppColors.sellGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _hasExtracted = false),
                            child: const Text('دوبارہ کوشش کریں'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: BigButton(
                            label: 'تصدیق کریں / Confirm',
                            icon: Icons.check_circle_rounded,
                            backgroundColor: AppColors.sellGreen,
                            onPressed: _commitVoiceSale,
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
