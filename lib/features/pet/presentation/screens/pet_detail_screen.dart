import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;

  const PetDetailScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Detayı (#$petId)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
            onPressed: () {
              context.push('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
            onPressed: () {
              context.push('/owner/pets/$petId/edit');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.pets, size: 40, color: Colors.teal),
                title: Text(
                  'Evcil Hayvan ID: $petId',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text('Sağlık Durumu: Sağlıklı | Aşılar: Güncel'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/owner/pets/$petId/recommendations');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Sağlık & Bakım Önerileri'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/owner/pets/$petId/edit');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Pet Bilgilerini Düzenle'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                context.push('/owner/pets/$petId/visits');
              },
              icon: const Icon(Icons.history_edu),
              label: const Text('Geçmiş Ziyaretler & Muayeneler'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                context.push('/owner/pets/$petId/treatments');
              },
              icon: const Icon(Icons.vaccines),
              label: const Text('Tedaviler & Aşı Takvimi'),
            ),
          ],
        ),
      ),
    );
  }
}
