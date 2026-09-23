import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/sale.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../data/sales_repository.dart';

final todaySalesProvider = AsyncNotifierProvider<TodaySalesNotifier, List<Sale>>(
  TodaySalesNotifier.new,
);

class TodaySalesNotifier extends AsyncNotifier<List<Sale>> {
  @override
  Future<List<Sale>> build() async {
    final repo = ref.watch(salesRepositoryProvider);
    return repo.fetchTodaySales();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(salesRepositoryProvider).fetchTodaySales();
    });
  }

  Future<bool> recordSale({
    required String productId,
    required int quantity,
    required double salePrice,
    required double costPrice,
    required String inputMethod,
  }) async {
    try {
      final repo = ref.read(salesRepositoryProvider);
      await repo.recordSale(
        productId: productId,
        quantity: quantity,
        salePrice: salePrice,
        costPrice: costPrice,
        inputMethod: inputMethod,
      );
      // Refresh both sales list and inventory list to keep quantities up to date
      await refresh();
      ref.read(inventoryListProvider.notifier).refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class TodaySummary {
  final double totalRevenue;
  final double totalProfit;
  final int totalItemsSold;

  const TodaySummary({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalItemsSold,
  });

  factory TodaySummary.empty() => const TodaySummary(
        totalRevenue: 0.0,
        totalProfit: 0.0,
        totalItemsSold: 0,
      );
}

final todaySummaryProvider = Provider<TodaySummary>((ref) {
  final salesAsync = ref.watch(todaySalesProvider);

  return salesAsync.maybeWhen(
    data: (sales) {
      double revenue = 0.0;
      double profit = 0.0;
      int items = 0;

      for (final sale in sales) {
        revenue += sale.revenue;
        profit += sale.profit;
        items += sale.quantity;
      }

      return TodaySummary(
        totalRevenue: revenue,
        totalProfit: profit,
        totalItemsSold: items,
      );
    },
    orElse: () => TodaySummary.empty(),
  );
});
