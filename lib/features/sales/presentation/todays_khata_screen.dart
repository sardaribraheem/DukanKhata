import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../../shared/widgets/big_button.dart';
import '../providers/sales_provider.dart';
import 'manual_sale_dialog.dart';

class TodaysKhataScreen extends ConsumerWidget {
  const TodaysKhataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(todaySalesProvider);
    final summary = ref.watch(todaySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'آج کا کھاتہ / Today\'s Khata',
          style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ریش فریش / Refresh',
            onPressed: () {
              ref.read(todaySalesProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClayContainer(
              padding: const EdgeInsets.all(20),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'آج کا خلاصہ • Today\'s Summary',
                        style: AppTypography.headingMedium,
                      ),
                      const Icon(Icons.analytics_rounded, color: AppColors.primary),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryBox(
                        label: 'آمدنی / Revenue',
                        amount: 'Rs. ${summary.totalRevenue.toStringAsFixed(0)}',
                        color: AppColors.sellGreen,
                      ),
                      _SummaryBox(
                        label: 'منافع / Profit',
                        amount: 'Rs. ${summary.totalProfit.toStringAsFixed(0)}',
                        color: AppColors.primary,
                      ),
                      _SummaryBox(
                        label: 'فروخت / Items',
                        amount: '${summary.totalItemsSold}',
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sales List Title & Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آج کی فروخت شدہ اشیاء / Today\'s Sales',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('دستی فروخت'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ManualSaleDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Sales List
          Expanded(
            child: salesAsync.when(
              data: (sales) {
                if (sales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'آج ابھی تک کوئی فروخت نہیں ہوئی\nNo sales recorded today',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BigButton(
                          label: 'پہلی فروخت درج کریں / Record Sale',
                          icon: Icons.point_of_sale_rounded,
                          backgroundColor: AppColors.sellGreen,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const ManualSaleDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ClayContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.sellGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.sellGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sale.productName ?? 'Unknown Product',
                                    style: AppTypography.headingMedium.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'مقدار: ${sale.quantity} | قیمت فی عدد: Rs. ${sale.salePrice.toStringAsFixed(0)}',
                                    style: AppTypography.caption,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'طریقہ: ${sale.inputMethod.toUpperCase()} | وقت: ${sale.soldAt.hour}:${sale.soldAt.minute.toString().padLeft(2, '0')}',
                                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${sale.revenue.toStringAsFixed(0)}',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sellGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'منافع: +${sale.profit.toStringAsFixed(0)}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('خرابی: $err', style: const TextStyle(color: AppColors.costRed)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryBox({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(
          amount,
          style: AppTypography.headingLarge.copyWith(color: color, fontSize: 18),
        ),
      ],
    );
  }
}
