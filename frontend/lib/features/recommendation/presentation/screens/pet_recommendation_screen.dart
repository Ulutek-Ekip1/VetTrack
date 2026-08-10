import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:vettrack_frontend/features/recommendation/presentation/cubit/recommendation_cubit.dart';
import 'package:vettrack_frontend/features/recommendation/presentation/cubit/recommendation_state.dart';
import '../../../../core/constants/app_dimensions.dart';

class PetRecommendationScreen extends StatefulWidget {
  final String petId;

  const PetRecommendationScreen({
    super.key,
    required this.petId,
  });

  @override
  State<PetRecommendationScreen> createState() =>
      _PetRecommendationScreenState();
}

class _PetRecommendationScreenState extends State<PetRecommendationScreen> {
  String _selectedCategory = 'Tümü';

  Map<String, dynamic> _mapRecommendation(RecommendationEntity entity) {
    switch (entity.type) {
      case 'food':
        return {
          'title': 'Beslenme Önerisi',
          'category': 'Beslenme',
          'icon': Icons.restaurant_menu_rounded,
          'color': Colors.orange,
          'bgColor': const Color(0xFFFFFAF0),
          'description': entity.description,
          'actionLabel': 'Önerilen Mamalar',
        };
      case 'litter':
        return {
          'title': 'Kum & Hijyen Önerisi',
          'category': 'Sağlık',
          'icon': Icons.clean_hands_outlined,
          'color': Colors.blue,
          'bgColor': const Color(0xFFF0F9FF),
          'description': entity.description,
          'actionLabel': 'AI Asistan\'a Sor',
        };
      default:
        return {
          'title': 'Genel Bakım & Diğer Öneriler',
          'category': 'Genel',
          'icon': Icons.add,
          'color': Colors.grey,
          'bgColor': Colors.grey.shade100,
          'description': entity.description,
          'actionLabel': 'Detaylar',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);
    const peachBg = Color(0xFFFFECE5);
    const peachBorder = Color(0xFFFFB89C);
    const peachText = Color(0xFFD9531E);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'AI Analizi',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RecommendationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          List<RecommendationEntity> rawList = [];
          if (state is RecommendationLoaded) {
            rawList = state.recommendations;
          }
          //Veritabanı önerilerini UI formatına dönüştür
          final uiRecommendations = rawList.map(_mapRecommendation).toList();

          //Filtreleme
          final filteredList = _selectedCategory == 'Tümü'
              ? uiRecommendations
              : uiRecommendations
                  .where((r) => r['category'] == _selectedCategory)
                  .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AI Üst Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.containerMargin),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome,
                                      color: theme.colorScheme.tertiary,
                                      size: 24),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'VetTrack AI Analiz',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Yapay zeka asistanımız evcil hayvanınızın sağlık geçmişi, aşı takvimi ve davranış verilerini analiz ederek kişiselleştirilmiş tavsiyeler üretti.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filtre Butonları
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                      left: AppDimensions.containerMargin, bottom: 12),
                  child: Row(
                    children:
                        ['Tümü', 'Beslenme', 'Sağlık', 'Genel'].map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: AppDimensions.spacingSm),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                          selectedColor: primaryBlue,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Tavsiye Kartları Listesi
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Kayıtlı Öneri Bulunamadı',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Evcil hayvanınız için şu anda tanımlanmış bir öneri bulunmamaktadır. Muayene sonrası veteriner hekiminiz öneriler ekleyebilir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade500, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.containerMargin),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredList[index];
                        final cardColor = item['color'] as Color;
                        final bgColor = item['bgColor'] as Color;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(
                              bottom: AppDimensions.spacingMd),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                            side: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          color: theme.colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(item['icon'] as IconData,
                                          color: cardColor, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] as String,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF131B2E),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cardColor.withValues(
                                                  alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item['category'] as String,
                                              style: TextStyle(
                                                color: cardColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['description'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade800,
                                    height: 1.45,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.push('/chatbot');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: cardColor,
                                      side: BorderSide(
                                          color: cardColor, width: 1.2),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      item['actionLabel'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredList.length,
                    ),
                  ),
                ),

              // Yapay Zeka Sohbet Banner'ı (Sona Doğru Sohbeti Teşvik Eder)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.containerMargin),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: peachBg,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(color: peachBorder, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: peachText, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Kafanıza takılan bir soru mu var?',
                              style: TextStyle(
                                color: peachText,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AI Sohbet Asistanımız ile evcil hayvanınızın sağlığı hakkında her şeyi anında konuşabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.5,
                              height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/chatbot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: peachText,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                          ),
                          icon: const Icon(Icons.forum_outlined),
                          label: const Text(
                            'AI Asistan ile Sohbet Et',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}
