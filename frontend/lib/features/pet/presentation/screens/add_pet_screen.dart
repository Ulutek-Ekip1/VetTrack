import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/validators.dart';
import 'package:vettrack_frontend/l10n/generated/app_localizations.dart';
import '../../domain/entities/pet_entity.dart';
import '../cubit/pet_cubit.dart';
import '../cubit/pet_state.dart';
import '../widgets/pet_profile_photo_bottom_sheet.dart';

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
  bool _ageUnknown = false;
  final _nameFocusNode = FocusNode();
  final _speciesFocusNode = FocusNode();
  final _breedFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  String? _localPhotoUrl;

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

  void _showDiscardModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B), size: 48),
            SizedBox(height: 8),
            Text('Kaydetmeden Çık?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal',
                      style: TextStyle(color: Color(0xFF131B2E))),
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
      final age =
          !_ageUnknown && ageText.isNotEmpty ? int.tryParse(ageText) : null;

      // Tür ve Cinsi birleştirerek kaydediyoruz (örn. "Kedi / Tekir")
      final combinedBreed = species.isNotEmpty
          ? (breed.isNotEmpty ? "$species / $breed" : species)
          : breed;

      context.read<PetCubit>().addPet(
          name: name,
          gender: _selectedGender,
          age: age,
          breed: combinedBreed.isNotEmpty ? combinedBreed : null,
          petPhotoUrl: _localPhotoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);
    const buttonBlue = Color(0xFF2563EB);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(l10n.addPetTitle,
              style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
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
                            // Fotoğrafı buraya koyun, child yerine:
                            image: _localPhotoUrl != null
                                ? DecorationImage(
                                    image: FileImage(File(_localPhotoUrl!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          // Placeholder ikonu:
                          child: _localPhotoUrl == null
                              ? const Icon(Icons.camera_alt,
                                  size: 40, color: Color(0xFF434655))
                              : null,
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                  ),
                                  builder: (context) {
                                    return PetProfilePhotoBottomSheet(
                                      getPhotoUrl: (url) {
                                        setState(() {
                                          if (url == null) {
                                            // Fotoğraf silindi
                                            _localPhotoUrl = null;
                                          } else {
                                            // Yeni fotoğraf eklendi
                                            _localPhotoUrl = url;
                                          }
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.petNameLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: Validators.validatePetName,
                    onFieldSubmitted: (_) {
                      _speciesFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.genderLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderOption(
                          Gender.male, l10n.male, Icons.male, Colors.blue),
                      const SizedBox(width: 8),
                      _buildGenderOption(
                          Gender.female, l10n.female, Icons.female, Colors.pink),
                      const SizedBox(width: 8),
                      _buildGenderOption(Gender.unknown, l10n.unknown,
                          Icons.pets, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: _speciesFocusNode,
                    controller: _speciesController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.speciesLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: Validators.validatePetSpecies,
                    onFieldSubmitted: (_) {
                      _breedFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: _breedFocusNode,
                    controller: _breedController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.breedLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: Validators.validatePetBreed,
                    onFieldSubmitted: (_) {
                      _ageFocusNode.requestFocus();
                    },
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
                            labelText: l10n.ageLabel,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: _ageUnknown
                              ? (_) => null
                              : Validators.validatePetAge,
                          onFieldSubmitted: (value) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
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
                            height:
                                56, // Metin kutusu yüksekliğiyle tam eşleşir
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
                                  l10n.unknown,
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
                        onPressed: isLoading ? null : _onSave,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isLoading ? l10n.saving : l10n.save,
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
