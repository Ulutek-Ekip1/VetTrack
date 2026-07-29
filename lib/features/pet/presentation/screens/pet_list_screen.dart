import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockPets = [
      {'id': '101', 'name': 'Pamuk', 'species': 'Kedi', 'breed': 'Tekir'},
      {'id': '102', 'name': 'Gölge', 'species': 'Köpek', 'breed': 'Golden Retriever'},
      {'id': '103', 'name': 'Maviş', 'species': 'Kuş', 'breed': 'Muhabbet Kuşu'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evcil Hayvanlarım'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutSubmittedEvent());
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockPets.length,
        itemBuilder: (context, index) {
          final pet = mockPets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  pet['species'] == 'Kedi' ? Icons.pets : Icons.cruelty_free,
                  color: Colors.teal,
                ),
              ),
              title: Text(
                pet['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${pet['species']} • ${pet['breed']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/owner/pets/${pet['id']}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addPet);
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Pet Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
