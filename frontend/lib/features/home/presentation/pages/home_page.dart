import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../features/pet/presentation/cubit/pet_cubit.dart';
import '../../../../features/pet/presentation/cubit/pet_state.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/profile_state.dart';
import '../../../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../../../features/notification/presentation/widgets/notification_badge_button.dart';
import '../../../../features/notification/presentation/widgets/notification_permission_dialog.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/firebase_messaging_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static bool _hasShownPermissionDialogInSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Sayfa açıldığında pet listesini tazele
    context.read<PetCubit>().fetchPets();
    context.read<NotificationCubit>().loadNotifications();
    if (context.read<ProfileCubit>().state is ProfileInitial) {
      context.read<ProfileCubit>().fetchProfile();
    }
    _checkAndPromptNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<FirebaseMessagingService>().flushPendingNavigation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationCubit>().loadNotifications();
      _checkAndPromptNotificationPermission();
    }
  }

  Future<void> _checkAndPromptNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final status = settings.authorizationStatus;

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      try {
        await sl<FirebaseMessagingService>().syncTokenIfAuthorized();
      } catch (_) {
        // Token sonraki girişte veya uygulama resume olduğunda tekrar denenir.
      }
      return;
    }

    if (!_hasShownPermissionDialogInSession &&
        (status == AuthorizationStatus.notDetermined ||
            status == AuthorizationStatus.denied)) {
      _hasShownPermissionDialogInSession = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          NotificationPermissionDialog.show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userName =
              authState is Authenticated ? authState.user.name : 'Misafir';
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 185,
                    color: theme.colorScheme.primary,
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 54, // Clear status bar
                      bottom: 40,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, profileState) {
                            String? photoUrl;
                            if (profileState is ProfileLoaded) {
                              photoUrl = profileState.profile.profilePhotoUrl;
                            }

                            ImageProvider? avatarImage;
                            if (photoUrl != null && photoUrl.isNotEmpty) {
                              if (photoUrl.startsWith('http')) {
                                avatarImage = NetworkImage(photoUrl);
                              } else {
                                avatarImage = FileImage(File(photoUrl));
                              }
                            }

                            return CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merhaba,',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$userName 👋',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NotificationBadgeButton(
                          iconColor: theme.colorScheme.onPrimary,
                          iconSize: 22,
                          backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik Listesi
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // Hızlı İşlemler
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.containerMargin),
                    child: Text(
                      'Hızlı İşlemler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.containerMargin),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _buildQuickActionCard(
                          context,
                          title: 'AI Asistan',
                          subtitle: 'Sağlık & bakım danışmanı',
                          icon: Icons.auto_awesome,
                          color: const Color(0xFFFFECE5),
                          iconColor: const Color(0xFFD9531E),
                          onTap: () => context.push('/chatbot'),
                        ),
                        _buildQuickActionCard(
                          context,
                          title: 'Dost Ekle',
                          subtitle: 'Yeni evcil hayvan kaydet',
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFFEEF2F6),
                          iconColor: theme.colorScheme.primary,
                          onTap: () => context.push('/owner/pets/add'),
                        ),
                        _buildQuickActionCard(
                          context,
                          title: 'Tedaviler',
                          subtitle: 'Tedavi geçmişi ve reçeteler',
                          icon: Icons.healing_outlined,
                          color: const Color(0xFFFFF1F2),
                          iconColor: const Color(0xFFF43F5E),
                          onTap: () {
                            final petState = context.read<PetCubit>().state;
                            if (petState is PetLoaded &&
                                petState.pets.isNotEmpty) {
                              if (petState.pets.length == 1) {
                                context.push(
                                    '/owner/pets/${petState.pets.first.id}/treatments');
                              } else {
                                _showPetSelectionSheet(context, petState.pets);
                              }
                            } else {
                              context.go('/owner/pets');
                            }
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          title: 'Ziyaretlerim',
                          subtitle: 'Muayene geçmişi',
                          icon: Icons.assignment_outlined,
                          color: const Color(0xFFFDF2F8),
                          iconColor: const Color(0xFFDB2777),
                          onTap: () => context.push('/owner/visits'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dostlarım Bölümü
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.containerMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sevgili Dostlarım',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/owner/pets'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Tümünü Gör',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Evcil Hayvan Yatay Listesi
                  SizedBox(
                    height: 148,
                    child: BlocBuilder<PetCubit, PetState>(
                      builder: (context, petState) {
                        if (petState is PetLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (petState is PetLoaded) {
                          final pets = petState.pets;
                          if (pets.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Kayıtlı evcil hayvanınız bulunmuyor.',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => context.push('/owner/pets/add'),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Hemen Ekle'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.containerMargin),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return Container(
                                width: 215,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      context.go('/owner/pets/${pet.id}'),
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  hoverColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.04),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              theme.colorScheme.primaryContainer,
                                          backgroundImage:
                                              pet.photoUrl != null &&
                                                      pet.photoUrl!.isNotEmpty
                                                  ? NetworkImage(pet.photoUrl!)
                                                  : null,
                                          child: pet.photoUrl == null ||
                                                  pet.photoUrl!.isEmpty
                                              ? Icon(Icons.pets,
                                                  size: 30,
                                                  color:
                                                      theme.colorScheme.primary)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                pet.name,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.onSurface,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pet.breed ??
                                                    'Tür Belirtilmemiş',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${pet.age ?? 0} yaşında',
                                                style: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark
        ? theme.colorScheme.surfaceContainerLowest
        : theme.colorScheme.surfaceContainerLowest;
    final badgeBgColor = isDark
        ? iconColor.withValues(alpha: 0.2)
        : color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            cardBgColor,
            isDark
                ? iconColor.withValues(alpha: 0.12)
                : color.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : iconColor.withValues(alpha: 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: iconColor.withValues(alpha: 0.15),
          hoverColor: iconColor.withValues(alpha: 0.08),
          highlightColor: iconColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPetSelectionSheet(BuildContext context, List<PetEntity> pets) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.healing_rounded, color: Color(0xFFF43F5E)),
                    const SizedBox(width: 8),
                    Text(
                      'Tedavi Geçmişi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Lütfen tedavi geçmişini görüntülemek istediğiniz dostunuzu seçin:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      ImageProvider? petImage;
                      if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
                        if (pet.photoUrl!.startsWith('http')) {
                          petImage = NetworkImage(pet.photoUrl!);
                        } else {
                          petImage = FileImage(File(pet.photoUrl!));
                        }
                      }

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          backgroundImage: petImage,
                          child: petImage == null
                              ? Icon(
                                  Icons.pets_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                )
                              : null,
                        ),
                        title: Text(
                          pet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${pet.breed ?? 'Evcil Hayvan'}${pet.age != null ? " • ${pet.age} Yaşında" : ""}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/owner/pets/${pet.id}/treatments');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    final firstControlPoint = Offset(size.width * 0.25, size.height - 40);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height);
    final secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
