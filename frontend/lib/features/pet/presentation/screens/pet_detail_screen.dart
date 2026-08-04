import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;

  const PetDetailScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'Dost Detayı',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF434655)),
            tooltip: 'Bildirimler',
            onPressed: () {
              context.push('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF434655)),
            tooltip: 'Düzenle',
            onPressed: () {
              context.push('/owner/pets/$petId/edit');
            },
          ),
        ],
      ),
      body: BlocBuilder<PetCubit, PetState>(
        builder: (context, state) {
          if (state is PetLoaded) {
            try {
              final pet = state.pets.firstWhere((p) => p.id == petId);

              String speciesText = '';
              String breedText = pet.breed ?? '';
              if (pet.breed != null && pet.breed!.contains(' / ')) {
                final parts = pet.breed!.split(' / ');
                speciesText = parts[0];
                breedText = parts[1];
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'pet-photo-${pet.id}',
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFDBEAFE),
                                backgroundImage: pet.photoUrl != null &&
                                        pet.photoUrl!.isNotEmpty
                                    ? NetworkImage(pet.photoUrl!)
                                    : null,
                                child:
                                    pet.photoUrl == null || pet.photoUrl!.isEmpty
                                        ? const Icon(Icons.pets,
                                            size: 36, color: primaryBlue)
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Color(0xFF131B2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (speciesText.isNotEmpty)
                                    Text(
                                      'Tür: $speciesText',
                                      style: const TextStyle(
                                          color: Color(0xFF737686),
                                          fontSize: 14),
                                    ),
                                  if (breedText.isNotEmpty)
                                    Text(
                                      'Cins / Irk: $breedText',
                                      style: const TextStyle(
                                          color: Color(0xFF737686),
                                          fontSize: 14),
                                    ),
                                  if (pet.age != null)
                                    Text(
                                      'Yaş: ${pet.age} yaş',
                                      style: const TextStyle(
                                          color: Color(0xFF737686),
                                          fontSize: 14),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Eşsiz Kod: ${pet.uniqueCode}',
                                    style: const TextStyle(
                                      color: primaryBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/owner/pets/$petId/recommendations');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('AI Sağlık & Bakım Önerileri',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/owner/pets/$petId/edit');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue, width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        foregroundColor: primaryBlue,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Bilgileri Düzenle',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/owner/pets/$petId/visits');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue, width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        foregroundColor: primaryBlue,
                      ),
                      icon: const Icon(Icons.history_edu),
                      label: const Text('Geçmiş Ziyaretler & Muayeneler',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/owner/pets/$petId/treatments');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue, width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        foregroundColor: primaryBlue,
                      ),
                      icon: const Icon(Icons.vaccines),
                      label: const Text('Tedaviler & Aşı Takvimi',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } catch (_) {}
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
