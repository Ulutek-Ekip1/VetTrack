import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';

class OwnerVisitHistoryListScreen extends StatelessWidget {
  const OwnerVisitHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziyaret & Muayene Geçmişi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<VisitCubit, VisitState>(
        builder: (context, state) {
          if (state is VisitLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VisitError) {
            return Center(child: Text(state.message));
          }
          if (state is VisitHistoryLoaded) {
            final visits = state.visits;
            if (visits.isEmpty) {
              return const Center(child: Text('Ziyaret geçmişi bulunamadı.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                final isOngoing = visit.isOngoing;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.history_edu, color: Colors.white),
                    ),
                    title: Text(
                      'Ziyaret #${visit.id.toShortId()} - ${visit.chiefComplaint ?? 'Genel Kontrol'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${visit.startedAt.toLocal().toString().substring(0, 16)} • ${visit.vetStaffName ?? 'Bilinmeyen Hekim'}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOngoing ? Colors.blue.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOngoing ? 'Devam Ediyor' : 'Tamamlandı',
                        style: TextStyle(
                          color: isOngoing ? Colors.blue.shade800 : Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
