import 'package:flutter/material.dart';
import 'dart:async';

//Tedavi/öneri modülü (15 dk kontrolü için)
class VisitItem {
  final String id;
  final String text;
  final String type;
  final DateTime createdAt;

  VisitItem({
    required this.id,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  //15 dk silme süresini kontrol
  bool get isDeletable {
    final difference = DateTime.now().difference(createdAt);
    return difference.inMinutes < 15;
  }

  //Kalan süreyi dakika/saniye olarak döndürür
  int get remainingMinutes {
    final diff = DateTime.now().difference(createdAt);
    final remaining = 15 - diff.inMinutes;
    return remaining > 0 ? remaining : 0;
  }
}

class ActiveVisitScreen extends StatefulWidget {
  final String visitId;

  const ActiveVisitScreen({
    super.key,
    required this.visitId,
  });

  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _prescriptionController = TextEditingController();

  final List<VisitItem> _visitItems = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //Silme sürelerinin anlık güncellenmesi için her dakika arayüzü günceller
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _diagnosisController.dispose();
    _notesController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  //Hızlı Tedavi/Öneri Ekleme
  void _addQuickItem(String title, String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '$title detayını yazınız...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _visitItems.add(
                    VisitItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: controller.text.trim(),
                      type: type,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // Öğe Silme Mantığı (15 Dakika Kontrollü)
  void _removeItem(VisitItem item) {
    if (!item.isDeletable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Eklenme üzerinden 15 dakika geçtiği için bu kayıt silinemez!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _visitItems.removeWhere((element) => element.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt silindi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  //Muayene Kapatma Onay İşlemi
  void _onCloseVisit() {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen muayeneyi kapatmadan önce bir teşhis giriniz.'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muayeneyi Tamamla'),
        content: const Text(
          'Muayene kapatılacak ve hasta sahibinin mobil uygulamasına bildirim/özet olarak yansıtılacaktır. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat

              // backend kaydetme mantığı buraya gelecek

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Ziyaret #${widget.visitId} başarıyla kapatıldı ve kaydedildi.'),
                  backgroundColor: Colors.teal,
                ),
              );
              Navigator.of(context).pop(); // Ekrandan çık
            },
            child: const Text('Tamamla ve Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    return Scaffold(
      appBar: AppBar(
        title: Text('Aktif Muayene (#${widget.visitId})'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.fiber_manual_record,
                    color: Colors.greenAccent, size: 12),
                label: const Text('Muayene Devam Ediyor',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.teal.shade800,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildExaminationForm()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildPatientHistoryTimeline()),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildExaminationForm(),
                        const SizedBox(height: 24),
                        _buildPatientHistoryTimeline(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Sol Taraf : Aktif Muayene ve Form Alanları
  Widget _buildExaminationForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Hasta Künyesi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.pets, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pamuk (Kedi - Tekir, 3 Yaş)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Sahibi: Zeynep Y. | İletişi: +90 555 *** ** 00',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Teşhis ve Bulgular
              const Text('Teşhis & Klinik Bulgular',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Akut Gastrit, Hafif Dehidrasyon',
                  prefixIcon: Icon(Icons.healing),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Hızlı Tedavi ve Öneri Ekleme Butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addQuickItem('Tedavi/Aşı', 'tedavi'),
                      icon: const Icon(Icons.add_moderator),
                      label: const Text('Tedavi/Aşı Ekle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addQuickItem('Ev İçin Öneri', 'oneri'),
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Öneri Ekle'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dynamic Tedavi & Öneri Çipleri (15 Dk Kısıtlamalı Silme)
              if (_visitItems.isNotEmpty) ...[
                const Text(
                  'Eklenecek İşlemler (İlk 15 dk içinde silinebilir):',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _visitItems.map((item) {
                    final canDelete = item.isDeletable;
                    return Chip(
                      avatar: Icon(
                        item.type == 'tedavi'
                            ? Icons.check_circle
                            : Icons.lightbulb,
                        size: 16,
                        color:
                            item.type == 'tedavi' ? Colors.teal : Colors.orange,
                      ),
                      label: Text(
                        '${item.text} ${canDelete ? "(${item.remainingMinutes}dk)" : "(Süre Doldu)"}',
                        style: TextStyle(
                          color:
                              canDelete ? Colors.black : Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: item.type == 'tedavi'
                          ? Colors.teal.shade50
                          : Colors.orange.shade50,
                      onDeleted: () => _removeItem(item),
                      deleteIcon: Icon(
                        Icons.cancel,
                        size: 18,
                        color: canDelete ? Colors.redAccent : Colors.grey,
                      ),
                      deleteButtonTooltipMessage: canDelete
                          ? 'Sil'
                          : '15 dakika dolduğu için silinemez',
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              //Reçete ve İlaç Notları
              const Text('Reçete & İlaçlar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prescriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'İlaç adı, dozaj ve kullanım sıklığını giriniz.',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Klinik Notları
              const Text('Hekim Notları',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Sadece klinikte görünecek dahili notları giriniz.',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),

              // Ziyaret Kapat Butonu
              ElevatedButton.icon(
                onPressed: _onCloseVisit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Muayeneyi Tamamla ve Kaydet',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sağ Taraf: Geçmiş Medikal Zaman Çizgisi (Timeline)
  Widget _buildPatientHistoryTimeline() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.teal),
                SizedBox(width: 8),
                Text('Tıbbi Geçmiş & Zaman Çizgisi',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildTimelineTile(
                    date: '12 Mart 2026',
                    title: 'Karma Aşı (Doz 2)',
                    subtitle:
                        'Dr. Ahmet K. - Rutin aşı uygulaması yapıldı. Yan etki gözlenmedi.',
                    icon: Icons.vaccines,
                    iconColor: Colors.blue,
                  ),
                  _buildTimelineTile(
                    date: '05 Ocak 2026',
                    title: 'Genel Kontrol & Parazit',
                    subtitle: 'İç-dış parazit damlası uygulandı. Kilo: 4.2 kg.',
                    icon: Icons.sanitizer,
                    iconColor: Colors.orange,
                  ),
                  _buildTimelineTile(
                    date: '18 Kasım 2025',
                    title: 'Kulak Enfeksiyonu Tedavisi',
                    subtitle:
                        'Sol kulakta kızarıklık. Damla reçete edildi (7 gün).',
                    icon: Icons.medical_services,
                    iconColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required String date,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: iconColor.withValues(alpha: 0.15),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
