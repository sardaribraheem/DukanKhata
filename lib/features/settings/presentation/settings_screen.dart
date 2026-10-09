import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/config/supabase.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isUrdu ? 'ترتیبات' : 'Settings',
          style: AppTypography.headingMedium.copyWith(color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Information Card
              ClayContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_circle_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUrdu
                                    ? 'دکان دار اکاؤنٹ'
                                    : 'Shop Owner Account',
                                style: AppTypography.headingMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ??
                                    (isUrdu ? 'مہمان صارف' : 'Guest User'),
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Language Switcher Card
              ClayContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isUrdu ? 'زبان: اردو' : 'Language: English',
                          style: AppTypography.bodyLarge,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => toggleLocale(ref),
                      child: Text(
                        isUrdu ? 'English میں کریں' : 'اردو میں کریں',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // App Version Info Card
              ClayContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isUrdu
                          ? 'ورژن: 1.0.0 (DukanKhata)'
                          : 'Version: 1.0.0 (DukanKhata)',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Logout Button (Only in Settings, as required)
              BigButton(
                label: isUrdu ? 'لاگ آؤٹ کریں' : 'Logout',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.costRed,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
