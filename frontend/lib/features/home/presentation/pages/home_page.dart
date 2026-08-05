import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../features/pet/presentation/cubit/pet_cubit.dart';
import '../../../../features/pet/presentation/cubit/pet_state.dart';
import '../../../../core/constants/app_dimensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında pet listesini tazele
    context.read<PetCubit>().fetchPets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const peachBg = Color(0xFFFFECE5);
    const peachBorder = Color(0xFFFFB89C);
    const peachText = Color(0xFFD9531E);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userName = authState is Authenticated ? authState.user.name : 'Misafir';
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium & Kompakt Üst Karşılama Alanı (SliverAppBar)
              SliverAppBar(
                expandedHeight: 135,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                elevation: 0,
                // Kavisli modern alt kenar tasarımı (Yüksekliği azaltılmış ve sadeleştirilmiş)
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.containerMargin,
                        right: AppDimensions.containerMargin,
                        bottom: 18,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Merhaba,',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '$userName 👋',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                              onPressed: () => context.push('/notifications'),
                              tooltip: 'Bildirimler',
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // İçerik Listesi
              SliverList(
                delegate: SliverChildListDelegate([
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
                        _buildQuickActionCard(
                          context,
                          title: 'Kişisel Bilgiler',
                          subtitle: 'Profilinizi görüntüleyin',
                          icon: Icons.person_outline,
                          color: const Color(0xFFEFF6FF),
                          iconColor: theme.colorScheme.primary,
                          onTap: () => context.push('/owner/profile'),
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
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      theme.colorScheme.primary.withValues(alpha: 0.03),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                    width: 1.2,
                                  ),
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
                                                style: theme.textTheme.labelMedium?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w700,
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
        // İkon rengiyle uyumlu belirgin çerçeve
        border: Border.all(
          color: iconColor.withValues(alpha: 0.12),
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
