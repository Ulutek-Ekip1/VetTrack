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

  Color get primaryBlue => Theme.of(context).colorScheme.primary;
  Color get bgGray => Theme.of(context).colorScheme.surface;

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
    final theme = Theme.of(context);



    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
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

              final hasPhoto =
                  pet.photoUrl != null && pet.photoUrl!.isNotEmpty;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 310,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                          image: hasPhoto
                              ? DecorationImage(
                                  image: NetworkImage(pet.photoUrl!),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                )
                              : null,
                          gradient: !hasPhoto
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primaryContainer,
                                    theme.colorScheme.tertiaryContainer,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'pet-photo-${pet.id}',
                              child: const SizedBox.expand(),
                            ),

                            if (!hasPhoto)
                              Center(
                                child: Icon(
                                  Icons.pets,
                                  size: 96,
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.35),
                                ),
                              ),

                            // Gradyan Maskesi (Metinler için)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.65),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.90),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.35, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Üst Aksiyon Barı (Geri, AI, Düzenle)
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: 16,
                              right: 16,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Geri Butonu
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => context.pop(),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.4),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Sağ Butonlar (AI & Düzenle)
                                  Row(
                                    children: [
                                      // AI'ya Sor
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            context.push('/chatbot',
                                                extra: pet);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD9531E)
                                                  .withValues(alpha: 0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2)),
                                              ],
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.auto_awesome,
                                                    color: Colors.white,
                                                    size: 16),
                                                SizedBox(width: 6),
                                                Text(
                                                  "AI'ya Sor",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Düzenle
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => context.push(
                                              '/owner/pets/${pet.id}/edit'),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.4),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Alt Bilgiler (İsim, Irk, Cinsiyet & Yaş Çipleri)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pet.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 30,
                                      shadows: [
                                        Shadow(
                                            color: Colors.black87,
                                            blurRadius: 8),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (breedText.isNotEmpty)
                                    Text(
                                      breedText,
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      if (pet.gender != Gender.unknown)
                                        _buildHeaderGlassChip(
                                          icon: pet.gender == Gender.male
                                              ? Icons.male_rounded
                                              : Icons.female_rounded,
                                          label: pet.gender == Gender.male
                                              ? 'Erkek'
                                              : 'Dişi',
                                          color: pet.gender == Gender.male
                                              ? const Color(0xFF64B5F6)
                                              : const Color(0xFFF48FB1),
                                        ),
                                      if (pet.age != null)
                                        _buildHeaderGlassChip(
                                          icon: Icons.cake_outlined,
                                          label: '${pet.age} Yaşında',
                                        ),
                                      if (pet.weight != null)
                                        _buildHeaderGlassChip(
                                          icon: Icons.scale_outlined,
                                          label: '${pet.weight} kg',
                                        ),
                                      if (pet.isSpayedOrNeutered == true)
                                        _buildHeaderGlassChip(
                                          icon:
                                              Icons.health_and_safety_outlined,
                                          label: 'Kısırlaştırılmış',
                                          color: Colors.tealAccent,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
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
          Text('Genel Bilgiler',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface)),
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
          Divider(height: 24, color: theme.colorScheme.outlineVariant),
          Text('Ek Detaylar',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant)),
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
              Row(
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 20,
                    color: primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kilo Takip Grafiği',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _showUpdateWeightDialog(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryBlue.withValues(alpha: 0.12),
                      foregroundColor: primaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Kilo Ekle',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  BlocBuilder<WeightHistoryCubit, WeightHistoryState>(
                    builder: (context, state) {
                      if (state is WeightHistoryLoaded &&
                          state.history.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: OutlinedButton(
                            onPressed: () => _showAllWeightsBottomSheet(
                                context, state.history),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: const Text(
                              'Tümü',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<WeightHistoryCubit, WeightHistoryState>(
            builder: (context, state) {
              if (state is WeightHistoryLoading) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  child: const CircularProgressIndicator(),
                );
              } else if (state is WeightHistoryLoaded) {
                return _buildEnhancedWeightSection(
                    context, state.history, theme, primaryBlue);
              } else if (state is WeightHistoryError) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(
                    'Kilo geçmişi yüklenemedi: ${state.message}',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showAllWeightsBottomSheet(
      BuildContext context, List<PetWeightEntity> history) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  Text(
                    'Kilo Geçmişi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
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
                      'Ocak',
                      'Şubat',
                      'Mart',
                      'Nisan',
                      'Mayıs',
                      'Haziran',
                      'Temmuz',
                      'Ağustos',
                      'Eylül',
                      'Ekim',
                      'Kasım',
                      'Aralık'
                    ];
                    final dateStr =
                        '${record.date.day.toString().padLeft(2, '0')} ${months[record.date.month - 1]} ${record.date.year}';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.scale_outlined,
                            color: theme.colorScheme.primary, size: 20),
                      ),
                      title: Text(
                        '${record.weight.toStringAsFixed(record.weight % 1 == 0 ? 0 : 1)} kg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        dateStr,
                        style:
                            TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
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
                icon: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 18),
                label: const Text('Yeni Kilo Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
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
    final theme = Theme.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Yeni Kilo Kaydı',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lütfen hayvanın yeni kilosunu girin (kg):',
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Örn: 12.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('İptal', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () async {
                final text = controller.text.trim().replaceAll(',', '.');
                final newW = double.tryParse(text);
                if (newW == null || newW <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Lütfen geçerli bir kilo girin.'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                  return;
                }
                final petCubit = context.read<PetCubit>();
                final weightHistoryCubit = context.read<WeightHistoryCubit>();

                Navigator.pop(dialogContext);

                // Pet verisini güncelle ve tamamlandığında kilo geçmişini garantili olarak çek
                await petCubit.updatePet(
                  id: widget.petId,
                  weight: newW,
                );
                weightHistoryCubit.fetchWeightHistory(widget.petId);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface)),
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

            final theme = Theme.of(context);
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
                      GestureDetector(
                        onTap: () =>
                            context.push('/owner/pets/${widget.petId}/visits'),
                        child: Text('Tümü >',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (combinedHistory.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                                'Herhangi bir sağlık geçmişi bulunmuyor.',
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
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
                                  Divider(height: 1, indent: 56, color: theme.colorScheme.outlineVariant),
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
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'Şu anda kaydedilmiş kronik rahatsızlığı bulunmuyor.',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
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
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.colorScheme.onSurface)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          Text(subtitle,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // 4. NOTLAR SEKMESİ
  Widget _buildNotlarTab() {
    final theme = Theme.of(context);
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
                  Text('Hekim Önerileri',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                  Text('${recommendations.length} Öneri',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendations.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Hayvana ait kaydedilmiş hekim önerisi bulunmuyor.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                  Color labelBgColor = theme.colorScheme.primaryContainer;
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
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateStr,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
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
                            style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                                height: 1.4)),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWeightSection(
    BuildContext context,
    List<PetWeightEntity> history,
    ThemeData theme,
    Color primaryBlue,
  ) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.scale_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Henüz kilo kaydı bulunmuyor.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _showUpdateWeightDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('İlk Kiloyu Ekle'),
            ),
          ],
        ),
      );
    }

    final sortedHistory = List<PetWeightEntity>.from(history)
      ..sort((a, b) => a.date.compareTo(b.date));

    final latestRecord = sortedHistory.last;
    final latestWeight = latestRecord.weight;

    double? diff;
    if (sortedHistory.length > 1) {
      final prevWeight = sortedHistory[sortedHistory.length - 2].weight;
      diff = latestWeight - prevWeight;
    }

    final spots = <FlSpot>[];
    double minW = sortedHistory[0].weight;
    double maxW = sortedHistory[0].weight;
    for (int i = 0; i < sortedHistory.length; i++) {
      final record = sortedHistory[i];
      if (record.weight < minW) minW = record.weight;
      if (record.weight > maxW) maxW = record.weight;
    }

    if (sortedHistory.length == 1) {
      // 1 adet kilo kaydı olduğunda grafiği yatay çizgi ve belirgin orta noktayla render et
      spots.add(FlSpot(0.0, latestWeight));
      spots.add(FlSpot(1.0, latestWeight));
    } else {
      for (int i = 0; i < sortedHistory.length; i++) {
        spots.add(FlSpot(i.toDouble(), sortedHistory[i].weight));
      }
    }

    double range = maxW - minW;
    if (range == 0) {
      range = 4.0; // Tek kayıt veya eşit kilolarda varsayılan dikey aralık
    }

    double rawMinY = (minW - (range * 0.25)).clamp(0.0, double.infinity);
    double rawMaxY = maxW + (range * 0.25);
    if (rawMaxY - rawMinY < 4.0) {
      rawMaxY = rawMinY + 4.0;
    }

    double rawInterval = (rawMaxY - rawMinY) / 4;
    double yInterval;
    if (rawInterval <= 0.5) {
      yInterval = 0.5;
    } else if (rawInterval <= 1.0) {
      yInterval = 1.0;
    } else if (rawInterval <= 2.5) {
      yInterval = 2.5;
    } else if (rawInterval <= 5.0) {
      yInterval = 5.0;
    } else {
      yInterval = rawInterval.ceilToDouble();
    }

    double minYVal = (rawMinY / yInterval).floorToDouble() * yInterval;
    double maxYVal = (rawMaxY / yInterval).ceilToDouble() * yInterval;

    if (minYVal < 0) minYVal = 0;
    if (maxYVal <= minYVal) maxYVal = minYVal + (yInterval * 4);

    double maxXVal = (sortedHistory.length == 1)
        ? 1.0
        : (sortedHistory.length - 1).toDouble();

    double xInterval = 1.0;
    if (sortedHistory.length > 5) {
      xInterval = (sortedHistory.length / 5).ceilToDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.scale_rounded,
                          size: 14,
                          color: primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Son Kilo',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${latestWeight.toStringAsFixed(1)} kg',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          diff == null || diff == 0
                              ? Icons.trending_flat_rounded
                              : (diff > 0
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded),
                          size: 14,
                          color: diff == null || diff == 0
                              ? theme.colorScheme.onSurfaceVariant
                              : (diff > 0
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Son Değişim',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diff == null || diff == 0
                          ? 'Değişim Yok'
                          : '${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)} kg',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: diff == null || diff == 0
                            ? theme.colorScheme.onSurface
                            : (diff > 0
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444)),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 14,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kayıtlar',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${history.length} Ölçüm',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(10, 20, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) =>
                      theme.colorScheme.surfaceContainerHigh,
                  tooltipRoundedRadius: 12,
                  tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  tooltipBorder: BorderSide(
                    color: primaryBlue.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      int index = spot.x.round();
                      if (sortedHistory.length == 1) {
                        index = 0;
                      }
                      if (index >= 0 && index < sortedHistory.length) {
                        final record = sortedHistory[index];
                        final dateStr =
                            '${record.date.day}/${record.date.month}/${record.date.year}';
                        return LineTooltipItem(
                          '$dateStr\n${record.weight} kg',
                          TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: xInterval,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: Color(0xFF737686),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      );
                      final index = value.round();
                      if (sortedHistory.length == 1) {
                        if (index == 0) {
                          final date = sortedHistory[0].date;
                          final months = [
                            'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                            'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
                          ];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${date.day} ${months[date.month - 1]} ${date.year}',
                              style: style,
                            ),
                          );
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: const SizedBox.shrink(),
                        );
                      }

                      if (value == index.toDouble() &&
                          index >= 0 &&
                          index < sortedHistory.length) {
                        final date = sortedHistory[index].date;
                        final months = [
                          'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                          'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
                        ];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${months[date.month - 1]} ${date.year}',
                            style: style,
                          ),
                        );
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: yInterval,
                    reservedSize: 46,
                    getTitlesWidget: (value, meta) {
                      if (value < minYVal - 0.01 || value > maxYVal + 0.01) {
                        return const SizedBox.shrink();
                      }
                      final formatted = value % 1 == 0
                          ? value.toInt().toString()
                          : value.toStringAsFixed(1);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 6,
                        child: Text(
                          '$formatted kg',
                          style: const TextStyle(
                            color: Color(0xFF737686),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
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
                  isCurved: sortedHistory.length > 1,
                  curveSmoothness: 0.35,
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  barWidth: 3.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4.5,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: primaryBlue,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        primaryBlue.withValues(alpha: 0.28),
                        primaryBlue.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGlassChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final textColor = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
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
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceDim, // Sticky Header arkaplan rengi
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
