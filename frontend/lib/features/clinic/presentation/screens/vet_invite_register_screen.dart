import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/clinic_invite_cubit.dart';
import '../cubit/clinic_invite_state.dart';
import '../../../../core/utils/validators.dart';

class VetInviteRegisterScreen extends StatefulWidget {
  final String token;
  final String? initialClinicName;

  const VetInviteRegisterScreen({
    super.key,
    required this.token,
    this.initialClinicName,
  });

  @override
  State<VetInviteRegisterScreen> createState() =>
      _VetInviteRegisterScreenState();
}

class _VetInviteRegisterScreenState extends State<VetInviteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Eğer clinicName henüz yoksa veya F5 ile gelinmişse doğrula
    if (widget.initialClinicName == null || widget.initialClinicName!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = context.read<ClinicInviteCubit>().state;
        if (state is! ClinicInviteValidated || state.token != widget.token) {
          context.read<ClinicInviteCubit>().validateToken(widget.token);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _hasSubmittedRegistration = false;

  void _onSubmit(String clinicName) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _hasSubmittedRegistration = true;
      });
      context.read<ClinicInviteCubit>().registerAndAccept(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            token: widget.token,
            clinicName: clinicName,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface),
          onPressed: () => context.go('/vet/invite'),
        ),
      ),
      body: BlocConsumer<ClinicInviteCubit, ClinicInviteState>(
        listener: (context, state) async {
          if (state is ClinicInviteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('${state.clinicName} bünyesine kaydınız tamamlandı!'),
                backgroundColor: AppColors.secondary,
              ),
            );
            // Auth durumunu güncelle (role: vet_staff olacak)
            await context.read<AuthCubit>().checkAuthStatus();
            if (context.mounted) {
              context.go('/vet/search');
            }
          }
        },
        builder: (context, state) {
          if (state is ClinicInviteValidating) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Klinik daveti doğrulanıyor...'),
                ],
              ),
            );
          }

          if (state is ClinicInviteSubmitting && _hasSubmittedRegistration) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.secondary),
                  const SizedBox(height: 16),
                  const Text('Klinik üyeliği tamamlanıyor...'),
                ],
              ),
            );
          }

          if (state is ClinicInviteError && state.type == ClinicInviteErrorType.acceptFailed) {
            final targetToken = state.token ?? widget.token;
            final targetClinicName = state.clinicName ?? widget.initialClinicName ?? 'Veteriner Kliniği';

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mark_email_read_rounded, size: 48, color: theme.colorScheme.tertiary),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Kayıt Tamamlandı, Davet Beklemede',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Hesabınız başarıyla oluşturuldu fakat $targetClinicName kliniğine bağlantı tamamlanırken bir sorun oluştu.\n\nFormu tekrar doldurmanıza gerek yoktur.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          if (state.message.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: theme.colorScheme.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: () {
                                context.read<ClinicInviteCubit>().retryAcceptOnly(
                                      token: targetToken,
                                      clinicName: targetClinicName,
                                    );
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text('Kliniğe Katılmayı Tekrar Dene', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/login'),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: const Text('Giriş Ekranına Git'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingMd,
                                  vertical: AppDimensions.spacingSm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is ClinicInviteError && state.type != ClinicInviteErrorType.acceptFailed) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Geçersiz Davet Bağlantısı',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.go('/vet/invite'),
                          child: const Text('Yeni Kod Gir'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          String clinicName = widget.initialClinicName ?? 'Veteriner Kliniği';
          if (state is ClinicInviteValidated) {
            clinicName = state.clinicName;
          } else if (state is ClinicInviteError && state.clinicName != null) {
            clinicName = state.clinicName!;
          }

          final isSubmitting = state is ClinicInviteSubmitting;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Doğrulanmış Klinik Rozeti
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                              border:
                                  Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Davet Edilen Klinik',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        clinicName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Veteriner Hekim Kaydı',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hesabınızı oluşturarak $clinicName bünyesinde hasta ve muayene yönetimine başlayabilirsiniz.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Hata Durumu (Kayıt / Bağlantı hatası)
                          if (state is ClinicInviteError) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                                border:
                                    Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: theme.colorScheme.error, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: TextStyle(
                                          color: theme.colorScheme.onErrorContainer,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Ad Soyad
                          TextFormField(
                            controller: _nameController,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              labelText: 'Ad Soyad',
                              hintText: 'Dr. Ahmet Yılmaz',
                              prefixIcon:
                                  const Icon(Icons.person_outline_rounded),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen adınızı ve soyadınızı giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // E-posta
                          TextFormField(
                            controller: _emailController,
                            enabled: !isSubmitting,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'E-posta Adresi',
                              hintText: 'hekim@klinik.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen e-posta adresinizi giriniz';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Geçerli bir e-posta adresi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telefon (Opsiyonel)
                          TextFormField(
                            controller: _phoneController,
                            enabled: !isSubmitting,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Telefon Numarası (Opsiyonel)',
                              hintText: '05XX XXX XX XX',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          TextFormField(
                            controller: _passwordController,
                            enabled: !isSubmitting,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              hintText:
                                  'En az 8 karakter, harf ve rakam içermelidir',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 28),

                          // Kaydol ve Kliniğe Katıl Butonu
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => _onSubmit(clinicName),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Kaydı Tamamla ve Kliniğe Katıl',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        },
      ),
    );
  }
}
