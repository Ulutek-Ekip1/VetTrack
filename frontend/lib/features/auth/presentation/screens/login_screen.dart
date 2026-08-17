import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/core/utils/app_snackbar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_platform.dart';
import '../../domain/entities/user_entity.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            rememberMe: _rememberMe,
          );
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
                  final error = state.errorMessage;
                  if (error != null) {
                    if (state is Unauthenticated) {
                      AppSnackBar.showSessionExpired(
                        context,
                        message: error,
                      );
                    } else if (error.contains("İnternet bağlantınız koptu") ||
                        error.contains("bağlantı hatası")) {
                      AppSnackBar.showNetworkError(
                        context,
                        message: error,
                      );
                    } else {
                      AppSnackBar.showError(
                        context,
                        title: "Giriş Engellendi",
                        message: error,
                      );
                    }
                  }
                  if (state is Authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hoşgeldiniz, ${state.user.name}'),
                      ),
                    );
                    context.go(
                      state.user.role == UserRole.vet
                          ? AppRoutes.vetSearch
                          : AppRoutes.ownerHome,
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading || state.isLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      SvgPicture.asset(
                        "assets/icons/VetTrack.svg",
                        width: 160,
                        height: 160,
                      ),

                      const SizedBox(height: 16),

                      // Kutulu Form Kartı (Card Container)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                          color: AppColors.surfaceContainerLowest,
                          child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Başlıklar
                                Text(
                                  AppPlatform.isVetWebExperience
                                      ? "Veteriner Personel Girişi"
                                      : "Giriş Yap",
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF14B8A6),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Devam etmek için e-posta ve şifrenizle giriş yapın",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                if (AppPlatform.isVetWebExperience) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Klinik yönetim paneline erişmek için personel hesabınızı kullanın.",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // E-posta TextFormField
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "E-posta Adresi",
                                    hintText: "E-posta adresinizi giriniz",
                                    prefixIcon: const Icon(
                                      Icons.mail_outline,
                                      color: AppColors.outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF14B8A6),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: Validators.validateEmail,
                                ),

                                const SizedBox(height: 16),

                                // Şifre TextFormField
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Şifre',
                                    hintText: 'Şifrenizi giriniz',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF14B8A6),
                                        width: 2,
                                      ),
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
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen şifrenizi girin';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Beni Hatırla & Şifremi Unuttum Satırı
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF14B8A6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: Text(
                                        "Beni Hatırla",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => context
                                          .push(AppRoutes.forgotPassword),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Şifremi Unuttum?',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: const Color(0xFF14B8A6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Giriş Yap Butonu (Loading Durumu Destekli)
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF14B8A6),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Giriş Yap',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // veya Ayracı
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "veya",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Google ile Giriş Yap Butonu
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<AuthCubit>().signInWithGoogle();
                                          },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/icons/google_g.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Google ile Giriş Yap',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
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

                      // Kayıt Ol Yönlendirmesi
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hesabınız yok mu?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(AppRoutes.register);
                              },
                              child: Text(
                                "Kayıt Ol",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF14B8A6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
