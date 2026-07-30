import 'package:flutter/material.dart';

class PetRecommendationScreen extends StatelessWidget {
  final String petId;

  const PetRecommendationScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    final mockRecommendations = [
      {
        'title': 'Beslenme Önerisi',
        'category': 'Beslenme',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'description':
            'Yaş ve kilo analizine göre günlük protein oranı %30 olan somonlu kuru mama kullanımı önerilir.',
      },
      {
        'title': 'Yaklaşan Aşı Hatırlatması',
        'category': 'Sağlık',
        'icon': Icons.vaccines,
        'color': Colors.blue,
        'description':
            'Yıllık Karma Aşı zamanına 14 gün kaldı. Lütfen veteriner hekiminizden randevu alın.',
      },
      {
        'title': 'Egzersiz ve Aktivite',
        'category': 'Aktivite',
        'icon': Icons.directions_run,
        'color': Colors.green,
        'description':
            'Mevsimsel geçişlerde günlük 30 dakika tüy taraması ve aktif oyun tavsiye edilmektedir.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Önerileri (Pet #$petId)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockRecommendations.length,
        itemBuilder: (context, index) {
          final item = mockRecommendations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item['icon'] as IconData, color: item['color'] as Color),
                      const SizedBox(width: 8),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] as String,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
