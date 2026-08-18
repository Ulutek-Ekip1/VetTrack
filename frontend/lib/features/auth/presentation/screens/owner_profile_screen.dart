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
                          onTap: () {},
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
