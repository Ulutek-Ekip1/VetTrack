import 'package:flutter/material.dart';

class PetTreatmentHistoryScreen extends StatelessWidget {
  final String petId;

  const PetTreatmentHistoryScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    // Örnek tedavi & reçete geçmişi verileri
    final mockTreatments = [
      {
        'id': 'TRT-501',
        'title': 'Kuduz Aşısı',
        'category': 'Aşı',
        'date': '24.07.2026',
        'vet': 'Dr. Mehmet Yılmaz',
        'dosage': '1 Doz (Yıllık Tekrar)',
      },
      {
        'id': 'TRT-412',
        'title': 'Amoksasilin Antibiyotik',
        'category': 'İlaç',
        'date': '10.05.2026',
        'vet': 'Dr. Ayşe Kaya',
        'dosage': 'Günde 2 kez (5 Gün)',
      },
      {
        'id': 'TRT-309',
        'title': 'İç/Dış Parazit Damlası',
        'category': 'Kür',
        'date': '01.03.2026',
        'vet': 'Dr. Mehmet Yılmaz',
        'dosage': 'Ense Damlası',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tedaviler & Reçeteler (Pet #$petId)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockTreatments.length,
        itemBuilder: (context, index) {
          final item = mockTreatments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item['category'] == 'Aşı'
                    ? Colors.blue.shade100
                    : Colors.purple.shade100,
                child: Icon(
                  item['category'] == 'Aşı'
                      ? Icons.vaccines
                      : Icons.medication_liquid,
                  color: item['category'] == 'Aşı'
                      ? Colors.blue.shade800
                      : Colors.purple.shade800,
                ),
              ),
              title: Text(
                '${item['title']} (${item['category']})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item['dosage']}\n${item['date']} • ${item['vet']}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
