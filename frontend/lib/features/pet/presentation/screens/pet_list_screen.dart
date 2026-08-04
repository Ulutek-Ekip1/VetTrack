import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';
import '../widgets/pet_card.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PetCubit>().fetchPets();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);
    const labelGray = Color(0xFF737686);
    const bgGray = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'Hayvanlarım',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF434655)),
            tooltip: 'Bildirimler',
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF434655)),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: BlocConsumer<PetCubit, PetState>(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // Arama Çubuğu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'İsim veya 6 haneli kod ile ara...',
                          hintStyle: TextStyle(color: labelGray, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: labelGray),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hayvan Kartları Listesi
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPets.length,
                      itemBuilder: (context, index) {
                        final pet = filteredPets[index];
                        return PetCard(pet: pet);
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
                          Container(width: double.infinity, height: 16, color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),
                          Container(width: 100, height: 12, color: const Color(0xFFF1F5F9)),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF131B2E)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: onAddTap,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Hayvan Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              Text('Çevrimdışı moddasınız', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.cloud_off, size: 80, color: Color(0xFF737686)),
                  const SizedBox(height: 16),
                  const Text(
                    'Bağlantı Hatası',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF131B2E)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
