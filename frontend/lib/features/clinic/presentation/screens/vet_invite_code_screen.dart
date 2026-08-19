import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/clinic_invite_cubit.dart';
import '../cubit/clinic_invite_state.dart';

class VetInviteCodeScreen extends StatefulWidget {
  final String? initialToken;

  const VetInviteCodeScreen({super.key, this.initialToken});

  @override
  State<VetInviteCodeScreen> createState() => _VetInviteCodeScreenState();
}

class _VetInviteCodeScreenState extends State<VetInviteCodeScreen> {
  late final TextEditingController _codeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialToken ?? '');

    // Eğer linkten bir token gelmişse otomatik doğrulamayı başlat
    if (widget.initialToken != null && widget.initialToken!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ClinicInviteCubit>().validateToken(widget.initialToken!);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ClinicInviteCubit>().validateToken(_codeController.text);
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
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: BlocConsumer<ClinicInviteCubit, ClinicInviteState>(
        listener: (context, state) {
          if (state is ClinicInviteValidated) {
            // Kod geçerli -> Kayıt formuna yönlendir
            context.go(
              '/vet/invite/register?token=${Uri.encodeComponent(state.token)}&clinicName=${Uri.encodeComponent(state.clinicName)}',
            );
          }
        },
        builder: (context, state) {
          final isValidating = state is ClinicInviteValidating;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Klinik / Anahtar İkonu
                          Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                size: 34,
                                color: Color(0xFF14B8A6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Başlık & Açıklama
                          Text(
                            'Klinik Davet Kodu',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'VetTrack hekim paneline katılmak için klinik yöneticiniz tarafından iletilen davet kodunu giriniz.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Hata Mesajı Gösterimi
                          if (state is ClinicInviteError) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getErrorTitle(state.type),
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.message,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppColors.onErrorContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Kod Giriş Alanı
                          TextFormField(
                            controller: _codeController,
                            enabled: !isValidating,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Davet Kodu',
                              hintText: 'Örn: INV-8F92A1...',
                              prefixIcon: const Icon(Icons.vpn_key_rounded),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen davet kodunu giriniz';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _onValidate(),
                          ),
                          const SizedBox(height: 24),

                          // Doğrula Butonu
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: isValidating ? null : _onValidate,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF14B8A6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                ),
                              ),
                              child: isValidating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Kodu Doğrula ve İlerle',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Zaten Hesabım Var Linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Zaten kayıtlı mısınız? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14B8A6),
                                  ),
                                ),
                              ),
                            ],
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

  String _getErrorTitle(ClinicInviteErrorType type) {
    switch (type) {
      case ClinicInviteErrorType.expired:
        return 'Davet Kodunun Süresi Dolmuş';
      case ClinicInviteErrorType.alreadyUsed:
        return 'Kod Daha Önce Kullanılmış';
      case ClinicInviteErrorType.invalid:
        return 'Geçersiz Davet Kodu';
      case ClinicInviteErrorType.network:
        return 'Bağlantı Hatası';
      default:
        return 'Davet Doğrulanamadı';
    }
  }
}
