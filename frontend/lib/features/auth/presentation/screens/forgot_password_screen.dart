import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceContainerLow,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is PasswordResetEmailSent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${state.email} adresine şifre sıfırlama bağlantısı gönderildi!',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.go(AppRoutes.ownerEmailVerification);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading || state.isLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.asset(
                          "assets/icons/paw.svg",
                          width: 40,
                          height: 40,
                          colorFilter: const ColorFilter.mode(
                            AppColors.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // VetTrack Başlık
                      Text(
                        "VetTrack",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Kutulu Form Kartı
                      Card(
                        elevation: 2,
                        shadowColor:
                            AppColors.onSurface.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: AppColors.surfaceContainerLowest,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Şifremi Unuttum",
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "E-posta adresinizi girin, size bir şifre sıfırlama bağlantısı gönderelim.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // E-posta TextFormField
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "E-posta Adresi",
                                    prefixIcon: const Icon(
                                      Icons.mail_outline,
                                      color: AppColors.outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: Validators.validateEmail,
                                ),

                                const SizedBox(height: 24),

                                // Sıfırlama Bağlantısı Gönder Butonu
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _onResetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.onPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.onPrimary,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sıfırlama Bağlantısı Gönder',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: AppColors.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.send_rounded,
                                                size: 20,
                                                color: AppColors.onPrimary,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Giriş Ekranına Dön Yönlendirmesi
                      TextButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.login);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          "Giriş Ekranına Dön",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Text(
                        "© 2026 VetTrack Health Systems. All rights reserved.",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
