import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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
                    child: const Center(child: Text('Henüz tedavi kaydı yok.')),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TreatmentCubit>().loadPetTreatments(petId),
              child: ListView.builder(
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
                        '${TreatmentCategoryLocalization.typeToCategory(treatment.type)}\n${treatment.description ?? ''}',
                      ),
                      isThreeLine: treatment.description != null &&
                          treatment.description!.isNotEmpty,
                      trailing: hasAttachment
                          ? IconButton(
                              icon: Icon(Icons.open_in_new,
                                  color: theme.colorScheme.primary),
                              tooltip: 'Eki Görüntüle',
                              onPressed: () async {
                                final uri = Uri.parse(treatment.attachmentUrl!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Dosya açılamadı.')),
                                    );
                                  }
                                }
                              },
                            )
                          : null,
                    ),
                  );
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
