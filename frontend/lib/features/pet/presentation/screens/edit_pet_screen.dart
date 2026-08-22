import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/widgets/image_picker_bottom_sheet.dart';
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
  String? _localPhotoUrl;
  bool isDeleted = false;

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
              _speciesController.text = pet.breed!;
              _breedController.text = '';
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
      final age =
          !_ageUnknown && ageText.isNotEmpty ? int.tryParse(ageText) : null;

      final combinedBreed = species.isNotEmpty
          ? (breed.isNotEmpty ? "$species / $breed" : species)
          : breed;

      context.read<PetCubit>().updatePet(
          id: widget.petId,
          name: name,
          gender: _selectedGender,
          age: age,
          breed: combinedBreed.isNotEmpty ? combinedBreed : null,
          photoPath: _localPhotoUrl,
          removePhoto: isDeleted);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 48),
            SizedBox(height: 8),
            Text('Evcil Hayvanı Sil?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('İptal',
                      style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
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
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;
    final buttonBlue = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dostu Düzenle',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
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
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is PetActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
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
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: _localPhotoUrl != null &&
                                  _localPhotoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(_localPhotoUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : _photoUrl != null && _photoUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_photoUrl!),
                                      fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_localPhotoUrl == null ||
                                    _localPhotoUrl!.isEmpty) &&
                                (_photoUrl == null || _photoUrl!.isEmpty)
                            ? Center(
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 48,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () {
                            showImagePickerBottomSheet(
                              context: context,
                              title: 'Dost resmi',
                              onPhotoSelected: (url) {
                                setState(() {
                                  if (url == null) {
                                    isDeleted = true;
                                    _localPhotoUrl = _photoUrl = null;
                                  } else {
                                    _localPhotoUrl = url;
                                    isDeleted = false;
                                  }
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Lütfen bir ad girin'
                      : null,
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
                    _buildGenderOption(
                        Gender.male, 'Erkek', Icons.male, Colors.blue),
                    const SizedBox(width: 8),
                    _buildGenderOption(
                        Gender.female, 'Dişi', Icons.female, Colors.pink),
                    const SizedBox(width: 8),
                    _buildGenderOption(
                        Gender.unknown, 'Bilinmiyor', Icons.pets, Colors.teal),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _speciesFocusNode,
                  controller: _speciesController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Türü * (örn. Kedi, Köpek)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Lütfen hayvan türünü girin'
                      : null,
                  onFieldSubmitted: (_) => _breedFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _breedFocusNode,
                  controller: _breedController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Cinsi / Irkı (örn. Tekir, Golden)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                        onFieldSubmitted: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
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
                                ? primaryBlue.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _ageUnknown
                                  ? primaryBlue
                                  : Colors.grey.shade400,
                              width: _ageUnknown ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _ageUnknown
                                    ? Icons.check_circle
                                    : Icons.help_outline,
                                color: _ageUnknown
                                    ? primaryBlue
                                    : const Color(0xFF434655),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bilinmiyor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _ageUnknown
                                      ? primaryBlue
                                      : const Color(0xFF434655),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: isLoading ? null : _onUpdate,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.update),
                      label: Text(
                        isLoading ? 'Güncelleniyor...' : 'Güncelle',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildGenderOption(
      Gender gender, String label, IconData icon, Color activeColor) {
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
            color: isSelected
                ? activeColor.withValues(alpha: 0.08)
                : Colors.transparent,
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
