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
import '../cubit/weight_history_cubit.dart';
import '../cubit/weight_history_state.dart';

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
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFD9531E)),
            tooltip: "AI'ya Sor",
            onPressed: () {
              final petState = context.read<PetCubit>().state;
              if (petState is PetLoaded) {
                try {
                  final pet =
                      petState.pets.firstWhere((p) => p.id == widget.petId);
                  context.push('/chatbot', extra: pet);
                } catch (_) {
                  context.push('/chatbot?petId=${widget.petId}');
                }
              } else {
                context.push('/chatbot?petId=${widget.petId}');
              }
            },
          ),
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
                          const SizedBox(height: 12),
                          // AI'ya Sor Aksiyon Butonu
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.push('/chatbot', extra: pet),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text('${pet.name} İçin AI\'ya Sor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFECE5),
                              foregroundColor: const Color(0xFFD9531E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 20),
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
          const Text('Ek Detaylar',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          _buildInfoRow(
              'Doğum Tarihi',
              pet.birthDate != null
                  ? '${pet.birthDate!.day.toString().padLeft(2, '0')}.${pet.birthDate!.month.toString().padLeft(2, '0')}.${pet.birthDate!.year}'
                  : 'Bilinmiyor'),
          _buildInfoRow(
            'Kilo',
            pet.weight != null ? '${pet.weight} kg' : 'Bilinmiyor',
          ),
          _buildInfoRow(
            'Mikroçip No',
            pet.microchipNo ?? 'Belirtilmemiş',
          ),
          _buildInfoRow(
            'Kısırlaştırma',
            pet.isSpayedOrNeutered == true
                ? 'Evet'
                : (pet.isSpayedOrNeutered == false ? 'Hayır' : 'Bilinmiyor'),
          ),
          _buildInfoRow(
            'Kan Grubu',
            pet.bloodType ?? 'Belirtilmemiş',
          ),
          _buildInfoRow(
            'Renk',
            pet.color ?? 'Belirtilmemiş',
          ),
          _buildInfoRow(
            'Alerjiler',
            pet.allergies ?? 'Yok',
          ),
          _buildInfoRow(
            'Kronik Rahatsızlıklar',
            pet.chronicIllnesses ?? 'Yok',
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kilo Grafiği',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              BlocBuilder<WeightHistoryCubit, WeightHistoryState>(
                builder: (context, state) {
                  if (state is WeightHistoryLoaded &&
                      state.history.isNotEmpty) {
                    return GestureDetector(
                      onTap: () =>
                          _showAllWeightsBottomSheet(context, state.history),
                      child: Text('Tümü',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<WeightHistoryCubit, WeightHistoryState>(
            builder: (context, state) {
              if (state is WeightHistoryLoading) {
                return Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const CircularProgressIndicator(),
                );
              } else if (state is WeightHistoryLoaded) {
                final history = state.history;
                if (history.isEmpty) {
                  return Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'Kilo geçmişi kaydı bulunmuyor.',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  );
                }

                final spots = <FlSpot>[];
                double minYVal = 0;
                double maxYVal = 30;
                double maxXVal = 5;

                final sortedHistory = List<PetWeightEntity>.from(history)
                  ..sort((a, b) => a.date.compareTo(b.date));

                double minW = sortedHistory[0].weight;
                double maxW = sortedHistory[0].weight;
                for (int i = 0; i < sortedHistory.length; i++) {
                  final record = sortedHistory[i];
                  spots.add(FlSpot(i.toDouble(), record.weight));
                  if (record.weight < minW) minW = record.weight;
                  if (record.weight > maxW) maxW = record.weight;
                }
                minYVal = (minW - 2).clamp(0, double.infinity).toDouble();
                maxYVal = maxW + 2;
                maxXVal = (spots.length - 1).toDouble();
                if (maxXVal == 0) maxXVal = 1.0;

                double yRange = maxYVal - minYVal;
                double yInterval = yRange / 4;
                if (yInterval <= 0 || yInterval.isNaN || yInterval.isInfinite) {
                  yInterval = 1.0;
                }

                double xInterval = 1.0;
                if (sortedHistory.length > 5) {
                  xInterval = (sortedHistory.length / 5).ceilToDouble();
                }

                return Container(
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
                        horizontalInterval: yInterval,
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
                            interval: xInterval,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(
                                  color: Color(0xFF737686), fontSize: 10);
                              final index = value.round();
                              if (value == index.toDouble() &&
                                  index >= 0 &&
                                  index < sortedHistory.length) {
                                final date = sortedHistory[index].date;
                                final months = [
                                  'Oca',
                                  'Şub',
                                  'Mar',
                                  'Nis',
                                  'May',
                                  'Haz',
                                  'Tem',
                                  'Ağu',
                                  'Eyl',
                                  'Eki',
                                  'Kas',
                                  'Ara'
                                ];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                      '${months[date.month - 1]} ${date.year}',
                                      style: style),
                                );
                              }
                              return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const SizedBox.shrink());
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) {
                              final formatted = value % 1 == 0
                                  ? value.toInt().toString()
                                  : value.toStringAsFixed(1);
                              return Text('$formatted kg',
                                  style: const TextStyle(
                                      color: Color(0xFF737686), fontSize: 10));
                            },
                            reservedSize: 36,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: maxXVal,
                      minY: minYVal,
                      maxY: maxYVal,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
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
                );
              } else if (state is WeightHistoryError) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    'Kilo geçmişi yüklenemedi: ${state.message}',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),
          const Text('Son Aktivite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showAllWeightsBottomSheet(BuildContext context, List<PetWeightEntity> history) {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
            ),
             child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kilo Geçmişi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF131B2E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final sortedList = List<PetWeightEntity>.from(history)
                      ..sort((a, b) => b.date.compareTo(a.date));
                    final record = sortedList[index];
                    final months = [
                      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
                    ];
                    final dateStr =
                        '${record.date.day.toString().padLeft(2, '0')} ${months[record.date.month - 1]} ${record.date.year}';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF1F5F9),
                        child: Icon(Icons.scale_outlined, color: Color(0xFF004AC6), size: 20),
                      ),
                      title: Text(
                        '${record.weight.toStringAsFixed(record.weight % 1 == 0 ? 0 : 1)} kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF131B2E),
                        ),
                      ),
                      subtitle: Text(
                        dateStr,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  _showUpdateWeightDialog(context);
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Yeni Kilo Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Yeni kilo kaydetme
  void _showUpdateWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Yeni Kilo Kaydı',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Lütfen hayvanın yeni kilosunu girin (kg):',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Örn: 12.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                final text = controller.text.trim().replaceAll(',', '.');
                final newW = double.tryParse(text);
                if (newW == null || newW <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen geçerli bir kilo girin.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                // Pet verisini güncelle
                context.read<PetCubit>().updatePet(
                  id: widget.petId,
                  weight: newW,
                );
                // Grafik verilerini yenile
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    context
                        .read<WeightHistoryCubit>()
                        .fetchWeightHistory(widget.petId);
                  }
                });
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
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
