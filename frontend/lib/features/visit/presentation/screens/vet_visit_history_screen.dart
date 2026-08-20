import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/core/widgets/app_error_widget.dart';
import '../cubit/visit_cubit.dart';
import '../cubit/visit_state.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';

class VetVisitHistoryScreen extends StatefulWidget {
  const VetVisitHistoryScreen({super.key});

  @override
  State<VetVisitHistoryScreen> createState() => _VetVisitHistoryScreenState();
}

class _VetVisitHistoryScreenState extends State<VetVisitHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Arama ve Filtreleme Mantığı
  List<VisitEntity> _getFilteredVisits(List<VisitEntity> visits) {
    return visits.where((visit) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = visit.id.toLowerCase().contains(query) ||
          (visit.chiefComplaint ?? '').toLowerCase().contains(query);

      if (_selectedFilter == 'Devam Edenler') {
        return matchesSearch && visit.isOngoing;
      } else if (_selectedFilter == 'Tamamlananlar') {
        return matchesSearch && visit.isCompleted;
      } else if (_selectedFilter == 'İptal Edilenler') {
        return matchesSearch && visit.isCancelled;
      }
      return matchesSearch;
    }).toList();
  }

  // Muayene Detay Diyaloğu
  void _showVisitDetailsDialog(BuildContext context, VisitEntity visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(24),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined,
                      color: Theme.of(context).colorScheme.onSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Muayene Detayı (${visit.id.toShortId()})',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width > 700 ? 650 : null,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hasta Künyesi Özeti
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Icon(Icons.pets,
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet ID: ${visit.petId.toShortId()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'Hekim: ${visit.vetStaffName ?? 'Bilinmeyen Hekim'} | Tarih: ${visit.startedAt.toLocal().toString().substring(0, 16)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Teşhis / Şikayet
                _buildDetailSection('Teşhis / Şikayet',
                    visit.chiefComplaint ?? 'Belirtilmemiş', Icons.healing),
                const SizedBox(height: 16),

                // Uygulanan Tedaviler
                const Text('Uygulanan Tedaviler & Aşılar',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(Icons.check_circle,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary),
                      label: const Text('Genel Fiziksel Muayene'),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.15),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Reçete
                _buildDetailSection('Reçete & İlaçlar',
                    'Geçmiş reçete kaydı bulunmamaktadır.', Icons.medication),
                const SizedBox(height: 16),

                // Ev İçin Öneriler
                const Text('Hasta Sahibine Öneriler',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right,
                              color: Theme.of(context).colorScheme.secondary),
                          const Expanded(
                              child:
                                  Text('Genel sağlık kurallarına uyulmalı.')),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Hekim Notları
                _buildDetailSection(
                    'Hekim Notları',
                    visit.chiefComplaint ??
                        'Hekim tarafından girilen not bulunmamaktadır.',
                    Icons.note_alt_outlined),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary),
            icon: const Icon(Icons.check),
            label: const Text('Kapat'),
          )
        ],
      ),
    );
  }

  // Detay bölümü için yardımcı widget
  Widget _buildDetailSection(String title, String content, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.secondary),
            const SizedBox(width: 6),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child:
              Text(content, style: const TextStyle(fontSize: 13, height: 1.3)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isNarrow = width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hekim Muayene Geçmişi'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 1200), // Web paneli genişlik sınırı
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Arama ve Filtreleme Barı
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Hasta adı, sahibi veya teşhis ile ara...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Filtrele',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                ),
                                items: [
                                  'Tümü',
                                  'Devam Edenler',
                                  'Tamamlananlar'
                                ]
                                    .map((f) => DropdownMenuItem(
                                        value: f, child: Text(f)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedFilter = val);
                                  }
                                },
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Hasta adı, sahibi veya teşhis ile ara...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              DropdownButton<String>(
                                value: _selectedFilter,
                                items: [
                                  'Tümü',
                                  'Devam Edenler',
                                  'Tamamlananlar'
                                ]
                                    .map((f) => DropdownMenuItem(
                                        value: f, child: Text(f)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedFilter = val);
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Muayene Geçmişi Listesi
                Expanded(
                  child: BlocBuilder<VisitCubit, VisitState>(
                    builder: (context, state) {
                      if (state is VisitLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is VisitError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: () =>
                              context.read<VisitCubit>().fetchVetVisitHistory(),
                        );
                      }
                      if (state is VisitHistoryLoaded) {
                        final filtered = _getFilteredVisits(state.visits);
                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              'Arama kriterlerine uygun muayene kaydı bulunamadı.',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 16),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final visit = filtered[index];
                            final isOngoing = visit.isOngoing;
                            final isCancelled = visit.isCancelled;

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isOngoing
                                      ? Theme.of(context)
                                          .colorScheme
                                          .tertiary
                                          .withValues(alpha: 0.15)
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.15),
                                  child: Icon(
                                    isOngoing
                                        ? Icons.pending_actions
                                        : Icons.check_circle_outline,
                                    color: isOngoing
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      visit.petId.toShortId(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        visit.id.toShortId(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        'Pet ID: ${visit.petId.toShortId()}\nŞikayet/Teşhis: ${visit.chiefComplaint ?? 'Belirtilmemiş'} • Tarih: ${visit.startedAt.toFormattedDateTime()}',
                                        style: const TextStyle(height: 1.3),
                                      ),
                                    ),
                                    if (isNarrow) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isOngoing
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .tertiary
                                                      .withValues(alpha: 0.15)
                                                  : isCancelled
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .errorContainer
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withValues(
                                                              alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isOngoing
                                                  ? 'Devam Ediyor'
                                                  : isCancelled
                                                      ? 'İptal Edildi'
                                                      : 'Tamamlandı',
                                              style: TextStyle(
                                                color: isOngoing
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .tertiary
                                                    : isCancelled
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .error
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _showVisitDetailsDialog(
                                                    context, visit),
                                            icon: const Icon(
                                                Icons.visibility_outlined,
                                                size: 18),
                                            label: const Text('Detay'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                isThreeLine: !isNarrow,
                                trailing: isNarrow
                                    ? null
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isOngoing
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .tertiary
                                                      .withValues(alpha: 0.15)
                                                  : isCancelled
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .errorContainer
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withValues(
                                                              alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isOngoing
                                                  ? 'Devam Ediyor'
                                                  : isCancelled
                                                      ? 'İptal Edildi'
                                                      : 'Tamamlandı',
                                              style: TextStyle(
                                                color: isOngoing
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .tertiary
                                                    : isCancelled
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .error
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _showVisitDetailsDialog(
                                                    context, visit),
                                            icon: const Icon(
                                                Icons.visibility_outlined,
                                                size: 18),
                                            label: const Text('Detay'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
