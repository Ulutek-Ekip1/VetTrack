import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  // Tasarım ve deneme için dinamik mock liste (sonrasında API/Cubit ile bağlanacak)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Tedavi Kaydı Eklendi',
      'message': 'Hekiminiz Pamuk için yeni bir ilaç tedavi kaydı girdi. Detayları inceleyebilirsiniz.',
      'time': '10 dk önce',
      'isRead': false,
      'type': 'healing',
      'group': 'Bugün',
    },
    {
      'id': '2',
      'title': 'Ziyaret Başlatıldı',
      'message': 'Pamuk için Patili Veteriner Kliniği\'nde yeni bir muayene ziyareti başlatıldı.',
      'time': '2 saat önce',
      'isRead': false,
      'type': 'medical_services',
      'group': 'Bugün',
    },
    {
      'id': '3',
      'title': 'Ziyaret Tamamlandı',
      'message': 'Dr. Mehmet Yılmaz, Pamuk için gerçekleştirdiği muayene ziyaretini tamamladı.',
      'time': 'Dün, 14:30',
      'isRead': true,
      'type': 'check_circle',
      'group': 'Daha Eski',
    },
    {
      'id': '4',
      'title': 'Sistem Güncellemesi',
      'message': 'VetTrack uygulamasına hoş geldiniz! Evcil hayvanınızın profilini doldurarak hekiminizle paylaşabilirsiniz.',
      'time': '3 gün önce',
      'isRead': true,
      'type': 'system',
      'group': 'Daha Eski',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm bildirimler okundu olarak işaretlendi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleReadStatus(int index) {
    setState(() {
      _notifications[index]['isRead'] = !_notifications[index]['isRead'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);

    // Gruplama işlemi
    final groups = <String, List<Map<String, dynamic>>>{};
    for (var item in _notifications) {
      groups.putIfAbsent(item['group'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined, color: Color(0xFF434655)),
            tooltip: 'Tümünü Okundu Yap',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildiriminiz yok',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              children: groups.entries.map((entry) {
                final groupName = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 12.0),
                      child: Text(
                        groupName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF131B2E),
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final globalIndex = _notifications.indexOf(item);
                      final isRead = item['isRead'] as bool;
                      final type = item['type'] as String;

                      IconData iconData;
                      Color iconBgColor;
                      Color iconColor;

                      switch (type) {
                        case 'healing':
                          iconData = Icons.healing_outlined;
                          iconBgColor = const Color(0xFFFFF1F2);
                          iconColor = const Color(0xFFF43F5E);
                          break;
                        case 'medical_services':
                          iconData = Icons.medical_services_outlined;
                          iconBgColor = const Color(0xFFEFF6FF);
                          iconColor = primaryBlue;
                          break;
                        case 'check_circle':
                          iconData = Icons.check_circle_outline_rounded;
                          iconBgColor = const Color(0xFFECFDF5);
                          iconColor = const Color(0xFF059669);
                          break;
                        default:
                          iconData = Icons.notifications_none_outlined;
                          iconBgColor = const Color(0xFFF1F5F9);
                          iconColor = Colors.grey.shade600;
                      }

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                        color: isRead ? theme.colorScheme.surface : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          side: BorderSide(
                            color: isRead ? Colors.grey.shade200 : primaryBlue.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _toggleReadStatus(globalIndex),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bildirim Tipi İkonu
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData, color: iconColor, size: 22),
                                ),
                                const SizedBox(width: 14),

                                // Bildirim Detayları
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                                                color: isRead ? const Color(0xFF334155) : const Color(0xFF131B2E),
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['message'] as String,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isRead ? Colors.grey.shade600 : const Color(0xFF1E293B),
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['time'] as String,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
