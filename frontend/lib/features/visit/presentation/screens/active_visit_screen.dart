import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:vettrack_frontend/core/di/injection_container.dart';
import 'package:vettrack_frontend/core/router/app_router.dart';
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
    if (createdAt == null) return false;
    final difference = DateTime.now().difference(createdAt.toLocal());
    return difference.inMinutes < 15;
  }

  int _remainingMinutes(DateTime? createdAt) {
    if (createdAt == null) return 0;
    final diff = DateTime.now().difference(createdAt.toLocal());
    final remaining = 15 - diff.inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> _deleteTreatment(TreatmentEntity treatment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tedavi Girişini Sil'),
        content: Text(
            '"${treatment.title}" kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
          const SnackBar(
            content: Text('Tedavi kaydı başarıyla silindi.'),
            backgroundColor: Colors.green,
          ),
        );
        _reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tedavi kaydı silinemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _close() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muayeneyi tamamla'),
        content: const Text(
            'Ziyaret kapatılacak. Hasta sahibine ziyaret özeti bildirimi gönderilecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tamamla ve kapat'),
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
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocListener<VisitCubit, VisitState>(
      listener: (context, state) {
        if (state is VisitClosed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Ziyaret kapatıldı. Hasta sahibine bildirim gönderildi.'),
              backgroundColor: Colors.teal,
            ),
          );
          context.go(AppRoutes.vetSearch);
        } else if (state is VisitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: FutureBuilder<ActiveVisitContext>(
        future: _context,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Aktif Muayene')),
              body: Center(
                  child:
                      Text('Ziyaret bilgileri alınamadı: ${snapshot.error}')),
            );
          }

          final data = snapshot.requireData;

          // Sol Taraf: Aktif Muayene Formu
          Widget buildActiveForm() => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.pets)),
                      title: Text(data.pet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Sahibi: ${data.ownerName}${data.ownerPhone == null ? '' : ' • ${data.ownerPhone}'}\nKod: ${data.pet.uniqueCode}'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final saved = await context.push<bool>(
                                '/vet/visit/${widget.visitId}/treatment/add');
                            if (saved == true) _reload();
                          },
                          icon: const Icon(Icons.medication),
                          label: const Text('Tedavi ekle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final saved = await context.push<bool>(
                                '/vet/visit/${widget.visitId}/recommendation/add');
                            if (saved == true) _reload();
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Öneri ekle'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Bu ziyaretteki tedaviler',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<TreatmentEntity>>(
                    future: _treatments,
                    builder: (context, treatmentSnapshot) {
                      if (treatmentSnapshot.connectionState !=
                          ConnectionState.done) {
                        return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()));
                      }
                      if (treatmentSnapshot.hasError) {
                        return const Text('Tedavi kayıtları yüklenemedi.');
                      }

                      final treatments = treatmentSnapshot.data ?? const [];
                      if (treatments.isEmpty) {
                        return const Text('Henüz tedavi kaydı yok.');
                      }

                      return Column(
                        children: treatments.map((t) {
                          final canDelete =
                              t.editable && _isDeletable(t.createdAt);
                          final remaining = _remainingMinutes(t.createdAt);
                          return ListTile(
                            leading: const Icon(Icons.medication,
                                color: Colors.teal),
                            title: Text(t.title),
                            subtitle: Text(
                              [
                                if (t.description != null &&
                                    t.description!.isNotEmpty)
                                  t.description
                                else
                                  TreatmentCategoryLocalization.typeToCategory(
                                      t.type),
                                if (canDelete)
                                  '($remaining dk içinde silinebilir)'
                              ].join(' • '),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color:
                                    canDelete ? Colors.redAccent : Colors.grey,
                              ),
                              tooltip: canDelete
                                  ? 'Sil ($remaining dk kaldı)'
                                  : '15 dakika dolduğu için silinemez',
                              onPressed:
                                  canDelete ? () => _deleteTreatment(t) : null,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Bu ziyaretteki öneriler',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<RecommendationEntity>>(
                    future: _recommendations,
                    builder: (context, recommendationSnapshot) {
                      if (recommendationSnapshot.connectionState !=
                          ConnectionState.done) {
                        return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()));
                      }
                      if (recommendationSnapshot.hasError) {
                        return const Text('Öneriler yüklenemedi.');
                      }

                      final recommendations =
                          recommendationSnapshot.data ?? const [];
                      if (recommendations.isEmpty) {
                        return const Text('Henüz öneri kaydı yok.');
                      }

                      return Column(
                        children: recommendations
                            .map((r) => ListTile(
                                  leading: const Icon(Icons.lightbulb_outline,
                                      color: Colors.orange),
                                  title: Text(r.type),
                                  subtitle: Text(r.description),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<VisitCubit, VisitState>(
                    builder: (context, state) => ElevatedButton.icon(
                      onPressed: state is VisitLoading ? null : _close,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(state is VisitLoading
                          ? 'Kapatılıyor...'
                          : 'Muayeneyi tamamla ve kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Tedavi kayıtları yalnızca ilk 15 dakika içinde düzenlenebilir veya silinebilir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );

          // Sağ Taraf: Geçmiş Medikal Zaman Çizgisi (Timeline)
          Widget buildTimeline() => Card(
                margin: const EdgeInsets.all(20),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: data.history.isEmpty
                            ? const Center(
                                child: Text('Geçmiş ziyaret bulunmuyor.'))
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
                                              radius: 16,
                                              backgroundColor: (visit.isOngoing
                                                      ? Colors.orange
                                                      : Colors.teal)
                                                  .withValues(alpha: 0.15),
                                              child: Icon(
                                                visit.isOngoing
                                                    ? Icons.pending
                                                    : Icons.check_circle,
                                                size: 18,
                                                color: visit.isOngoing
                                                    ? Colors.orange
                                                    : Colors.teal,
                                              ),
                                            ),
                                            if (index < data.history.length - 1)
                                              Container(
                                                  width: 2,
                                                  height: 40,
                                                  color: Colors.grey.shade300),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                visit.startedAt
                                                    .toLocal()
                                                    .toString()
                                                    .substring(0, 16),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                visit.isOngoing
                                                    ? 'Devam Eden Muayene'
                                                    : 'Tamamlanan Muayene',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              if (visit.chiefComplaint !=
                                                      null &&
                                                  visit.chiefComplaint!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Şikayet: ${visit.chiefComplaint}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ],
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
              title: Text('Aktif Muayene • ${data.pet.name}'),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
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
