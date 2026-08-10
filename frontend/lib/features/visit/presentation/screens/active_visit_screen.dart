import 'package:flutter/material.dart';

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

  final List<String> _treatments = [];
  final List<String> _recommendations = [];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  void _addQuickItem(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '$title detayını yazın...',
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
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAdd(text);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _onCloseVisit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ziyaret #${widget.visitId} tamamlandı ve kaydedildi.'),
        backgroundColor: Colors.teal,
      ),
    );
    Navigator.of(context).pop();
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
                            style:
                                TextStyle(color: Colors.black87, fontSize: 13)),
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

            // Hızlı Tedavi ve Öneri Ekleme Alanı
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addQuickItem('Tedavi/Uygulama',
                        (val) => setState(() => _treatments.add(val))),
                    icon: const Icon(Icons.add_moderator),
                    label: const Text('Tedavi/Aşı Ekle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addQuickItem('Ev İçin Öneri',
                        (val) => setState(() => _recommendations.add(val))),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Öneri Ekle'),
                  ),
                ),
              ],
            ),

            //Eklenen Tedaviler ve Öneriler Listesi
            if (_treatments.isNotEmpty || _recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._treatments.map((t) => Chip(
                        avatar: const Icon(Icons.check, size: 16),
                        label: Text('Tedavi: $t'),
                        onDeleted: () => setState(() => _treatments.remove(t)),
                      )),
                  ..._recommendations.map((r) => Chip(
                        avatar: const Icon(Icons.info_outline, size: 16),
                        label: Text('Öneri: $r'),
                        backgroundColor: Colors.orange.shade50,
                        onDeleted: () =>
                            setState(() => _recommendations.remove(r)),
                      )),
                ],
              ),
            ],
            const SizedBox(height: 20),

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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
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
