import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';
import '../../domain/entities/pet_entity.dart';
import '../../../visit/presentation/cubit/visit_cubit.dart';
import '../../../visit/presentation/cubit/visit_state.dart';
import '../../../treatment/presentation/cubit/treatment_cubit.dart';
import '../../../treatment/presentation/cubit/treatment_state.dart';
import '../../../recommendation/presentation/cubit/recommendation_cubit.dart';
import '../../../recommendation/presentation/cubit/recommendation_state.dart';
import '../../../recommendation/domain/entities/recommendation_entity.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
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
                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    size: 20, color: primaryBlue),
                                onPressed: () =>
                                    context.push('/owner/pets/${pet.id}/edit'),
                              ),
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
                      _buildGenelTab(pet),
                      _buildSaglikTab(),
                      _buildNotlarTab(),
                    ],
                  ),
                ),
              );
            } catch (_) {
              return const Center(child: Text('Pet bulunamadı.'));
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // 1. GENEL SEKMESİ
  Widget _buildGenelTab(PetEntity pet) {
    String speciesVal = 'Bilinmiyor';
    String breedVal = pet.breed ?? 'Bilinmiyor';
    if (pet.breed != null && pet.breed!.contains(' / ')) {
      final parts = pet.breed!.split(' / ');
      speciesVal = parts[0];
      breedVal = parts[1];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Genel Bilgiler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('Benzersiz Kod', pet.uniqueCode),
          _buildInfoRow('Türü', speciesVal),
          _buildInfoRow('Cinsi / Irkı', breedVal),
          _buildInfoRow(
              'Yaş', pet.age != null ? '${pet.age} Yaş' : 'Bilinmiyor'),
          _buildInfoRow(
              'Cinsiyet',
              pet.gender == Gender.male
                  ? 'Erkek'
                  : (pet.gender == Gender.female ? 'Dişi' : 'Bilinmiyor')),
          const Divider(height: 24),
          const Text('Ek Detaylar (Statik / Mock)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          _buildInfoRow('Doğum Tarihi (Mock)', '12.04.2022'),
          _buildInfoRow('Kilo (Mock)', '23 kg'),
          _buildInfoRow('Mikroçip No (Mock)', '900215000123456'),
          _buildInfoRow('Kısırlaştırma (Mock)', 'Evet'),
          _buildInfoRow('Kan Grubu (Mock)', 'DEA 1.1 (+)'),
          _buildInfoRow('Renk (Mock)', 'Golden'),
          _buildInfoRow('Alerjiler (Mock)', 'Tavuk proteinine alerjisi var.'),
          _buildInfoRow('Kronik Rahatsızlıklar (Mock)', 'Yok'),
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
    return BlocBuilder<VisitCubit, VisitState>(
      builder: (context, visitState) {
        return BlocBuilder<TreatmentCubit, TreatmentState>(
          builder: (context, treatmentState) {
            final List<Map<String, dynamic>> combinedHistory = [];

            if (visitState is VisitHistoryLoaded) {
              for (var visit in visitState.visits) {
                combinedHistory.add({
                  'date': visit.startedAt,
                  'title':
                      'Muayene: ${visit.chiefComplaint ?? 'Genel Kontrol'}',
                  'subtitle': visit.vetStaffName ?? 'Klinik Hekimi',
                  'icon': Icons.medical_services_outlined,
                });
              }
            }

            if (treatmentState is TreatmentLoaded) {
              for (var treatment in treatmentState.treatments) {
                combinedHistory.add({
                  'date': treatment.createdAt,
                  'title': 'Tedavi: ${treatment.title}',
                  'subtitle':
                      '${treatment.type} ${treatment.description != null ? "• ${treatment.description}" : ""}',
                  'icon': Icons.healing_outlined,
                });
              }
            }

            // Sort descending (newest first)
            combinedHistory.sort((a, b) =>
                (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            final isLoading = visitState is VisitLoading ||
                treatmentState is TreatmentLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sağlık Geçmişi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (combinedHistory.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                                'Herhangi bir sağlık geçmişi bulunmuyor.',
                                style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...combinedHistory.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final DateTime dateVal = item['date'] as DateTime;
                            final dateStr =
                                '${dateVal.day.toString().padLeft(2, '0')}.${dateVal.month.toString().padLeft(2, '0')}.${dateVal.year}';

                            return Column(
                              children: [
                                _buildHealthHistoryItem(
                                  item['icon'] as IconData,
                                  dateStr,
                                  item['title'] as String,
                                  item['subtitle'] as String,
                                ),
                                if (index < combinedHistory.length - 1)
                                  const Divider(height: 1, indent: 56),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
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
                                    color: Colors.grey.shade600,
                                    fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
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
    return BlocBuilder<RecommendationCubit, RecommendationState>(
      builder: (context, state) {
        if (state is RecommendationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RecommendationError) {
          return Center(child: Text(state.message));
        }

        List<RecommendationEntity> recommendations = [];
        if (state is RecommendationLoaded) {
          recommendations = state.recommendations;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hekim Önerileri',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${recommendations.length} Öneri',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendations.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Hayvana ait kaydedilmiş hekim önerisi bulunmuyor.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...recommendations.map((rec) {
                  final DateTime dateVal = rec.createdAt;
                  final dateStr =
                      '${dateVal.day.toString().padLeft(2, '0')}.${dateVal.month.toString().padLeft(2, '0')}.${dateVal.year}';

                  String recTitle = 'Genel Öneri';
                  Color labelColor = primaryBlue;
                  Color labelBgColor = const Color(0xFFDBEAFE);
                  if (rec.type == 'food') {
                    recTitle = 'Beslenme Önerisi';
                    labelColor = Colors.orange.shade800;
                    labelBgColor = const Color(0xFFFFECE5);
                  } else if (rec.type == 'litter') {
                    recTitle = 'Kum & Hijyen Önerisi';
                    labelColor = Colors.blue.shade800;
                    labelBgColor = const Color(0xFFE0F2FE);
                  }

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
                            Text(dateStr,
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: labelBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                recTitle,
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(rec.description,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF131B2E),
                                height: 1.4)),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
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
