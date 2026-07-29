import 'package:flutter/material.dart';

class OwnerVisitHistoryListScreen extends StatelessWidget {
  const OwnerVisitHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockVisits = [
      {
        'id': 'VST-2001',
        'petName': 'Pamuk (Kedi)',
        'date': '24.07.2026',
        'vetName': 'Dr. Mehmet Yılmaz',
        'reason': 'Genel Kontrol & Karma Aşı',
        'status': 'Tamamlandı'
      },
      {
        'id': 'VST-1942',
        'petName': 'Gölge (Köpek)',
        'date': '10.05.2026',
        'vetName': 'Dr. Ayşe Kaya',
        'reason': 'İştahsızlık & Rutin Muayene',
        'status': 'Tamamlandı'
      },
      {
        'id': 'VST-1810',
        'petName': 'Pamuk (Kedi)',
        'date': '15.02.2026',
        'vetName': 'Dr. Mehmet Yılmaz',
        'reason': 'İç/Dış Parazit Uygulaması',
        'status': 'Tamamlandı'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziyaret & Muayene Geçmişi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockVisits.length,
        itemBuilder: (context, index) {
          final visit = mockVisits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.history_edu, color: Colors.white),
              ),
              title: Text(
                '${visit['petName']} - ${visit['reason']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${visit['date']} • ${visit['vetName']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit['status']!,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
