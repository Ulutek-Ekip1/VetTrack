import 'package:flutter/material.dart';

class VetVisitHistoryScreen extends StatefulWidget {
  const VetVisitHistoryScreen({super.key});

  @override
  State<VetVisitHistoryScreen> createState() => _VetVisitHistoryScreenState();
}

class _VetVisitHistoryScreenState extends State<VetVisitHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';

  //Örnek Muayene Verileri
  final List<Map<String, dynamic>> mockVisits = [
    {
      'id': 'VST-2001',
      'patient': 'Pamuk',
      'species': 'Kedi (Tekir)',
      'owner': 'Zeynep Yılmaz',
      'date': 'Bugün, 14:30',
      'diagnosis': 'Rutin Aşılama & Genel Kontrol',
      'status': 'Devam Ediyor',
      'isOngoing': true,
      'treatments': ['Karma Aşı (Doz 2)', 'Genel Fiziksel Muayene'],
      'recommendations': [
        'Bol su içmesi sağlansın',
        'Aşı sonrası hafif halsizlik normaldir'
      ],
      'prescription': 'Gerek görülmedi',
      'doctorNotes': 'Hasta gayet sağlıklı. Kilo: 3.8 kg, Ateş: 38.2°C',
    },
    {
      'id': 'VST-1998',
      'patient': 'Gölge',
      'species': 'Köpek (Golden Retriever)',
      'owner': 'Ahmet Kaya',
      'date': '09.08.2026 - 11:00',
      'diagnosis': 'Kulak Enfeksiyonu & İlaç Tedavisi',
      'status': 'Tamamlandı',
      'isOngoing': false,
      'treatments': ['Kulak Temizliği', 'Topikal Antibiyotik'],
      'recommendations': [
        'Kulak kanalına su kaçırılmamalı',
        '7 gün sonra kontrol'
      ],
      'prescription': 'Otic Drops 2x1 (7 Gün), PainRelief Tablet 1x1',
      'doctorNotes':
          'Sol kulakta belirgin akıntı ve kızarıklık mevcuttu. Dış kulak yolu temizlendi.',
    },
    {
      'id': 'VST-1980',
      'patient': 'Maviş',
      'species': 'Kuş (Muhabbet Kuşu)',
      'owner': 'Elif Demir',
      'date': '27.07.2026 - 16:15',
      'diagnosis': 'Tüy Dökümü & Vitamin Desteği',
      'status': 'Tamamlandı',
      'isOngoing': false,
      'treatments': ['Vitamin B Kompleks Enjeksiyon', 'Deri Bakım Spreyi'],
      'recommendations': [
        'Tüy dökümü mevsimseldir, endişelenmeyin',
        'Daha parlak tüyler için özel mama'
      ],
      'prescription': 'Suprävit 1ml (3 Günlük Kür)',
      'doctorNotes':
          'Kuşun genel durumu iyi. Stres kaynaklı tüy dökümü yaşanmış olabilir. Vitamin takviyesi yapıldı.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //Arama ve Filtreleme Mantığı
  List<Map<String, dynamic>> get _filteredVisits {
    return mockVisits.where((visit) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch =
          visit['patient'].toString().toLowerCase().contains(query) ||
              visit['owner'].toString().toLowerCase().contains(query) ||
              visit['id'].toString().toLowerCase().contains(query) ||
              visit['diagnosis'].toString().toLowerCase().contains(query);

      if (_selectedFilter == 'Devam Edenler') {
        return matchesSearch && visit['isOngoing'] == true;
      } else if (_selectedFilter == 'Tamamlananlar') {
        return matchesSearch && visit['isOngoing'] == false;
      }
      return matchesSearch;
    }).toList();
  }

  //Muayene Detay
  void _showVisitDetailsDialog(
      BuildContext context, Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(24),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Muayene Detayı (${visit['id']})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: 650, // Web ekranında okunabilirlik için sabit genişlik
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hasta Künyesi Özeti
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.pets, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${visit['patient']} (${visit['species']})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'Hasta Sahibi: ${visit['owner']} | Tarih: ${visit['date']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                //Teşhis
                _buildDetailSection('Teşhis / Klinik Bulgular',
                    visit['diagnosis'], Icons.healing),
                const SizedBox(height: 16),

                //Uygulanan Tedaviler
                const Text('Uygulanan Tedaviler & Aşılar',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (visit['treatments'] as List<String>)
                      .map((t) => Chip(
                            avatar: const Icon(Icons.check_circle,
                                size: 16, color: Colors.teal),
                            label: Text(t),
                            backgroundColor: Colors.teal.shade50,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Reçete
                _buildDetailSection('Reçete & İlaçlar', visit['prescription'],
                    Icons.medication),
                const SizedBox(height: 16),

                // Ev İçin Öneriler
                const Text('Hasta Sahibine Öneriler',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (visit['recommendations'] as List<String>)
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right,
                                    color: Colors.teal),
                                Expanded(child: Text(r)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Klinik Notları
                _buildDetailSection('Klinik Notları (Dahili)',
                    visit['doctorNotes'], Icons.note_alt_outlined),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            label: const Text('Kapat'),
          )
        ],
      ),
    );
  }

  //Detay bölümü için yardımcı widget
  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 6),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              Text(content, style: const TextStyle(fontSize: 13, height: 1.3)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinik Muayene Geçmişi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 1200), // Web paneli genişlik sınırı
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Arama ve Filtreleme Barı
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText:
                                  'Hasta adı, sahibi veya teşhis ile ara...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _selectedFilter,
                          items: ['Tümü', 'Devam Edenler', 'Tamamlananlar']
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFilter = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Muayene Geçmişi Listesi
                Expanded(
                  child: _filteredVisits.isEmpty
                      ? const Center(
                          child: Text(
                            'Arama kriterlerine uygun muayene kaydı bulunamadı.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredVisits.length,
                          itemBuilder: (context, index) {
                            final visit = _filteredVisits[index];
                            final isOngoing = visit['isOngoing'] as bool;

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isOngoing
                                      ? Colors.orange.shade100
                                      : Colors.teal.shade100,
                                  child: Icon(
                                    isOngoing
                                        ? Icons.pending_actions
                                        : Icons.check_circle_outline,
                                    color: isOngoing
                                        ? Colors.orange.shade800
                                        : Colors.teal.shade800,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      '${visit['patient']} (${visit['species']})',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        visit['id'] as String,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    'Hasta Sahibi: ${visit['owner']}\nTeşhis: ${visit['diagnosis']} • Tarih: ${visit['date']}',
                                    style: const TextStyle(height: 1.3),
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isOngoing
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        visit['status'] as String,
                                        style: TextStyle(
                                          color: isOngoing
                                              ? Colors.orange.shade900
                                              : Colors.green.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () => _showVisitDetailsDialog(
                                          context, visit),
                                      icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 18),
                                      label: const Text('Detay'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

