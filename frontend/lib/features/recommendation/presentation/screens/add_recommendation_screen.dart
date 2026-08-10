import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/recommendation/presentation/cubit/recommendation_cubit.dart';
import 'package:vettrack_frontend/features/recommendation/presentation/cubit/recommendation_state.dart';

class AddRecommendationScreen extends StatefulWidget {
  final String visitId;

  const AddRecommendationScreen({
    super.key,
    required this.visitId,
  });

  @override
  State<AddRecommendationScreen> createState() =>
      _AddRecommendationScreenState();
}

class _AddRecommendationScreenState extends State<AddRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'food';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSaveRecommendation() {
    if (_formKey.currentState!.validate()) {
      context.read<RecommendationCubit>().addRecommendation(
            visitId: widget.visitId,
            type: _selectedType,
            description: _descriptionController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecommendationCubit, RecommendationState>(
      listener: (context, state) {
        if (state is RecommendationActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is RecommendationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Öneri Ekle (#${widget.visitId})'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Öneri Türü',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'food', child: Text('Beslenme / Mama')),
                    DropdownMenuItem(
                        value: 'litter', child: Text('Kum / Hijyen')),
                    DropdownMenuItem(
                        value: 'other', child: Text('Genel Bakım & Diğer')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Öneri Detayı ve Açıklaması',
                    prefixIcon: Icon(Icons.comment_bank_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Lütfen öneri detayını yazın'
                      : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<RecommendationCubit, RecommendationState>(
                  builder: (context, state) {
                    final isLoading = state is RecommendationLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _onSaveRecommendation,
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
                        isLoading ? 'Kaydediliyor...' : 'Öneriyi Kaydet',
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
    );
  }
}
