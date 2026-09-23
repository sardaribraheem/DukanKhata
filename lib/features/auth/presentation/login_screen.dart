import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/big_button.dart';
import '../../../shared/widgets/clay_container.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final isUrdu = ref.read(localeProvider).languageCode == 'ur';
    final notifier = ref.read(authControllerProvider.notifier);
    final success = _isSignUp
        ? await notifier.signUp(_emailController.text, _passwordController.text)
        : await notifier.signIn(_emailController.text, _passwordController.text);

    if (!mounted) return;
    if (!success) {
      final stateVal = ref.read(authControllerProvider);
      final errorMsg = stateVal.hasError
          ? stateVal.error.toString().replaceAll('Exception: ', '')
          : (_isSignUp
              ? (isUrdu ? 'اکاؤنٹ نہیں بن سکا۔' : 'Failed to create account.')
              : (isUrdu ? 'لاگ ان نہیں ہو سکا۔' : 'Failed to login.'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.costRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_isSignUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu ? 'اکاؤنٹ کامیابی سے بن گیا!' : 'Account created successfully!',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.sellGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleAuth() async {
    final isUrdu = ref.read(localeProvider).languageCode == 'ur';
    final notifier = ref.read(authControllerProvider.notifier);
    final success = await notifier.signInWithGoogle();

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu ? 'گوگل لاگ ان ناکام رہا۔' : 'Google sign-in failed.',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.costRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Mono Language Switcher Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.language_rounded, color: AppColors.primary),
              label: Text(
                isUrdu ? 'English' : 'اردو',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              onPressed: () => toggleLocale(ref),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Logo / App Header
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 52,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isUrdu ? 'دکان کھاتہ' : 'Dukan Khata',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUp
                          ? (isUrdu ? 'نیا اکاؤنٹ بنائیں' : 'Create Account')
                          : (isUrdu ? 'لاگ ان کریں' : 'Shop Login'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 36),

                    // Input Form inside tactile Clay Card
                    ClayContainer(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTypography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: isUrdu ? 'ای میل' : 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isUrdu ? 'براہ کرم ای میل درج کریں' : 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTypography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: isUrdu ? 'پاس ورڈ' : 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return isUrdu ? 'براہ کرم پاس ورڈ درج کریں' : 'Please enter password';
                              }
                              if (_isSignUp && val.length < 6) {
                                return isUrdu
                                    ? 'پاس ورڈ کم از کم 6 ہندسوں کا ہونا چاہیے'
                                    : 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button (Large tactile button)
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    else ...[
                      BigButton(
                        label: _isSignUp
                            ? (isUrdu ? 'اکاؤنٹ بنائیں' : 'Sign Up')
                            : (isUrdu ? 'لاگ ان کریں' : 'Login'),
                        icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                        onPressed: _handleAuth,
                        backgroundColor: AppColors.primary,
                      ),
                      const SizedBox(height: 14),
                      // Google Sign In Button
                      BigButton(
                        label: isUrdu ? 'گوگل سے لاگ ان کریں' : 'Login with Google',
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: _handleGoogleAuth,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Toggle between Login and Sign Up
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? (isUrdu
                                ? 'پہلے سے اکاؤنٹ ہے؟ لاگ ان کریں'
                                : 'Already have an account? Login')
                            : (isUrdu
                                ? 'نیا اکاؤنٹ بنائیں'
                                : 'Create New Account'),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
