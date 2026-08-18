import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/profile_state.dart';
import '../../../../core/widgets/image_picker_bottom_sheet.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import 'faq_screen.dart';
class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'Profilim',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            final userName = user?.name ?? 'Hayvan Sahibi';
            final userEmail = user?.email ?? 'eposta@vettrack.com';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              child: Column(
                children: [
                  // Profil Üst Kartı (Avatar & Bilgiler)
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          _OwnerProfileAvatar(
                            userName: userName,
                            theme: theme,
                            primaryBlue: primaryBlue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF131B2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userEmail,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Hayvan Sahibi',
                                    style: TextStyle(
                                      color: Color(0xFF047857),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                // Hesap Ayarları Grubu
                _buildSectionHeader(context, 'Hesap Ayarları'),
                const SizedBox(height: AppDimensions.spacingSm),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildProfileTile(
                        context,
                        icon: Icons.person_outline,
                        title: 'Kişisel Bilgiler',
                        subtitle: 'Ad soyad, telefon ve e-posta ayarları',
                        onTap: () => context.push(AppRoutes.editProfile),
                      ),
                      _buildDivider(),
                      _buildProfileTile(
                        context,
                        icon: Icons.pets_outlined,
                        title: 'Evcil Hayvanlarım',
                        subtitle: 'Kayıtlı evcil hayvanların listesi',
                        onTap: () => context.push('/owner/pets'),
                      ),
                    ],
                  ),
                ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Destek ve Bilgi Grubu
                  _buildSectionHeader(context, 'Destek ve Bilgi'),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          context,
                          icon: Icons.help_outline,
                          title: 'Sıkça Sorulan Sorular',
                          subtitle: 'Uygulama kullanımı hakkında yardımlar',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          context,
                          icon: Icons.security_outlined,
                          title: 'Gizlilik ve Güvenlik Sözleşmesi',
                          subtitle: 'Verilerin korunması ve yasal maddeler',
                          onTap: () => _showPrivacyPolicyBottomSheet(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Çıkış Yap Butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().signOut();
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Hesaptan Çıkış Yap',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  TextButton(
                      onPressed: () {
                        context.push(AppRoutes.deleteAccount);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_outlined,
                            size: 24,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hesabımı sil',
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      )),

                  const SizedBox(height: AppDimensions.spacingLg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF131B2E),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
      indent: 56,
      endIndent: 16,
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF131B2E),
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade500,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showPrivacyPolicyBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Tutamaç & Başlık
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.security_outlined,
                              color: Color(0xFF14B8A6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gizlilik ve Güvenlik Sözleşmesi',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF131B2E),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // İçerik
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildPolicySection(
                        title: '1. Veri Sorumlusu ve KVKK Aydınlatma Metni',
                        content:
                            'VetTrack Health Systems (“VetTrack”), 6698 sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) ve ilgili mevzuat hükümleri uyarınca “Veri Sorumlusu” sıfatıyla hareket etmektedir. Kullanıcılarımıza ait kimlik (ad, soyad), iletişim (e-posta, telefon numarası) ve sistem işlem güvenliği verileri; hizmet sözleşmesinin ifası, yasal yükümlülüklerin yerine getirilmesi ve meşru menfaatler kapsamında hukuka ve dürüstlük kurallarına uygun olarak işlenmektedir.',
                      ),
                      _buildPolicySection(
                        title: '2. Evcil Hayvan Sağlık ve Tıbbi Kayıtlarının İşlenme Esasları',
                        content:
                            'Sistem üzerinde kayıt altına alınan evcil hayvan kimlik (çip numarası, ırk, doğum tarihi), aşı takvimi, muayene bulguları, teşhis, tedavi, reçete ve ağırlık geçmişi verileri; veteriner hekimlik hizmetlerinin sürekliliğini sağlamak, hasta takibini yürütmek ve acil müdahale süreçlerini desteklemek amacıyla işlenmekte ve yetkili klinik personeli ile paylaşılmaktadır.',
                      ),
                      _buildPolicySection(
                        title: '3. Bilgi Güvenliği, Şifreleme ve Altyapı Tedbirleri',
                        content:
                            'VetTrack sistemleri üzerindeki tüm ağ trafiği aktarım sırasında TLS 1.3 şifreleme protokolü ile korunmaktadır. Kullanıcı kimlik doğrulama süreçleri ES256 asimetrik anahtar imzalı JSON Web Token (JWT) standartlarına tabi olup, şifre ve kritik güvenlik parametreleri SHA-256 kriptografik özetleme yöntemleri ile muhafaza edilmektedir. Yetkisiz erişimleri engellemek adına rol tabanlı erişim kontrolü (RBAC) ve nesne düzeyinde yetki denetimleri uygulanmaktadır.',
                      ),
                      _buildPolicySection(
                        title: '4. Yapay Zekâ Destekli Sağlık Danışmanlığı Sorumluluk Reddi',
                        content:
                            'Uygulama içerisinde sunulan yapay zekâ (AI) destekli ön değerlendirme ve bilgilendirme hizmeti, kesin klinik teşhis ve tedavi niteliği taşımamaktadır. Yapay zekâ yanıtları yalnızca genel bilgilendirme ve acil durum yönlendirmesi amacına matuftur. Nihai klinik teşhis ve tedavi protokolleri münhasıran yetkili veteriner hekimin sorumluluğundadır. AI modülüne iletilen metinler ticari amaçlarla üçüncü şahıslara aktarılmamakta veya satılmamaktadır.',
                      ),
                      _buildPolicySection(
                        title: '5. İlgili Kişi Hakları ve Verilerin Silinmesi',
                        content:
                            'KVKK’nın 11. maddesi kapsamında kullanıcılar; kişisel verilerinin işlenip işlenmediğini öğrenme, amaca uygun kullanılıp kullanılmadığını denetleme ve düzeltilmesini talep etme hakkına sahiptir. Kullanıcı, dilediği zaman Profil menüsü altında yer alan “Hesabımı Sil” işlevi aracılığıyla hesabını kapatabilir ve mevzuatın zorunlu kıldığı saklama süreleri haricindeki tüm kişisel verilerinin silinmesini sağlayabilir.',
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF131B2E),
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kapat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // SSS Butonu
ListTile(
  leading: const Icon(Icons.help_outline, color: Color(0xFF2563EB)),
  title: const Text('Sıkça Sorulan Sorular'),
  onTap: () => showFAQBottomSheet(context),
),

                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF131B2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerProfileAvatar extends StatelessWidget {
  final String userName;
  final ThemeData theme;
  final Color primaryBlue;

  const _OwnerProfileAvatar({
    required this.userName,
    required this.theme,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String? photoUrl;
        if (state is ProfileLoaded) {
          photoUrl = state.profile.profilePhotoUrl;
        }

        ImageProvider? avatarImage;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          if (photoUrl.startsWith('http')) {
            avatarImage = NetworkImage(photoUrl);
          } else {
            avatarImage = FileImage(File(photoUrl));
          }
        }

        final isUploading = state is ProfileLoading;

        return GestureDetector(
          onTap: () {
            showImagePickerBottomSheet(
              context: context,
              title: 'Profil Fotoğrafı',
              showDeleteOption: photoUrl != null && photoUrl.isNotEmpty,
              onPhotoSelected: (url) {
                if (url != null) {
                  context.read<ProfileCubit>().uploadProfilePhoto(url);
                } else {
                  context.read<ProfileCubit>().deleteProfilePhoto();
                }
              },
            );
          },
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFDBEAFE),
                backgroundImage: avatarImage,
                child: isUploading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : (avatarImage == null
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
