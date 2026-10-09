import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../sales/presentation/manual_sale_dialog.dart';
import '../../sales/providers/sales_provider.dart';
import '../../voice/presentation/voice_sale_dialog.dart';

final homeGraphPeriodProvider = StateProvider<int>((ref) => 30);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';
    final today = ref.watch(todaySalesProvider);
    final rolling = ref.watch(rolling30DaySalesProvider);
    final period = ref.watch(homeGraphPeriodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(appText(isUrdu, 'دکان کھاتہ', 'DukanKhata')),
      ),
      body: SafeArea(
        child: today.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (todaySales) => rolling.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (sales) => _DashboardBody(
              isUrdu: isUrdu,
              todaySales: todaySales,
              rollingSales: sales,
              period: period,
              onPeriodChanged: (value) =>
                  ref.read(homeGraphPeriodProvider.notifier).state = value,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final bool isUrdu;
  final List<Sale> todaySales;
  final List<Sale> rollingSales;
  final int period;
  final ValueChanged<int> onPeriodChanged;

  const _DashboardBody({
    required this.isUrdu,
    required this.todaySales,
    required this.rollingSales,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final today = _summary(todaySales);
    final sevenDays = _summary(_since(rollingSales, 7));
    final thirtyDays = _summary(rollingSales);
    final graphSales = _since(rollingSales, period);
    final graphStart = _dateOnly(
      DateTime.now(),
    ).subtract(Duration(days: period - 1));
    final dailyProfits = _dailyProfits(graphSales, graphStart, period);
    final isProfit = today.profit >= 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          appText(isUrdu, 'آج کا جائزہ', "Today's overview"),
          style: AppTypography.headingLarge,
        ),
        const SizedBox(height: 12),
        ClayContainer(
          color: isProfit
              ? AppColors.sellGreen.withValues(alpha: 0.12)
              : AppColors.costRed.withValues(alpha: 0.12),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isProfit ? AppColors.sellGreen : AppColors.costRed,
                size: 42,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProfit
                          ? appText(
                              isUrdu,
                              'آج منافع میں ہیں',
                              'You are profitable today',
                            )
                          : appText(
                              isUrdu,
                              'آج نقصان میں ہیں',
                              'Today is a loss',
                            ),
                      style: AppTypography.headingMedium,
                    ),
                    Text(
                      'Rs. ${today.profit.toStringAsFixed(0)}',
                      style: AppTypography.displayMedium.copyWith(
                        color: isProfit
                            ? AppColors.sellGreen
                            : AppColors.costRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard('Revenue', today.revenue, AppColors.sellGreen),
            ),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard('Cost', today.cost, AppColors.costRed)),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                'Items',
                today.items.toDouble(),
                Colors.blueGrey,
                decimals: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle(appText(isUrdu, 'کاروباری کارکردگی', 'Performance')),
        const SizedBox(height: 8),
        ClayContainer(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Today')),
                  ButtonSegment(value: 7, label: Text('7 Days')),
                  ButtonSegment(value: 30, label: Text('30 Days')),
                ],
                selected: {period},
                onSelectionChanged: (selection) =>
                    onPeriodChanged(selection.first),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                child: _ProfitChart(values: dailyProfits, isUrdu: isUrdu),
              ),
              const SizedBox(height: 6),
              Text(
                appText(isUrdu, 'روزانہ منافع', 'Daily profit'),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(appText(isUrdu, 'مدت کا خلاصہ', 'Period summary')),
        const SizedBox(height: 8),
        _PeriodCard('Last 7 Days', sevenDays),
        const SizedBox(height: 10),
        _PeriodCard('Last 30 Days', thirtyDays),
        const SizedBox(height: 24),
        _SectionTitle(appText(isUrdu, 'فوری اقدامات', 'Quick actions')),
        const SizedBox(height: 8),
        BigButton(
          label: appText(isUrdu, 'آواز سے فروخت درج کریں', 'Voice Entry'),
          icon: Icons.mic_rounded,
          backgroundColor: AppColors.micAmber,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const VoiceSaleDialog(),
          ),
        ),
        const SizedBox(height: 10),
        BigButton(
          label: appText(isUrdu, 'فروخت درج کریں', 'Sell Item'),
          icon: Icons.point_of_sale_rounded,
          backgroundColor: AppColors.sellGreen,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ManualSaleDialog(),
          ),
        ),
        const SizedBox(height: 10),
        BigButton(
          label: appText(isUrdu, 'اسٹاک', 'Inventory'),
          icon: Icons.inventory_2_rounded,
          backgroundColor: AppColors.primary,
          onPressed: () => context.go('/inventory'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final int decimals;
  const _MetricCard(this.label, this.value, this.color, {this.decimals = 0});
  @override
  Widget build(BuildContext context) => ClayContainer(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 5),
        Text(
          'Rs. ${value.toStringAsFixed(decimals)}',
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _PeriodCard extends StatelessWidget {
  final String title;
  final _Summary summary;
  const _PeriodCard(this.title, this.summary);
  @override
  Widget build(BuildContext context) => ClayContainer(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.bodyLarge)),
        _SmallValue('Revenue', summary.revenue, AppColors.sellGreen),
        _SmallValue('Cost', summary.cost, AppColors.costRed),
        _SmallValue(
          'Profit',
          summary.profit,
          summary.profit >= 0 ? AppColors.sellGreen : AppColors.costRed,
        ),
      ],
    ),
  );
}

class _SmallValue extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SmallValue(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTypography.caption),
        Text(
          'Rs. ${value.toStringAsFixed(0)}',
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.headingMedium);
}

class _ProfitChart extends StatelessWidget {
  final List<double> values;
  final bool isUrdu;
  const _ProfitChart({required this.values, required this.isUrdu});
  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(
      0,
      (max, value) => math.max(max, value.abs()),
    );
    if (maxValue == 0) {
      return Center(
        child: Text(appText(isUrdu, 'ابھی کوئی فروخت نہیں', 'No sales yet')),
      );
    }
    return CustomPaint(
      painter: _ProfitChartPainter(values: values, maxValue: maxValue),
      child: const SizedBox.expand(),
    );
  }
}

class _ProfitChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  _ProfitChartPainter({required this.values, required this.maxValue});
  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height / 2;
    final barWidth = math.max(2.0, size.width / values.length - 3);
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.2);
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      gridPaint,
    );
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      final height = (value.abs() / maxValue) * (size.height * 0.42);
      final left = index * (size.width / values.length) + 1;
      final top = value >= 0 ? baseline - height : baseline;
      final paint = Paint()
        ..color = value >= 0 ? AppColors.sellGreen : AppColors.costRed;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, height),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProfitChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _Summary {
  final double revenue;
  final double cost;
  final double profit;
  final int items;
  const _Summary(this.revenue, this.cost, this.profit, this.items);
}

_Summary _summary(List<Sale> sales) => sales.fold(
  const _Summary(0, 0, 0, 0),
  (total, sale) => _Summary(
    total.revenue + sale.revenue,
    total.cost + sale.costPrice * sale.quantity,
    total.profit + sale.profit,
    total.items + sale.quantity,
  ),
);

List<Sale> _since(List<Sale> sales, int days) {
  final start = _dateOnly(DateTime.now()).subtract(Duration(days: days - 1));
  return sales.where((sale) => !sale.soldAt.toLocal().isBefore(start)).toList();
}

List<double> _dailyProfits(List<Sale> sales, DateTime start, int days) {
  return List.generate(days, (index) {
    final day = start.add(Duration(days: index));
    return sales
        .where((sale) {
          final local = sale.soldAt.toLocal();
          return local.year == day.year &&
              local.month == day.month &&
              local.day == day.day;
        })
        .fold(0.0, (total, sale) => total + sale.profit);
  });
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
