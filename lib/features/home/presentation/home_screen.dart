import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../sales/presentation/manual_sale_dialog.dart';
import '../../sales/providers/sales_provider.dart';
import '../../voice/presentation/voice_sale_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دکان کھاتہ • Dukan Khata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.costRed),
            tooltip: 'لاگ آؤٹ / Logout',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's summary card (clickable to open Khata)
              GestureDetector(
                onTap: () => context.go('/khata'),
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
                            'آج کا کھاتہ • Today\'s Summary',
                            style: AppTypography.headingMedium,
                          ),
                          const Row(
                            children: [
                              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                              SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SummaryItem(
                            label: 'آمدنی / Revenue',
                            amount: 'Rs. ${summary.totalRevenue.toStringAsFixed(0)}',
                            color: AppColors.sellGreen,
                          ),
                          _SummaryItem(
                            label: 'منافع / Profit',
                            amount: 'Rs. ${summary.totalProfit.toStringAsFixed(0)}',
                            color: AppColors.primary,
                          ),
                          _SummaryItem(
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
              const SizedBox(height: 24),

              // Action Buttons (Large, easy to tap for elderly user)
              BigButton(
                label: 'آواز سے فروخت درج کریں / Voice Entry',
                icon: Icons.mic_rounded,
                backgroundColor: AppColors.micAmber,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const VoiceSaleDialog(),
                  );
                },
              ),
              const SizedBox(height: 16),
              BigButton(
                label: 'دستی فروخت درج کریں / Manual Sell',
                icon: Icons.point_of_sale_rounded,
                backgroundColor: AppColors.sellGreen,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const ManualSaleDialog(),
                  );
                },
              ),
              const SizedBox(height: 16),
              BigButton(
                label: 'اسٹاک / Inventory',
                icon: Icons.inventory_2_rounded,
                backgroundColor: AppColors.primary,
                onPressed: () {
                  context.go('/inventory');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
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
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTypography.headingLarge.copyWith(color: color, fontSize: 18),
        ),
      ],
    );
  }
}
