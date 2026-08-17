import 'package:flutter/material.dart';
import 'package:vettrack_frontend/core/di/injection_container.dart';
import 'package:vettrack_frontend/core/widgets/app_async_state_views.dart';
import 'package:vettrack_frontend/features/treatment/domain/entities/treatment_entity.dart';
import 'package:vettrack_frontend/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:vettrack_frontend/l10n/generated/app_localizations.dart';

class PetTreatmentHistoryScreen extends StatefulWidget {
  final String petId;
  const PetTreatmentHistoryScreen({super.key, required this.petId});
  @override State<PetTreatmentHistoryScreen> createState() => _PetTreatmentHistoryScreenState();
}

class _PetTreatmentHistoryScreenState extends State<PetTreatmentHistoryScreen> {
  late Future<List<TreatmentEntity>> _treatments;
  @override void initState() { super.initState(); _treatments = sl<TreatmentRepository>().getPetTreatments(widget.petId); }

  void _reload() {
    setState(() {
      _treatments = sl<TreatmentRepository>().getPetTreatments(widget.petId);
    });
  }

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
    appBar: AppBar(title: Text(l10n.treatmentsAndPrescriptions), backgroundColor: Colors.teal, foregroundColor: Colors.white),
    body: FutureBuilder<List<TreatmentEntity>>(future: _treatments, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return AppLoadingView(label: l10n.treatmentHistoryLoading);
      if (snapshot.hasError) return AppErrorStateView(message: l10n.treatmentHistoryLoadFailed, onRetry: _reload);
      final treatments = snapshot.data ?? const [];
      if (treatments.isEmpty) return AppEmptyStateView(icon: Icons.medication_outlined, title: l10n.noTreatmentRecords);
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: treatments.length, itemBuilder: (context, index) { final treatment = treatments[index]; return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.medication)), title: Text(treatment.title), subtitle: Text('${treatment.type}\n${treatment.description ?? ''}'), isThreeLine: treatment.description != null)); });
    }),
  );
  }
}
