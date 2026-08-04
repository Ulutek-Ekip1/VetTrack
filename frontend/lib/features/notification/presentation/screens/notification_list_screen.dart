import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      {
        'title': 'Aşı Hatırlatması',
        'message': 'Pamuk isimli kedinizin Kuduz Aşısı zamanı yaklaşıyor.',
        'time': '10 dk önce',
        'isRead': false,
        'type': Icons.vaccines,
      },
      {
        'title': 'Ziyaret Tamamlandı',
        'message': 'Dr. Mehmet Yılmaz muayene notlarını güncelledi.',
        'time': '2 saat önce',
        'isRead': true,
        'type': Icons.check_circle_outline,
      },
      {
        'title': 'Sistem Bildirimi',
        'message': 'VetTrack uygulamasına hoş geldiniz! Profilinizi güncelleyin.',
        'time': '1 gün önce',
        'isRead': true,
        'type': Icons.notifications_active,
      },
    ];

    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final item = mockNotifications[index];
          final isRead = item['isRead'] as bool;

          return Card(
            color: isRead ? Colors.white : const Color(0xFFDBEAFE),
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryBlue,
                child: Icon(item['type'] as IconData, color: Colors.white),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['message'] as String),
                  const SizedBox(height: 4),
                  Text(
                    item['time'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
