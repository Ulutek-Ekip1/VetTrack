import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';
import '../widgets/pet_card.dart';
import '../../../notification/presentation/widgets/notification_badge_button.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<PetCubit>().fetchPets();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase().trim();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);
    const labelGray = Color(0xFF737686);
    const bgGray = Color(0xFFF1F5F9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: bgGray,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          title: Text(
            'Hayvanlarım',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        body: BlocConsumer<PetCubit, PetState>(
          buildWhen: (previous, current) {
            // Aksiyon durumlarında (PetActionLoading, PetActionError vb.)
            // ana listeyi sıfırlamamak/kaybetmemek için ekranı yeniden çizme.
            return current is PetLoading ||
                current is PetLoaded ||
                current is PetError;
          },
          listener: (context, state) {
            if (state is PetActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF006B5F),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is PetActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // --- 1. YÜKLENME (SKELETON) DURUMU ---
            if (state is PetLoading) {
              return const SkeletonLoadingView();
            }

            // --- 3. ÇEVRİMDIŞI / HATA DURUMU ---
            if (state is PetError) {
              return OfflineErrorView(
                errorMessage: state.message,
                onRetry: () => context.read<PetCubit>().fetchPets(),
              );
            }

            if (state is PetLoaded) {
              final filteredPets = state.pets.where((pet) {
                return pet.name.toLowerCase().contains(_searchQuery) ||
                    pet.uniqueCode.toLowerCase().contains(_searchQuery);
              }).toList();

              // --- 2. BOŞ DURUM (EMPTY DASHBOARD) ---
              if (state.pets.isEmpty) {
                return EmptyDashboardView(
                  onAddTap: () => context.push(AppRoutes.addPet),
                );
              }

              return RefreshIndicator(
                color: primaryBlue,
                onRefresh: () => context.read<PetCubit>().fetchPets(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    children: [
                      // Arama Çubuğu
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'İsim veya 6 haneli kod ile ara...',
                          hintStyle:
                              const TextStyle(color: labelGray, fontSize: 14),
                          prefixIcon:
                              const Icon(Icons.search, color: labelGray),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: primaryBlue, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Hayvan Kartları Listesi (Kademeli Animasyon ve Swipe to Action ile)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = filteredPets[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 300 + (index * 80)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Dismissible(
                              key: Key('pet-dismiss-${pet.id}'),
                              background: _buildSwipeBackground(
                                context: context,
                                alignment: Alignment.centerLeft,
                                color: Theme.of(context).colorScheme.secondary,
                                icon: Icons.edit,
                                label: 'Düzenle',
                              ),
                              secondaryBackground: _buildSwipeBackground(
                                context: context,
                                alignment: Alignment.centerRight,
                                color: Theme.of(context).colorScheme.error,
                                icon: Icons.delete_forever,
                                label: 'Sil',
                              ),
                              confirmDismiss: (direction) async {
                                final theme = Theme.of(context);
                                if (direction == DismissDirection.endToStart) {
                                  // Silme
                                  bool deleteConfirmed = false;
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Evcil Hayvanı Sil'),
                                      content: Text(
                                          '${pet.name} isimli evcil hayvanı silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('İptal'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            foregroundColor:
                                                theme.colorScheme.onError,
                                          ),
                                          onPressed: () {
                                            deleteConfirmed = true;
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Sil'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (deleteConfirmed && context.mounted) {
                                    context
                                        .read<PetCubit>()
                                        .deletePet(id: pet.id);
                                    return true;
                                  }
                                  return false;
                                } else {
                                  // Düzenleme
                                  context.push('/owner/pets/${pet.id}/edit');
                                  return false; // listeden silinmesin
                                }
                              },
                              child: PetCard(pet: pet),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push(AppRoutes.addPet);
          },
          backgroundColor: primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Yeni Hayvan Ekle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required BuildContext context,
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14.0), // PetCard alt boşluğuyla uyumlu
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(16.0), // PetCard köşe kavisiyle uyumlu
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 22),
              ],
      ),
    );
  }
}

// ==========================================
// 1. SKELETON LOADING YARIMCI WIDGET
// ==========================================
class SkeletonLoadingView extends StatelessWidget {
  const SkeletonLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Color(0xFF737686)),
                SizedBox(width: 8),
                Text(
                  'İsim veya 6 haneli kod ile ara...',
                  style: TextStyle(color: Color(0xFF737686), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              height: 16,
                              color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),
                          Container(
                              width: 100,
                              height: 12,
                              color: const Color(0xFFF1F5F9)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. EMPTY DASHBOARD YARDIMCI WIDGET
// ==========================================
class EmptyDashboardView extends StatelessWidget {
  final VoidCallback onAddTap;

  const EmptyDashboardView({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 72, color: Color(0xFF004AC6)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz bir evcil hayvan eklemedin',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF131B2E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aşağıdaki "Yeni Hayvan Ekle" butonuna basarak ilk evcil hayvanınızın profilini oluşturun.',
              style: TextStyle(fontSize: 14, color: Color(0xFF434655)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: onAddTap,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Hayvan Ekle',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. OFFLINE ERROR YARDIMCI WIDGET
// ==========================================
class OfflineErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const OfflineErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFF59E0B),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Çevrimdışı moddasınız',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off,
                      size: 80, color: Color(0xFF737686)),
                  const SizedBox(height: 16),
                  const Text(
                    'Bağlantı Hatası',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131B2E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VetTrack sunucularına şu anda ulaşılamıyor. Hata: $errorMessage. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF434655)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
