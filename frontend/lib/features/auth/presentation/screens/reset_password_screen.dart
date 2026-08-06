import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _translateAuthError(String message) {
    if (message.contains('Auth session missing') ||
        message.contains('Geçerli bir şifre yenileme oturumu bulunamadı')) {
      return 'Geçerli bir şifre yenileme oturumu bulunamadı. Lütfen e-postanıza gönderilen sıfırlama bağlantısına tıklayarak tekrar deneyiniz.';
    }
    if (message.contains('same password') ||
        message.contains('should be different')) {
      return 'Yeni şifreniz eski şifrenizle aynı olamaz.';
    }
    if (message.contains('Password should be')) {
      return 'Şifreniz en az 8 karakter olmalı, harf ve rakam içermelidir.';
    }
    if (message.contains('Token has expired') ||
        message.contains('expired')) {
      return 'Şifre sıfırlama bağlantısının süresi dolmuş. Lütfen yeni bir bağlantı talep ediniz.';
    }
    
    // Eğer mesaj zaten Türkçe ise doğrudan döndür, aksi halde genel Türkçe hata mesajı göster
    if (message.contains('şifre') || message.contains('oturum') || message.contains('bağlantı') || message.contains('hata')) {
      return message;
    }
    
    return 'Şifre güncellenirken bir sorun oluştu. Lütfen tekrar deneyin.';
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw const AuthException(
            'Geçerli bir şifre yenileme oturumu bulunamadı. Lütfen e-postanıza gönderilen sıfırlama bağlantısına tıklayarak tekrar deneyiniz.');
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      AppSnackBar.showSuccess(
        context,
        title: "Başarılı",
        message:
            "Şifreniz başarıyla güncellendi. Yeni şifrenizle giriş yapabilirsiniz.",
      );

      // Başarılı olduğunda giriş ekranına yönlendir
      context.go(AppRoutes.login);
    } on AuthException catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        title: "Şifre Güncelleme Hatası",
        message: _translateAuthError(error.message),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        title: "Şifre Güncelleme Hatası",
        message:
            "Şifre güncellenirken bir sorun oluştu. Lütfen tekrar deneyin.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              child: Column(
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

                  // Card Form Container
                  Card(
                    elevation: 2,
                    shadowColor: AppColors.onSurface.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: AppColors.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Yeni Şifre Belirle",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Hesabınızı güvende tutmak için lütfen güçlü ve benzersiz bir şifre seçin.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Yeni Şifre Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                label: const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: "Yeni Şifre"),
                                      TextSpan(
                                        text: " *",
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                hintText: "Yeni şifrenizi giriniz",
                                helperText:
                                    "En az 8 karakter, harf ve rakam içermelidir",
                                helperStyle:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.outline,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.outline,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
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
                              validator: Validators.validatePassword,
                            ),

                            const SizedBox(height: 16),

                            // Şifre Tekrar Input
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                label: const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: "Yeni Şifre (Tekrar)"),
                                      TextSpan(
                                        text: " *",
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                hintText: "Yeni şifrenizi tekrar giriniz",
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.outline,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.outline,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
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
                              validator: (value) {
                                final passValidation =
                                    Validators.validatePassword(value);
                                if (passValidation != null) {
                                  return passValidation;
                                }
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Şifreyi Güncelle Butonu
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
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
                                            'Şifreyi Güncelle',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: AppColors.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward,
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

                  const SizedBox(height: 20),

                  // Giriş Ekranına Dön Yönlendirmesi
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: Text(
                      "Giriş Ekranına Dön",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    "© 2026 VetTrack Health Systems. All rights reserved.",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
