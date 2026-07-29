import 'package:flutter/material.dart';

class VetVisitHistoryScreen extends StatelessWidget {
  const VetVisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockVisits = [
      {
        'id': 'VST-2001',
        'patient': 'Pamuk (Tekir Kedi)',
        'owner': 'Zeynep Yılmaz',
        'date': 'Bugün, 14:30',
        'diagnosis': 'Rutin Aşılama & Genel Kontrol',
        'status': 'Devam Ediyor',
        'isOngoing': true,
      },
      {
        'id': 'VST-1998',
        'patient': 'Gölge (Golden Retriever)',
        'owner': 'Ahmet Kaya',
        'date': 'Dün, 11:00',
        'diagnosis': 'Kulak Enfeksiyonu & İlaç Tedavisi',
        'status': 'Tamamlandı',
        'isOngoing': false,
      },
      {
        'id': 'VST-1980',
        'patient': 'Maviş (Muhabbet Kuşu)',
        'owner': 'Elif Demir',
        'date': '27.07.2026',
        'diagnosis': 'Tüy Dökümü & Vitamin Desteği',
        'status': 'Tamamlandı',
        'isOngoing': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinik Muayene Geçmişi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockVisits.length,
        itemBuilder: (context, index) {
          final visit = mockVisits[index];
          final isOngoing = visit['isOngoing'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOngoing ? Colors.orange.shade100 : Colors.teal.shade100,
                child: Icon(
                  isOngoing ? Icons.pending_actions : Icons.check_circle_outline,
                  color: isOngoing ? Colors.orange.shade800 : Colors.teal.shade800,
                ),
              ),
              title: Text(
                '${visit['patient']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Sahibi: ${visit['owner']}\n${visit['diagnosis']} • ${visit['date']}',
              ),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOngoing ? Colors.orange.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit['status'] as String,
                  style: TextStyle(
                    color: isOngoing ? Colors.orange.shade900 : Colors.green.shade800,
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
