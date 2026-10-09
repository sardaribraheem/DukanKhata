import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../providers/sales_provider.dart';
import 'manual_sale_dialog.dart';

class TodaysKhataScreen extends ConsumerWidget {
  const TodaysKhataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedKhataDateProvider);
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';
    final monthSales = ref.watch(monthlySalesProvider);
    final daySales = ref.watch(khataSalesProvider);
    final windowStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(const Duration(days: 29));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrentWindow = !selectedDate.isBefore(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          appText(isUrdu, 'کھاتہ', 'Khata'),
          style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            tooltip: appText(isUrdu, 'تازہ کریں', 'Refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(monthlySalesProvider);
              ref.invalidate(khataSalesProvider);
              ref.read(todaySalesProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: monthSales.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('${appText(isUrdu, 'خرابی', 'Error')}: $error'),
          ),
          data: (sales) {
            final monthTotals = _totals(sales);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _RollingHeader(
                  endDate: selectedDate,
                  onPrevious: () =>
                      ref.read(selectedKhataDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 30)),
                  onNext: isCurrentWindow
                      ? null
                      : () =>
                            ref.read(selectedKhataDateProvider.notifier).state =
                                selectedDate.add(const Duration(days: 30)),
                ),
                _TotalsCard(
                  totals: monthTotals,
                  title: appText(
                    isUrdu,
                    'گزشتہ 30 دن کا خلاصہ',
                    'Last 30 Days',
                  ),
                  isUrdu: isUrdu,
                ),
                const SizedBox(height: 16),
                Text(
                  appText(isUrdu, 'روزانہ کھاتہ', 'Daily Khata'),
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 8),
                ..._daysInRange(windowStart, selectedDate).map((day) {
                  final daySales = sales
                      .where((sale) => _sameDay(sale.soldAt.toLocal(), day))
                      .toList();
                  final totals = _totals(daySales);
                  final selected = _sameDay(day, selectedDate);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          ref.read(selectedKhataDateProvider.notifier).state =
                              day,
                      child: ClayContainer(
                        color: selected
                            ? AppColors.primaryContainer
                            : AppColors.surface,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                '${_monthName(day.month).substring(0, 3)} ${day.day}',
                                style: AppTypography.bodyLarge,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${daySales.length} ${appText(isUrdu, 'لین دین', 'transactions')}\n${appText(isUrdu, 'آمدنی', 'Revenue')}: Rs. ${totals.revenue.toStringAsFixed(0)}',
                                style: AppTypography.caption,
                              ),
                            ),
                            Text(
                              '${appText(isUrdu, 'منافع', 'Profit')}\nRs. ${totals.profit.toStringAsFixed(0)}',
                              textAlign: TextAlign.end,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  '${_formatDate(selectedDate)} ${appText(isUrdu, 'منتخب دن', 'Selected Day')}',
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 8),
                daySales.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Text('${appText(isUrdu, 'خرابی', 'Error')}: $error'),
                  data: (dayTransactions) => dayTransactions.isEmpty
                      ? _EmptyDay(isUrdu: isUrdu)
                      : Column(
                          children: dayTransactions
                              .map(
                                (sale) => _SaleTile(sale: sale, isUrdu: isUrdu),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 12),
                BigButton(
                  label: appText(isUrdu, 'فروخت درج کریں', 'Record Sale'),
                  icon: Icons.point_of_sale_rounded,
                  backgroundColor: AppColors.sellGreen,
                  onPressed: () => _openSale(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSale(BuildContext context) =>
      showDialog(context: context, builder: (_) => const ManualSaleDialog());
}

class _RollingHeader extends StatelessWidget {
  final DateTime endDate;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  const _RollingHeader({
    required this.endDate,
    required this.onPrevious,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Expanded(
        child: Text(
          '${_formatDate(endDate.subtract(const Duration(days: 29)))} -\n${_formatDate(endDate)}',
          textAlign: TextAlign.center,
          style: AppTypography.headingLarge,
        ),
      ),
      IconButton(
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _TotalsCard extends StatelessWidget {
  final _SaleTotals totals;
  final String title;
  final bool isUrdu;
  const _TotalsCard({
    required this.totals,
    required this.title,
    required this.isUrdu,
  });
  @override
  Widget build(BuildContext context) => ClayContainer(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headingMedium),
        const Divider(height: 20),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          spacing: 18,
          children: [
            _Metric(
              label: appText(isUrdu, 'آمدنی', 'Revenue'),
              value: totals.revenue,
              color: AppColors.sellGreen,
            ),
            _Metric(
              label: appText(isUrdu, 'لاگت', 'Cost'),
              value: totals.cost,
              color: AppColors.costRed,
            ),
            _Metric(
              label: appText(isUrdu, 'منافع', 'Profit'),
              value: totals.profit,
              color: AppColors.primary,
            ),
            _Metric(
              label: appText(isUrdu, 'اشیاء', 'Items'),
              value: totals.items.toDouble(),
              color: Colors.blueGrey,
              decimals: 0,
            ),
          ],
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final int decimals;
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
    this.decimals = 0,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.caption),
      Text(
        'Rs. ${value.toStringAsFixed(decimals)}',
        style: AppTypography.bodyLarge.copyWith(color: color),
      ),
    ],
  );
}

class _SaleTile extends StatelessWidget {
  final Sale sale;
  final bool isUrdu;
  const _SaleTile({required this.sale, required this.isUrdu});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ClayContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.sellGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${sale.productName}\n${appText(isUrdu, 'مقدار', 'Qty')} ${sale.quantity} · Rs. ${sale.salePrice.toStringAsFixed(0)} each\n${_formatTime(sale.soldAt.toLocal())}',
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. ${sale.revenue.toStringAsFixed(0)}\n${appText(isUrdu, 'منافع', 'Profit')} ${sale.profit.toStringAsFixed(0)}',
            textAlign: TextAlign.end,
            style: AppTypography.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    ),
  );
}

class _EmptyDay extends StatelessWidget {
  final bool isUrdu;
  const _EmptyDay({required this.isUrdu});
  @override
  Widget build(BuildContext context) => ClayContainer(
    padding: const EdgeInsets.all(18),
    child: Text(
      appText(isUrdu, 'آج کوئی فروخت نہیں', 'No sales recorded'),
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium,
    ),
  );
}

class _SaleTotals {
  final double revenue;
  final double cost;
  final double profit;
  final int items;
  const _SaleTotals(this.revenue, this.cost, this.profit, this.items);
}

_SaleTotals _totals(List<Sale> sales) {
  var revenue = 0.0;
  var cost = 0.0;
  var profit = 0.0;
  var items = 0;
  for (final sale in sales) {
    revenue += sale.revenue;
    cost += sale.costPrice * sale.quantity;
    profit += sale.profit;
    items += sale.quantity;
  }
  return _SaleTotals(revenue, cost, profit, items);
}

List<DateTime> _daysInRange(DateTime start, DateTime end) => List.generate(
  end.difference(start).inDays + 1,
  (index) => start.add(Duration(days: index)),
);
bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
String _formatDate(DateTime date) =>
    '${_monthName(date.month)} ${date.day}, ${date.year}';
String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _monthName(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];
