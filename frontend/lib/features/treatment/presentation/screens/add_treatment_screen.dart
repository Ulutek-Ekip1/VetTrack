import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/utils/treatment_category_localization.dart';
import '../cubit/treatment_cubit.dart';
import '../cubit/treatment_state.dart';
import 'package:vettrack_frontend/l10n/generated/app_localizations.dart';

class AddTreatmentScreen extends StatefulWidget {
  final String visitId;

  const AddTreatmentScreen({
    super.key,
    required this.visitId,
  });

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _treatmentTitleController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Aşı';

  @override
  void dispose() {
    _treatmentTitleController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSaveTreatment() {
    if (_formKey.currentState!.validate()) {
      final description = [
        if (_dosageController.text.trim().isNotEmpty)
          'Doz/Sıklık: ${_dosageController.text.trim()}',
        if (_notesController.text.trim().isNotEmpty)
          'Açıklama: ${_notesController.text.trim()}',
      ].join('\n');

      context.read<TreatmentCubit>().addTreatment(
            visitId: widget.visitId,
            type:
                TreatmentCategoryLocalization.categoryToType(_selectedCategory),
            title: _treatmentTitleController.text.trim(),
            description: description.isNotEmpty ? description : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<TreatmentCubit, TreatmentState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is TreatmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is TreatmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.addTreatment(widget.visitId)),
            centerTitle: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.treatmentType,
                        prefixIcon: const Icon(Icons.category),
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Aşı', child: Text('Aşı Uygulaması')),
                        DropdownMenuItem(
                            value: 'İlaç',
                            child: Text('İlaç Tedavisi/ Reçete')),
                        DropdownMenuItem(
                            value: 'Operasyon',
                            child: Text('Cerrahi Operasyon')),
                        DropdownMenuItem(
                            value: 'Röntgen',
                            child: Text('Röntgen / Sonuç Görüntüleme')),
                        DropdownMenuItem(
                            value: 'Laboratuvar',
                            child: Text('Laboratuvar / Sonuç Görüntüleme')),
                        DropdownMenuItem(
                            value: 'Not', child: Text('Diğer Notlar')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _treatmentTitleController,
                      decoration: InputDecoration(
                        labelText: l10n.treatmentName,
                        prefixIcon: const Icon(Icons.medication),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) => val!.trim().isEmpty
                          ? l10n.treatmentRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: l10n.dosageFrequency,
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.treatmentInstructions,
                        prefixIcon: const Icon(Icons.description),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<TreatmentCubit, TreatmentState>(
                      builder: (context, state) {
                        final isLoading = state is TreatmentLoading;
                        return ElevatedButton.icon(
                          onPressed: isLoading ? null : _onSaveTreatment,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
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
                              : const Icon(Icons.save),
                          label: Text(
                            isLoading
                                ? l10n.savingTreatment
                                : l10n.saveTreatment,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
