import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'owner';
  bool _obscurePassword = true;
  bool _kvkkApproved = false;
  bool _explicitConsentApproved = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDocumentDialog(String title, String content) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: Text(
              'Okudum, Anladım',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_kvkkApproved || !_explicitConsentApproved) {
        AppSnackBar.showError(
          context,
          title: 'Onay Gerekli',
          message:
              'Kayıt olmak için Aydınlatma Metni ve Açık Rıza Metnini onaylamalısınız.',
        );
        return;
      }

      context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            _selectedRole == 'vet_staff' ? UserRole.vet : UserRole.owner,
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
                    AppSnackBar.showError(
                      context,
                      title: "Kayıt Başarısız",
                      message: error,
                    );
                  }
                  if (state is Authenticated) {
                    context.go(AppRoutes.ownerEmailVerification);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading || state.isLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo (Yuvarlatılmış Mavi Kutu İle İkon)
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

                      // Kutulu Form Kartı (Card Container)
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Başlık
                                Text(
                                  "Kayıt Ol",
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Evcil hayvanınızın sağlığını takip etmeye bugün başlayın.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Kullanıcı Tipi Seçimi (SegmentedButton)
                                SegmentedButton<String>(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return AppColors.primary;
                                      }
                                      return AppColors.surfaceContainerLow;
                                    }),
                                    foregroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return AppColors.onPrimary;
                                      }
                                      return AppColors.onSurfaceVariant;
                                    }),
                                    iconColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return AppColors.onPrimary;
                                      }
                                      return AppColors.outline;
                                    }),
                                    side: WidgetStateProperty.all(
                                      const BorderSide(
                                          color: AppColors.outlineVariant),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  segments: const [
                                    ButtonSegment<String>(
                                      value: 'owner',
                                      label: Text('Hayvan Sahibi'),
                                      icon: Icon(Icons.pets_outlined),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'vet_staff',
                                      label: Text('Veteriner Personeli'),
                                      icon: Icon(Icons.local_hospital_outlined),
                                    ),
                                  ],
                                  selected: {_selectedRole},
                                  onSelectionChanged:
                                      (Set<String> newSelection) {
                                    final selected = newSelection.first;
                                    setState(() {
                                      _selectedRole = selected;
                                    });
                                    if (selected == 'vet_staff') {
                                      AppSnackBar.showWarning(
                                        context,
                                        message:
                                            'Bu uygulama hayvan sahipleri içindir. Klinik girişi için web panelini kullanınız.',
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Ad-Soyad TextFormField
                                TextFormField(
                                  controller: _nameController,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "Ad Soyad",
                                    hintText: "Adınızı ve soyadınızı giriniz",
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
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
                                  validator: Validators.validateName,
                                ),

                                const SizedBox(height: 16),

                                // E-posta TextFormField
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "E-posta Adresi",
                                    hintText: "E-posta adresinizi giriniz",
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

                                const SizedBox(height: 16),

                                // Telefon TextFormField (Opsiyonel)
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "Telefon (Opsiyonel)",
                                    hintText: "05XX XXX XX XX",
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
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
                                  validator: Validators.validatePhone,
                                ),

                                const SizedBox(height: 16),

                                // Şifre TextFormField
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "Şifre",
                                    hintText: "Şifrenizi giriniz",
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
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
                                  validator: Validators.validatePassword,
                                ),

                                const SizedBox(height: 20),

                                // Açık Rıza Metni Checkbox
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _explicitConsentApproved,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) => setState(() =>
                                            _explicitConsentApproved =
                                                val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showDocumentDialog(
                                              'Açık Rıza Metni',
                                              'Sağlık verilerinizin, tıbbi geçmişinizin ve aşı bildirimlerinin veteriner klinikleri ile paylaşılmasına ve işlenmesine açık rıza veriyorum.',
                                            ),
                                            child: Text(
                                              'Açık Rıza Metni',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\'ni okudum ve kabul ediyorum.',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // KVKK Aydınlatma Metni Checkbox
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _kvkkApproved,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) => setState(
                                            () => _kvkkApproved = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showDocumentDialog(
                                              'Aydınlatma Metni',
                                              'VetTrack olarak kişisel verilerinizin güvenliğine önem veriyoruz. 6698 sayılı KVKK uyarınca verileriniz hizmet sunumu, veteriner randevu takibi ve sağlık kayıtlarının tutulması amacıyla işlenmektedir.',
                                            ),
                                            child: Text(
                                              'Aydınlatma Metni',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\'ni okudum ve onaylıyorum.',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Kayıt Ol Butonu
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onRegister,
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
                                                'Kayıt Ol',
                                                style: theme
                                                    .textTheme.titleMedium
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

                      // Giriş Yap Yönlendirmesi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Zaten hesabınız var mı?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.login);
                            },
                            child: Text(
                              "Giriş Yap",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
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
