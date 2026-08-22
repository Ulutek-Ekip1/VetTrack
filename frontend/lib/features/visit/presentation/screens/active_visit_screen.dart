import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:vettrack_frontend/core/di/injection_container.dart';
import 'package:vettrack_frontend/core/router/app_router.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/active_visit_context.dart';
import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';
import 'package:vettrack_frontend/features/treatment/domain/entities/treatment_entity.dart';
import 'package:vettrack_frontend/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:vettrack_frontend/features/treatment/presentation/utils/treatment_category_localization.dart';
import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:vettrack_frontend/features/recommendation/domain/repositories/recommendation_repository.dart';

class ActiveVisitScreen extends StatefulWidget {
  final String visitId;
  const ActiveVisitScreen({super.key, required this.visitId});

  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  late Future<ActiveVisitContext> _context;
  late Future<List<TreatmentEntity>> _treatments;
  late Future<List<RecommendationEntity>> _recommendations;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _reload();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reload() => setState(() {
        _context = sl<VisitRepository>().getActiveVisitContext(widget.visitId);
        _treatments = sl<TreatmentRepository>().getTreatments(widget.visitId);
        _recommendations = sl<RecommendationRepository>()
            .getVisitRecommendations(widget.visitId);
      });

  bool _isDeletable(DateTime? createdAt) {
    if (createdAt == null) return true;
    final nowUtc = DateTime.now().toUtc();
    final createdUtc = createdAt.toUtc();
    final difference = nowUtc.difference(createdUtc);
    return difference.inMinutes >= -1 && difference.inMinutes < 15;
  }

  int _remainingMinutes(DateTime? createdAt) {
    if (createdAt == null) return 0;
    final nowUtc = DateTime.now().toUtc();
    final createdUtc = createdAt.toUtc();
    final diff = nowUtc.difference(createdUtc);
    final remaining = 15 - diff.inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  String _formatRecommendationType(String type) {
    switch (type) {
      case 'food':
        return 'Beslenme / Mama Önerisi';
      case 'litter':
        return 'Kum / Hijyen Önerisi';
      case 'other':
        return 'Genel Bakım & Diğer';
      default:
        return type;
    }
  }

  Future<void> _deleteTreatment(TreatmentEntity treatment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Tedavi Kaydını Sil'),
          ],
        ),
        content: Text(
            '"${treatment.title}" kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await sl<TreatmentRepository>().deleteTreatment(treatment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Tedavi kaydı başarıyla silindi.'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        _reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tedavi kaydı silinemedi: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _close() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.teal),
            SizedBox(width: 8),
            Text('Muayeneyi Tamamla'),
          ],
        ),
        content: const Text(
            'Ziyaret kapatılacak ve hasta sahibine ziyaret özeti bildirimi gönderilecektir. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tamamla ve Kapat'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<VisitCubit>().closeVisit(widget.visitId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocListener<VisitCubit, VisitState>(
      listener: (context, state) {
        if (state is VisitClosed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Ziyaret kapatıldı. Hasta sahibine bildirim gönderildi.'),
                ],
              ),
              backgroundColor: Colors.teal.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.go(AppRoutes.vetSearch);
        } else if (state is VisitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: FutureBuilder<ActiveVisitContext>(
        future: _context,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(title: const Text('Aktif Muayene')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Aktif Muayene')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text('Ziyaret bilgileri alınamadı:\n${snapshot.error}',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reload,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.requireData;
          final ownerPhoneClean = data.ownerPhone?.trim();
          final hasPhone = ownerPhoneClean != null && ownerPhoneClean.isNotEmpty;

          // Sol Taraf: Aktif Muayene Formu
          Widget buildActiveForm() => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. Hasta & Sahip Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pets_rounded,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      data.pet.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Kod: ${data.pet.uniqueCode}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      data.ownerName.isNotEmpty
                                          ? data.ownerName
                                          : 'Bilinmeyen Sahip',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (hasPhone) ...[
                                      const SizedBox(width: 12),
                                      Icon(Icons.phone_outlined,
                                          size: 15,
                                          color:
                                              theme.colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        ownerPhoneClean,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Aksiyon Butonları (Tedavi & Öneri Ekle)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final saved = await context.push<bool>(
                                '/vet/visit/${widget.visitId}/treatment/add');
                            if (saved == true) _reload();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.medical_services_rounded,
                              size: 20),
                          label: const Text(
                            'Tedavi Ekle',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final saved = await context.push<bool>(
                                '/vet/visit/${widget.visitId}/recommendation/add');
                            if (saved == true) _reload();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.lightbulb_rounded, size: 20),
                          label: const Text(
                            'Öneri Ekle',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Bu Ziyaretteki Tedaviler Bölümü
                  FutureBuilder<List<TreatmentEntity>>(
                    future: _treatments,
                    builder: (context, treatmentSnapshot) {
                      final treatments = treatmentSnapshot.data ?? const [];
                      final count = treatments.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medication_rounded,
                                  color: Colors.teal, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Bu Ziyaretteki Tedaviler',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (treatmentSnapshot.connectionState !=
                              ConnectionState.done)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (treatments.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 36,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Henüz kayıtlı tedavi yok',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Yukarıdaki "Tedavi Ekle" butonunu kullanarak aşı, ilaç veya operasyon ekleyebilirsiniz.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: treatments.map((t) {
                                final canDelete =
                                    t.editable && _isDeletable(t.createdAt);
                                final remaining = _remainingMinutes(t.createdAt);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.medication_rounded,
                                          color: Colors.teal, size: 20),
                                    ),
                                    title: Text(
                                      t.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme.primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  TreatmentCategoryLocalization
                                                      .typeToCategory(t.type),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              if (canDelete) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$remaining dk silinebilir',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.orange.shade800,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (t.description != null &&
                                              t.description!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              t.description!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: canDelete
                                            ? Colors.redAccent
                                            : Colors.grey.shade400,
                                      ),
                                      tooltip: canDelete
                                          ? 'Sil ($remaining dk kaldı)'
                                          : '15 dakika dolduğu için silinemez',
                                      onPressed: canDelete
                                          ? () => _deleteTreatment(t)
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Bu Ziyaretteki Öneriler Bölümü
                  FutureBuilder<List<RecommendationEntity>>(
                    future: _recommendations,
                    builder: (context, recommendationSnapshot) {
                      final recommendations =
                          recommendationSnapshot.data ?? const [];
                      final count = recommendations.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_rounded,
                                  color: Colors.orange.shade700, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Bu Ziyaretteki Öneriler',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (recommendationSnapshot.connectionState !=
                              ConnectionState.done)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (recommendations.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.lightbulb_outlined,
                                      size: 36,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Henüz öneri kaydı eklenmedi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Evcil hayvan için beslenme, kum veya bakım tavsiyelerini "Öneri Ekle" butonundan ekleyebilirsiniz.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: recommendations.map((r) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.orange.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.lightbulb_rounded,
                                          color: Colors.orange.shade700, size: 20),
                                    ),
                                    title: Text(
                                      _formatRecommendationType(r.type),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        r.description,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 5. Muayene Kapatma Alanı
                  BlocBuilder<VisitCubit, VisitState>(
                    builder: (context, state) {
                      final isLoading = state is VisitLoading;
                      return Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _close,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded,
                                    size: 22),
                            label: Text(
                              isLoading
                                  ? 'Kapatılıyor...'
                                  : 'Muayeneyi Tamamla ve Kaydet',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tedavi kayıtları yalnızca ilk 15 dakika içinde düzenlenebilir veya silinebilir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );

          // Sağ Taraf: Geçmiş Medikal Zaman Çizgisi (Timeline)
          Widget buildTimeline() => Card(
                margin: const EdgeInsets.all(20),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded,
                              color: Colors.teal, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Tıbbi Geçmiş & Zaman Çizgisi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${data.history.length} Ziyaret',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: data.history.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_outlined,
                                        size: 40,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Geçmiş ziyaret bulunmuyor.',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: data.history.length,
                                itemBuilder: (context, index) {
                                  final visit = data.history[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: (visit.isOngoing
                                                      ? Colors.orange
                                                      : Colors.teal)
                                                  .withValues(alpha: 0.15),
                                              child: Icon(
                                                visit.isOngoing
                                                    ? Icons.pending_rounded
                                                    : Icons.check_circle_rounded,
                                                size: 16,
                                                color: visit.isOngoing
                                                    ? Colors.orange.shade800
                                                    : Colors.teal,
                                              ),
                                            ),
                                            if (index < data.history.length - 1)
                                              Container(
                                                width: 2,
                                                height: 44,
                                                color: theme.colorScheme.outlineVariant
                                                    .withValues(alpha: 0.5),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Card(
                                            elevation: 0,
                                            color: theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        visit.startedAt
                                                            .toFormattedDateTime(),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6,
                                                            vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: visit.isOngoing
                                                              ? Colors.orange.shade100
                                                              : Colors.green.shade100,
                                                          borderRadius:
                                                              BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          visit.isOngoing
                                                              ? 'Devam Ediyor'
                                                              : 'Tamamlandı',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: visit.isOngoing
                                                                ? Colors.orange.shade900
                                                                : Colors.green.shade900,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    visit.chiefComplaint ??
                                                        'Genel Kontrol',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Aktif Muayene • ${data.pet.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            ),
            body: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: buildActiveForm()),
                        const VerticalDivider(width: 1),
                        Expanded(flex: 2, child: buildTimeline()),
                      ],
                    )
                  : buildActiveForm(),
            ),
          );
        },
      ),
    );
  }
}
