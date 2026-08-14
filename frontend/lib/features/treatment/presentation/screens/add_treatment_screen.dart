import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/utils/treatment_category_localization.dart';
import '../cubit/treatment_cubit.dart';
import '../cubit/treatment_state.dart';

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
            title: Text('Tedavi/Reçete Ekle (#${widget.visitId})'),
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
                      decoration: const InputDecoration(
                        labelText: 'İşlem Türü',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Tedavi Adı/ Aşı Adı',
                        prefixIcon: Icon(Icons.medication),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.trim().isEmpty
                          ? 'Lütfen tedavi adını girin'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Doz / Kullanım Sıklığı',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Kullanım Talimatı ve Açıklama',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
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
                                ? 'Tedavi Kaydediliyor...'
                                : 'Tedaviyi Kaydet',
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
