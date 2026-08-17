import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_platform.dart';
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

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            // Vet portal access is granted only after a clinic invite is accepted.
            UserRole.owner,
          );
    }
  }

  // KVKK Aydınlatma Metni Diyaloğu
  void _showKvkkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("KVKK Aydınlatma Metni"),
        content: const SingleChildScrollView(
          child: Text(
            """VETTRACK KİŞİSEL VERİLERİN İŞLENMESİ AYDINLATMA METNİ

1. Veri Sorumlusunun Kimliği
VetTrack ("Şirket/Geliştirici") olarak, 6698 sayılı Kişisel Verileri Koruma Kanunu (“KVKK”) uyarınca, veri sorumlusu sıfatıyla kişisel verilerinizi aşağıda açıklanan kapsamda işlemekteyiz.

2. İşlenen Kişisel Verileriniz ve İşleme Amaçları
VetTrack platformuna kayıt olmanız ve hizmetlerimizi kullanmanız kapsamında,
- Kimlik Verileri: Ad, soyad
- İletişim Verileri: E-posta adresi, telefon numarası
- İşlem Güvenliği Verileri: Şifre, IP adresi, giriş kayıtları
- Hizmet/Sistem Verileri: Evcil hayvan profilleri, aşı ve muayene takip takvimleri

Bu veriler, üyelik kayıt süreçlerinin yürütülmesi, evcil hayvan sağlık ve bakım takibinin sağlanması, kullanıcı hesabının güvenliğinin temini ve sistem hatalarının giderilmesi amaçlarıyla işlenmektedir.

3. Kişisel Verilerin Aktarılması
Kişisel verileriniz, kanunen yetkili kamu kurum ve kuruluşları ile uygulamanın teknik altyapısını sağlayan güvenli sunucu (hosting/cloud) hizmet sağlayıcıları dışında üçüncü şahıslarla paylaşılmamaktadır.

4. Toplama Yöntemi ve Hukuki Sebebi
Verileriniz, elektronik ortamda kayıt formu aracılığıyla; "Bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması" ve "Veri sorumlusunun hukuki yükümlülüğünü yerine getirebilmesi" hukuki sebeplerine dayanarak toplanmaktadır.

5. KVKK Madde 11 Kapsamındaki Haklarınız
Veri sahibi olarak; verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, silinmesini veya düzeltilmesini isteme haklarına sahipsiniz. Haklarınızı kullanmak için destek@vettrack.com adresi üzerinden bizimle iletişime geçebilirsiniz.""",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _kvkkApproved = true;
              });
              _formKey.currentState?.validate();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text("Okudum, Anladım"),
          ),
        ],
      ),
    );
  }

  // Açık Rıza Metni Diyaloğu
  void _showExplicitConsentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Açık Rıza Metni"),
        content: const SingleChildScrollView(
          child: Text(
            """VETTRACK AÇIK RIZA METNİ

VetTrack tarafından, sunulan hizmetlerin iyileştirilmesi, kampanya,
bildirim ve hatırlatmaların (aşı günü, parazit takibi vb.) e-posta 
veya mobil bildirim yoluyla tarafıma iletilmesi amacıyla iletişim 
verilerimin işlenmesine ve kampanya/bilgilendirme iletileri gönderilmesine
özgür irademle onay veriyorum.""",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _explicitConsentApproved = true;
              });
              _formKey.currentState?.validate();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text("Okudum, Anladım"),
          ),
        ],
      ),
    );
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
                  if (state is RegistrationSuccess) {
                    context.go(
                      AppPlatform.isVetWebExperience
                          ? AppRoutes.vetSearch
                          : AppRoutes.ownerEmailVerification,
                      extra: _emailController.text.trim(),
                    );
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
                          color: const Color(0xFF7B4832),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B4832)
                                  .withValues(alpha: 0.25),
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
                            Colors.white,
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
                          color: const Color(0xFF7B4832),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Kutulu Form Kartı (Card Container)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color:
                                AppColors.outlineVariant.withValues(alpha: 0.5),
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
                                // Başlık
                                Text(
                                  AppPlatform.isVetWebExperience
                                      ? "Veteriner Personel Kaydı"
                                      : "Kayıt Ol",
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7B4832),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  AppPlatform.isVetWebExperience
                                      ? "Klinik paneli için veteriner personel hesabınızı oluşturun."
                                      : "Evcil hayvanınızın sağlığını takip etmeye bugün başlayın.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Ad-Soyad TextFormField
                                TextFormField(
                                  controller: _nameController,
                                  autofillHints: const [AutofillHints.name],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    label: const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: "Ad Soyad"),
                                          TextSpan(
                                            text: " *",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    hintText: "Adınızı ve soyadınızı giriniz",
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
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
                                        color: Color(0xFF7B4832),
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
                                  autofillHints: const [AutofillHints.email],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    label: const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: "E-posta Adresi"),
                                          TextSpan(
                                            text: " *",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                        color: Color(0xFF7B4832),
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
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber
                                  ],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: "Telefon (Opsiyonel)",
                                    hintText: "05XX XXX XX XX",
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
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
                                        color: Color(0xFF7B4832),
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
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    label: const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: "Şifre"),
                                          TextSpan(
                                            text: " *",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    hintText: "Şifrenizi giriniz",
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
                                        color: Color(0xFF7B4832),
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

                                // KVKK Aydınlatma Metni Checkbox
                                FormField<bool>(
                                  validator: (_) {
                                    if (!_kvkkApproved) {
                                      return 'Devam etmek için Aydınlatma Metnini onaylamalısınız.';
                                    }
                                    return null;
                                  },
                                  builder: (fieldState) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _kvkkApproved,
                                                activeColor:
                                                    const Color(0xFF7B4832),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _kvkkApproved =
                                                        val ?? false;
                                                  });
                                                  fieldState
                                                      .didChange(_kvkkApproved);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: _showKvkkDialog,
                                                    child: Text(
                                                      'Aydınlatma Metni',
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        color: const Color(
                                                            0xFF7B4832),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        const TextSpan(
                                                          text: ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '\'ni okudum ve onaylıyorum.',
                                                          style: theme.textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (fieldState.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6, left: 32),
                                            child: Text(
                                              fieldState.errorText!,
                                              style: TextStyle(
                                                color: theme.colorScheme.error,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Açık Rıza Metni Checkbox
                                FormField<bool>(
                                  validator: (_) {
                                    if (!_explicitConsentApproved) {
                                      return 'Devam etmek için Açık Rıza Metnini onaylamalısınız.';
                                    }
                                    return null;
                                  },
                                  builder: (fieldState) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _explicitConsentApproved,
                                                activeColor:
                                                    const Color(0xFF7B4832),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _explicitConsentApproved =
                                                        val ?? false;
                                                  });
                                                  fieldState.didChange(
                                                      _explicitConsentApproved);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap:
                                                        _showExplicitConsentDialog,
                                                    child: Text(
                                                      'Açık Rıza Metni',
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        color: const Color(
                                                            0xFF7B4832),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        const TextSpan(
                                                          text: ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '\'ni okudum ve kabul ediyorum.',
                                                          style: theme.textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (fieldState.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6, left: 32),
                                            child: Text(
                                              fieldState.errorText!,
                                              style: TextStyle(
                                                color: theme.colorScheme.error,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Kayıt Ol Butonu
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFB89C),
                                      foregroundColor: const Color(0xFF131B2E),
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
                                              color: Color(0xFF131B2E),
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
                                                  color:
                                                      const Color(0xFF131B2E),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                                color: Color(0xFF131B2E),
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
                                color: const Color(0xFF7B4832),
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
