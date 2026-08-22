import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vettrack_frontend/features/treatment/domain/entities/treatment_entity.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_cubit.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_state.dart';
import 'package:vettrack_frontend/features/treatment/presentation/utils/treatment_category_localization.dart';

class PetTreatmentHistoryScreen extends StatelessWidget {
  final String petId;

  const PetTreatmentHistoryScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tedaviler & Reçeteler',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<TreatmentCubit, TreatmentState>(
        builder: (context, state) {
          if (state is TreatmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TreatmentError) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TreatmentCubit>().loadPetTreatments(petId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(child: Text(state.message)),
                ),
              ),
            );
          }
          if (state is TreatmentLoaded) {
            final treatments = state.treatments;
            if (treatments.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<TreatmentCubit>().loadPetTreatments(petId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.healing_outlined,
                            size: 64,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz tedavi veya reçete kaydı yok.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TreatmentCubit>().loadPetTreatments(petId),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: treatments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return TreatmentCard(treatment: treatments[index]);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class TreatmentCard extends StatelessWidget {
  final TreatmentEntity treatment;

  const TreatmentCard({
    super.key,
    required this.treatment,
  });

  Color _getCategoryColor(String type) {
    switch (type.toUpperCase()) {
      case 'VACCINE':
      case 'ASI':
      case 'AŞI':
        return const Color(0xFF10B981); // Emerald
      case 'MEDICATION':
      case 'ILAC':
      case 'İLAÇ':
        return const Color(0xFF06B6D4); // Cyan
      case 'OPERATION':
      case 'OPERASYON':
      case 'SURGERY':
        return const Color(0xFFF43F5E); // Rose
      case 'EXAMINATION':
      case 'MUAYENE':
        return const Color(0xFF6366F1); // Indigo
      case 'LAB':
      case 'TAHLIL':
      case 'TAHLİL':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toUpperCase()) {
      case 'VACCINE':
      case 'ASI':
      case 'AŞI':
        return Icons.vaccines_rounded;
      case 'MEDICATION':
      case 'ILAC':
      case 'İLAÇ':
        return Icons.medication_rounded;
      case 'OPERATION':
      case 'OPERASYON':
      case 'SURGERY':
        return Icons.medical_services_rounded;
      case 'EXAMINATION':
      case 'MUAYENE':
        return Icons.assignment_ind_rounded;
      case 'LAB':
      case 'TAHLIL':
      case 'TAHLİL':
        return Icons.science_rounded;
      default:
        return Icons.healing_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Ock',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Ekm',
      'Kas',
      'Ara'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = _getCategoryColor(treatment.type);
    final catIcon = _getCategoryIcon(treatment.type);
    final hasAttachment =
        treatment.attachmentUrl != null && treatment.attachmentUrl!.isNotEmpty;
    final dateStr = _formatDate(treatment.startDate ?? treatment.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
              : catColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: catColor.withValues(alpha: isDark ? 0.05 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: İkon, Başlık, Kategori ve Tarih
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    catIcon,
                    color: catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              treatment.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (dateStr.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dateStr,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          TreatmentCategoryLocalization.typeToCategory(
                              treatment.type),
                          style: TextStyle(
                            color: catColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Açıklama Alanı (Varsa)
            if (treatment.description != null &&
                treatment.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  treatment.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],

            // Ek Dosya Butonu (Varsa)
            if (hasAttachment) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final uri = Uri.parse(treatment.attachmentUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dosya açılamadı.')),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ekli Dosyayı Aç',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

