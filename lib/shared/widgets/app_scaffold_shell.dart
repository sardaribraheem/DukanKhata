import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/colors.dart';

class AppScaffoldShell extends ConsumerWidget {
  final Widget child;

  const AppScaffoldShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/khata')) return 1;
    if (location.startsWith('/inventory')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/khata');
        break;
      case 2:
        context.go('/inventory');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: appText(isUrdu, 'ڈیش بورڈ', 'Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: appText(isUrdu, 'کھاتہ', 'Khata'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: appText(isUrdu, 'اسٹاک', 'Inventory'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: appText(isUrdu, 'ترتیبات', 'Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
