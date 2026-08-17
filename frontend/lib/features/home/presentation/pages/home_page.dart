import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../features/pet/presentation/cubit/pet_cubit.dart';
import '../../../../features/pet/presentation/cubit/pet_state.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../../../features/notification/presentation/widgets/notification_badge_button.dart';
import '../../../../l10n/generated/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AuthorizationStatus? _notificationPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Sayfa açıldığında pet listesini tazele
    context.read<PetCubit>().fetchPets();
    context.read<NotificationCubit>().loadNotifications();
    _refreshNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationPermission();
    }
  }

  Future<void> _refreshNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (mounted) {
      setState(() => _notificationPermission = settings.authorizationStatus);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await sl<FirebaseMessagingService>().requestPermissionFromUser();
    if (mounted) setState(() => _notificationPermission = status);
  }

  Future<void> _openNotificationSettings() async {
    final opened = await sl<FirebaseMessagingService>().openNotificationSettings();
    if (!mounted || opened) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enableNotifications),
        content: Text(AppLocalizations.of(context)!.enableNotificationsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userName = authState is Authenticated ? authState.user.name : 'Misafir';
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 185,
                    color: const Color(0xFF004AC6),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 54, // Clear status bar
                      bottom: 40,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
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
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$userName 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NotificationBadgeButton(
                          iconColor: Colors.white,
                          iconSize: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik Listesi
              SliverList(
                delegate: SliverChildListDelegate([
                  if (_notificationPermission == AuthorizationStatus.notDetermined || _notificationPermission == AuthorizationStatus.denied)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active_outlined),
                          title: Text(l10n.doNotMissVisitUpdates),
                          subtitle: Text(_notificationPermission == AuthorizationStatus.denied ? l10n.notificationPermissionDenied : l10n.notificationPermissionPrompt),
                          trailing: TextButton(
                            onPressed: _notificationPermission == AuthorizationStatus.denied
                                ? _openNotificationSettings
                                : _requestNotificationPermission,
                            child: Text(_notificationPermission == AuthorizationStatus.denied
                                ? l10n.openSettings
                                : l10n.enable),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16), // Boşluk daraltıldı (24 -> 16)

                  // Hızlı İşlemler
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                    child: Text(
                      'Hızlı İşlemler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF131B2E),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Boşluk daraltıldı (12 -> 8)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
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
                            if (petState is PetLoaded && petState.pets.isNotEmpty) {
                              context.push('/owner/pets/${petState.pets.first.id}/treatments');
                            } else {
                              context.push('/owner/pets');
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

                  const SizedBox(height: 24), // Boşluk daraltıldı (28 -> 24)

                  // Dostlarım Bölümü
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sevgili Dostlarım',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF131B2E),
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/owner/pets'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Tümünü Gör', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          return const Center(child: CircularProgressIndicator());
                        } else if (petState is PetLoaded) {
                          final pets = petState.pets;
                          if (pets.isEmpty) {
                            return Center(
                              child: Text(
                                'Kayıtlı evcil hayvanınız bulunmuyor.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return Container(
                                width: 215,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF), // Eşleşen açık mavi renk
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  onTap: () => context.push('/owner/pets/${pet.id}'),
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  hoverColor: theme.colorScheme.primary.withValues(alpha: 0.04),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: const Color(0xFFDBEAFE),
                                          backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                                              ? NetworkImage(pet.photoUrl!)
                                              : null,
                                          child: pet.photoUrl == null || pet.photoUrl!.isEmpty
                                              ? Icon(Icons.pets, size: 30, color: theme.colorScheme.primary)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                pet.name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF131B2E),
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pet.breed ?? 'Tür Belirtilmemiş',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${pet.age ?? 0} yaşında',
                                                style: const TextStyle(
                                                  color: Color(0xFF004AC6),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 20px oval köşeler
        // Degradeli modern kart arka planı (Soluk uygun ton geçişi)
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // İkon rengiyle uyumlu daha belirgin çerçeve
        border: Border.all(
          color: iconColor.withValues(alpha: 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.03),
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
          // Dinamik eşleşen hover ve splash dalgalanma efekti
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
                    color: color,
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
                          color: const Color(0xFF131B2E),
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
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
