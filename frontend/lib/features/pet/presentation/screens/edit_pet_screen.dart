import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pet_entity.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';

class EditPetScreen extends StatefulWidget {
  final String petId;

  const EditPetScreen({
    super.key,
    required this.petId,
  });

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  Gender _selectedGender = Gender.male;
  bool _isInitialDataLoaded = false;
  bool _ageUnknown = false;
  String? _photoUrl;
  final _nameFocusNode = FocusNode();
  final _speciesFocusNode = FocusNode();
  final _breedFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _speciesController = TextEditingController();
    _breedController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialDataLoaded) {
      final petState = context.read<PetCubit>().state;
      if (petState is PetLoaded) {
        try {
          final pet = petState.pets.firstWhere((p) => p.id == widget.petId);
          _nameController.text = pet.name;
          
          if (pet.breed != null) {
            final parts = pet.breed!.split(' / ');
            if (parts.length > 1) {
              _speciesController.text = parts[0];
              _breedController.text = parts[1];
            } else {
              _speciesController.text = '';
              _breedController.text = pet.breed!;
            }
          } else {
            _speciesController.text = '';
            _breedController.text = '';
          }

          _ageController.text = pet.age?.toString() ?? '';
          _ageUnknown = pet.age == null;
          _selectedGender = pet.gender;
          _photoUrl = pet.photoUrl;
          _isInitialDataLoaded = true;
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _nameFocusNode.dispose();
    _speciesFocusNode.dispose();
    _breedFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final species = _speciesController.text.trim();
      final breed = _breedController.text.trim();
      final ageText = _ageController.text.trim();
      final age = !_ageUnknown && ageText.isNotEmpty ? int.tryParse(ageText) : null;

      final combinedBreed = species.isNotEmpty
          ? (breed.isNotEmpty ? "$species / $breed" : species)
          : breed;

      context.read<PetCubit>().updatePet(
            id: widget.petId,
            name: name,
            gender: _selectedGender,
            age: age,
            breed: combinedBreed.isNotEmpty ? combinedBreed : null,
          );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 48),
            SizedBox(height: 8),
            Text('Evcil Hayvanı Sil?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bu evcil hayvanı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
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
                    Navigator.pop(dialogContext);
                    context.read<PetCubit>().deletePet(id: widget.petId);
                  },
                  child: const Text('Evet, Sil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);
    const buttonBlue = Color(0xFF2563EB);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dostu Düzenle', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            tooltip: 'Evcil Hayvanı Sil',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
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
                          image: _photoUrl != null && _photoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoUrl == null || _photoUrl!.isEmpty
                            ? const Icon(Icons.camera_alt, size: 40, color: Color(0xFF434655))
                            : null,
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
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  focusNode: _nameFocusNode,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Adı *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Lütfen bir ad girin' : null,
                  onFieldSubmitted: (_) => _speciesFocusNode.requestFocus(),
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
                Row(
                  children: [
                    _buildGenderOption(Gender.male, 'Erkek', Icons.male, Colors.blue),
                    const SizedBox(width: 8),
                    _buildGenderOption(Gender.female, 'Dişi', Icons.female, Colors.pink),
                    const SizedBox(width: 8),
                    _buildGenderOption(Gender.unknown, 'Bilinmiyor', Icons.pets, Colors.teal),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _speciesFocusNode,
                  controller: _speciesController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Türü * (örn. Kedi, Köpek)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Lütfen hayvan türünü girin' : null,
                  onFieldSubmitted: (_) => _breedFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _breedFocusNode,
                  controller: _breedController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Cinsi / Irkı (örn. Tekir, Golden)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onFieldSubmitted: (_) => _ageFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: _ageFocusNode,
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        enabled: !_ageUnknown,
                        decoration: InputDecoration(
                          labelText: 'Yaş',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (val) {
                          if (_ageUnknown) return null;
                          if (val != null && val.isNotEmpty) {
                            final ageVal = int.tryParse(val);
                            if (ageVal == null || ageVal < 0 || ageVal > 30) {
                              return 'Lütfen 0-30 arası bir yaş girin';
                            }
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _ageUnknown = !_ageUnknown;
                            if (_ageUnknown) {
                              _ageController.clear();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 56, // Metin kutusu yüksekliğiyle tam eşleşir
                          decoration: BoxDecoration(
                            color: _ageUnknown
                                ? primaryBlue.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _ageUnknown ? primaryBlue : Colors.grey.shade400,
                              width: _ageUnknown ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _ageUnknown ? Icons.check_circle : Icons.help_outline,
                                color: _ageUnknown ? primaryBlue : const Color(0xFF434655),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bilinmiyor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _ageUnknown ? primaryBlue : const Color(0xFF434655),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<PetCubit, PetState>(
                  builder: (context, state) {
                    final isLoading = state is PetActionLoading;
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: isLoading ? null : _onUpdate,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.update),
                      label: Text(
                        isLoading ? 'Güncelleniyor...' : 'Güncelle',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildGenderOption(Gender gender, String label, IconData icon, Color activeColor) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : const Color(0xFF434655),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? activeColor : const Color(0xFF434655),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
