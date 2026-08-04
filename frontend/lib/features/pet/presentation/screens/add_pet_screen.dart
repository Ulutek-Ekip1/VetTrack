import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pet_entity.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showDiscardModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 48),
            SizedBox(height: 8),
            Text('Kaydetmeden Çık?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Değişiklikleri kaydetmeden çıkmak istiyor musunuz?',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal', style: TextStyle(color: Color(0xFF131B2E))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Dialog'u kapat
                    Navigator.pop(context); // Sayfadan çık
                  },
                  child: const Text('Evet, Çık'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final species = _speciesController.text.trim();
      final breed = _breedController.text.trim();
      final ageText = _ageController.text.trim();
      final age = ageText.isNotEmpty ? int.tryParse(ageText) : null;

      // Tür ve Cinsi birleştirerek kaydediyoruz (örn. "Kedi / Tekir")
      final combinedBreed = species.isNotEmpty
          ? (breed.isNotEmpty ? "$species / $breed" : species)
          : breed;

      context.read<PetCubit>().addPet(
            name: name,
            gender: _selectedGender,
            age: age,
            breed: combinedBreed.isNotEmpty ? combinedBreed : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);
    const buttonBlue = Color(0xFF2563EB);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hayvan Ekle', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showDiscardModal(context),
        ),
      ),
      body: BlocListener<PetCubit, PetState>(
        listener: (context, state) {
          if (state is PetActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF006B5F),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is PetActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(Icons.camera_alt, size: 40, color: Color(0xFF434655)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Adı *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Lütfen bir ad girin' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cinsiyet *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<Gender>(
                  segments: const [
                    ButtonSegment<Gender>(
                      value: Gender.male,
                      label: Text('Erkek'),
                      icon: Icon(Icons.male, color: Colors.blue),
                    ),
                    ButtonSegment<Gender>(
                      value: Gender.female,
                      label: Text('Dişi'),
                      icon: Icon(Icons.female, color: Colors.pink),
                    ),
                    ButtonSegment<Gender>(
                      value: Gender.unknown,
                      label: Text('Bilinmiyor'),
                      icon: Icon(Icons.pets, color: Colors.teal),
                    ),
                  ],
                  selected: {_selectedGender},
                  onSelectionChanged: (Set<Gender> newSelection) {
                    setState(() {
                      _selectedGender = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _speciesController,
                  decoration: InputDecoration(
                    labelText: 'Türü * (örn. Kedi, Köpek)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Lütfen hayvan türünü girin' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    labelText: 'Cinsi / Irkı (örn. Tekir, Golden)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<PetCubit, PetState>(
        builder: (context, state) {
          final isLoading = state is PetActionLoading;

          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: isLoading ? null : _onSave,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                isLoading ? 'Kaydediliyor...' : 'Kaydet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
