import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';

class PetDetailScreen2 extends StatefulWidget {
  final String petId;
  const PetDetailScreen2({super.key, required this.petId});

  @override
  State<PetDetailScreen2> createState() => _PetDetailScreen2State();
}

class _PetDetailScreen2State extends State<PetDetailScreen2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryBlue = const Color(0xFF004AC6);
  final Color bgGray = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF131B2E), size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF131B2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<PetCubit, PetState>(
        builder: (context, state) {
          if (state is PetLoaded) {
            try {
              final pet = state.pets.firstWhere((p) => p.id == widget.petId);

              String breedText = pet.breed ?? '';
              if (pet.breed != null && pet.breed!.contains(' / ')) {
                final parts = pet.breed!.split(' / ');
                breedText = parts.length > 1 ? parts[1] : parts[0];
              }

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Fotoğraf
                          Hero(
                            tag: 'pet-photo-${pet.id}',
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFDBEAFE),
                              backgroundImage: pet.photoUrl != null &&
                                      pet.photoUrl!.isNotEmpty
                                  ? NetworkImage(pet.photoUrl!)
                                  : null,
                              child:
                                  pet.photoUrl == null || pet.photoUrl!.isEmpty
                                      ? Icon(Icons.pets,
                                          size: 40, color: primaryBlue)
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // İsim ve Düzenle İkonu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF131B2E),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.edit_outlined,
                                  size: 20, color: primaryBlue),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Künye Bilgileri
                          Text(
                            '$breedText  •  ${pet.age ?? '?'} Yaş  •  ${pet.gender.name == 'male' ? 'Erkek' : 'Dişi'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF737686),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: primaryBlue,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF737686),
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          labelPadding: EdgeInsets.zero,
                          tabs: const [
                            Tab(text: 'Genel'),
                            Tab(text: 'Sağlık'),
                            Tab(text: 'Notlar'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: Container(
                  color: bgGray,
                  margin: const EdgeInsets.only(top: 16),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGenelTab(),
                      _buildSaglikTab(),
                      _buildNotlarTab(),
                    ],
                  ),
                ),
              );
            } catch (_) {}
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // 1. GENEL SEKMESİ
  Widget _buildGenelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Genel Bilgiler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('Doğum Tarihi', '12.04.2022'),
          _buildInfoRow('Kilo', '23 kg'),
          _buildInfoRow('Mikroçip No', '900215000123456'),
          _buildInfoRow('Kısırlaştırma', 'Evet'),
          _buildInfoRow('Kan Grubu', 'DEA 1.1 (+)'),
          _buildInfoRow('Renk', 'Golden'),
          _buildInfoRow('Alerjiler', 'Tavuk proteinine alerjisi var.'),
          _buildInfoRow('Kronik Rahatsızlıklar', 'Yok'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kilo Grafiği',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Tümü',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style =
                            TextStyle(color: Color(0xFF737686), fontSize: 10);
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Ara 2024', style: style);
                            break;
                          case 1:
                            text = const Text('Oca 2025', style: style);
                            break;
                          case 2:
                            text = const Text('Şub 2025', style: style);
                            break;
                          case 3:
                            text = const Text('Mar 2025', style: style);
                            break;
                          case 4:
                            text = const Text('Nis 2025', style: style);
                            break;
                          case 5:
                            text = const Text('May 2025', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                            axisSide: meta.axisSide, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()} kg',
                            style: const TextStyle(
                                color: Color(0xFF737686), fontSize: 10));
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 10,
                maxY: 25,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 21),
                      FlSpot(1, 22),
                      FlSpot(2, 21.5),
                      FlSpot(3, 22.5),
                      FlSpot(4, 21.8),
                      FlSpot(5, 23),
                    ],
                    isCurved: true,
                    color: primaryBlue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryBlue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Son Aktivite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('15.05.2026 - Genel Muayene',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Patili Veteriner Kliniği',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(color: Color(0xFF737686), fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF131B2E))),
          ),
        ],
      ),
    );
  }

  // 2. SAĞLIK SEKMESİ
  Widget _buildSaglikTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sağlık Geçmişi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Tümü >',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildHealthHistoryItem(Icons.medical_services_outlined,
                    '15.05.2026', 'Genel Muayene', 'Patili Veteriner Kliniği'),
                const Divider(height: 1, indent: 56),
                _buildHealthHistoryItem(Icons.thermostat_outlined, '10.05.2026',
                    'Ateş şikayeti ile muayene', 'Patili Veteriner Kliniği'),
                const Divider(height: 1, indent: 56),
                _buildHealthHistoryItem(Icons.healing_outlined, '15.02.2026',
                    'Dış parazit tedavisi', 'Patili Veteriner Kliniği'),
                const Divider(height: 1, indent: 56),
                _buildHealthHistoryItem(Icons.medication_outlined, '20.01.2026',
                    'Kulak enfeksiyonu tedavisi', 'Patili Veteriner Kliniği'),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Sağlık Kaydı Ekle',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side:
                          BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Kronik Rahatsızlıklar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Şu anda kaydedilmiş kronik rahatsızlığı bulunmuyor.',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHealthHistoryItem(
      IconData icon, String date, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // 4. NOTLAR SEKMESİ
  Widget _buildNotlarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text('Tümü',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                  const SizedBox(width: 4),
                  const Icon(Icons.filter_alt_outlined, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteCard(
              '15.05.2026',
              'Genel durumu iyi, İştahı normal.\nKilo: 23 kg.',
              'Dr. Ahmet Yılmaz',
              true),
          _buildNoteCard(
              '20.04.2026',
              'Bugün tüy dökümü biraz fazlaydı.\nŞampuan değiştirdim.',
              null,
              false),
          _buildNoteCard(
              '10.03.2026',
              'Kulak temizliği yapıldı.\nAntibiyotik damla reçete edildi.',
              'Dr. Ayşe Demir',
              true),
          _buildNoteCard(
              '05.02.2026',
              'İlaçlarını düzenli kullandı.\nHerhangi bir yan etkisi olmadı.',
              null,
              false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
      String date, String content, String? doctor, bool isVetNote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVetNote
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isVetNote ? 'Veteriner Notu' : 'Sahip Notu',
                  style: TextStyle(
                    color: isVetNote ? const Color(0xFFD97706) : primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF131B2E), height: 1.4)),
          if (doctor != null) ...[
            const SizedBox(height: 12),
            Text(doctor,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ]
        ],
      ),
    );
  }
}

// TabBar'ın yapışkan kalabilmesi için gerekli SliverDelegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Sticky Header arkaplan rengi
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
