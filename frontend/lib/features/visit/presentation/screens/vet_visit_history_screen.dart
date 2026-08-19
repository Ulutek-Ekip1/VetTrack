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
          decoration: const BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Muayene Detayı (${visit.id.toShortId()})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: 650, // Web ekranında okunabilirlik için sabit genişlik
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hasta Künyesi Özeti
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.pets, color: Colors.white),
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
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(Icons.check_circle,
                          size: 16, color: Colors.teal),
                      label: Text('Genel Fiziksel Muayene'),
                      backgroundColor: Color(0xFFE0F2F1),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, color: Colors.teal),
                          Expanded(
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
                backgroundColor: Colors.teal, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            label: const Text('Kapat'),
          )
        ],
      ),
    );
  }

  // Detay bölümü için yardımcı widget
  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              Text(content, style: const TextStyle(fontSize: 13, height: 1.3)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinik Muayene Geçmişi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                    child: Row(
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
                          items: ['Tümü', 'Devam Edenler', 'Tamamlananlar']
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
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
                          return const Center(
                            child: Text(
                              'Arama kriterlerine uygun muayene kaydı bulunamadı.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
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
                                      ? Colors.orange.shade100
                                      : Colors.teal.shade100,
                                  child: Icon(
                                    isOngoing
                                        ? Icons.pending_actions
                                        : Icons.check_circle_outline,
                                    color: isOngoing
                                        ? Colors.orange.shade800
                                        : Colors.teal.shade800,
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
                                        color: Colors.grey.shade200,
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
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    'Pet ID: ${visit.petId.toShortId()}\nŞikayet/Teşhis: ${visit.chiefComplaint ?? 'Belirtilmemiş'} • Tarih: ${visit.startedAt.toFormattedDateTime()}',
                                    style: const TextStyle(height: 1.3),
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isOngoing
                                            ? Colors.orange.shade100
                                            : isCancelled
                                                ? Colors.red.shade100
                                                : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isOngoing
                                            ? 'Devam Ediyor'
                                            : isCancelled
                                                ? 'İptal Edildi'
                                                : 'Tamamlandı',
                                        style: TextStyle(
                                          color: isOngoing
                                              ? Colors.orange.shade900
                                              : isCancelled
                                                  ? Colors.red.shade800
                                                  : Colors.green.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () => _showVisitDetailsDialog(
                                          context, visit),
                                      icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 18),
                                      label: const Text('Detay'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.teal,
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
