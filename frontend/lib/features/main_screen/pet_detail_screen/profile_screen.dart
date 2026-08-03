import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_cubit.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_state.dart';

import 'pet_photo.dart';
import 'timeline_tile.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pet Detayı'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: BlocBuilder<PetCubit, PetState>(
            builder: (context, state) {
              if (state is PetLoaded) {
                final pet = state.pets.isNotEmpty ? state.pets.first : null;
                return Column(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          PetPhoto(pet: pet),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(pet?.name ?? "Bilgi yok",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: const Color(0xFFFFDBCE),
                                ),
                                child: Text(pet?.uniqueCode ?? "Bilgi yok",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Text(pet?.gender.name ?? "Bilgi yok",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        )),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Text(pet?.breed ?? "Bilgi yok",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // --- SAĞLIK GEÇMİŞİ (TIMELINE) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sağlık Geçmişi",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          TimelineTile(
                            isFirst: true,
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  size: 20),
                            ),
                            title: "Genel Muayene",
                            date: "12 Eki",
                            description:
                                "Yıllık kontrolleri tamamlandı. Genel sağlık durumu iyi.",
                          ),
                          TimelineTile(
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 2),
                              ),
                              child: Icon(Icons.medical_services_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 18),
                            ),
                            title: "Yeni Reçete",
                            titleTrailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Yeni",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            date: "Bugün",
                            description:
                                "Vitamin takviyesi yazıldı. Günde 1 tablet.",
                          ),
                          TimelineTile(
                            isLast: true,
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    width: 2),
                              ),
                              child: Icon(Icons.history,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 18),
                            ),
                            title: "Geçmiş Aşılama",
                            dateWidget: Icon(Icons.lock_outline,
                                color: Theme.of(context).colorScheme.outline,
                                size: 16),
                            description: "Kayıt arşivlendi.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Profil bilgisi yükleniyor..."),
              );
            },
          ),
        ),
      ),
    );
  }
}
