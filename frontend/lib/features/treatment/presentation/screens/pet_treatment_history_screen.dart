import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_cubit.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_state.dart';

class PetTreatmentHistoryScreen extends StatelessWidget {
  final String petId;

  const PetTreatmentHistoryScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tedaviler & Reçeteler'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TreatmentCubit, TreatmentState>(
        builder: (context, state) {
          if (state is TreatmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TreatmentError) {
            return Center(child: Text(state.message));
          }
          if (state is TreatmentLoaded) {
            final treatments = state.treatments;
            if (treatments.isEmpty) {
              return const Center(child: Text('Henüz tedavi kaydı yok.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: treatments.length,
              itemBuilder: (context, index) {
                final treatment = treatments[index];
                final hasAttachment = treatment.attachmentUrl != null &&
                    treatment.attachmentUrl!.isNotEmpty;

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication),
                    ),
                    title: Text(treatment.title),
                    subtitle: Text(
                      '${treatment.type}\n${treatment.description ?? ''}',
                    ),
                    isThreeLine: treatment.description != null &&
                        treatment.description!.isNotEmpty,
                    trailing: hasAttachment
                        ? IconButton(
                            icon: const Icon(Icons.open_in_new, color: Colors.teal),
                            tooltip: 'Eki Görüntüle',
                            onPressed: () async {
                              final uri = Uri.parse(treatment.attachmentUrl!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dosya açılamadı.')),
                                  );
                                }
                              }
                            },
                          )
                        : null,
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
