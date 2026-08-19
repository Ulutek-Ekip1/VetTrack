import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/owner_entity.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../cubit/auth_cubit.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isInitialized = false;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    context.read<ProfileCubit>().fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeFields(OwnerEntity profile) {
    if (!_isInitialized) {
      _nameController.text = profile.name;
      _surnameController.text = profile.surname ?? '';
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
      _isInitialized = true;
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileCubit>().updateProfile(
            name: _nameController.text.trim(),
            surname: _surnameController.text.trim().isEmpty
                ? null
                : _surnameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        title: Text(
          'Kişisel Bilgiler',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            context.read<AuthCubit>().checkAuthStatus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profiliniz başarıyla güncellendi!'),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _isEditable = false;
            });
            context.pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            );
          }

          OwnerEntity? profile;
          if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileUpdating) {
            profile = state.currentProfile;
          }

          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profil bilgileri yüklenemedi.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().fetchProfile(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          _initializeFields(profile);
          final isSaving = state is ProfileUpdating;

          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    color: theme.colorScheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Kişisel Bilgiler",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEditable
                                  ? "Aşağıdaki alanları güncelleyerek profilinizi güncel tutabilirsiniz."
                                  : "Kişisel profil bilgilerinizi aşağıdan inceleyebilirsiniz. Değişiklik yapmak için aşağıdaki 'Bilgileri Düzenle' butonuna tıklayın.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Ad TextFormField
                            TextFormField(
                              controller: _nameController,
                              enabled: _isEditable,
                              style: theme.textTheme.bodyLarge,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: "Ad",
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: theme.colorScheme.outline,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: Validators.validateFirstName,
                            ),

                            const SizedBox(height: 16),

                            // Soyad TextFormField
                            TextFormField(
                              controller: _surnameController,
                              enabled: _isEditable,
                              style: theme.textTheme.bodyLarge,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: "Soyad",
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: theme.colorScheme.outline,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: Validators.validateSurname,
                            ),

                            const SizedBox(height: 16),

                            // E-posta (Read-Only)
                            TextFormField(
                              controller: _emailController,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: "E-posta Adresi (Değiştirilemez)",
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: theme.colorScheme.outlineVariant,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Telefon TextFormField
                            TextFormField(
                              controller: _phoneController,
                              enabled: _isEditable,
                              keyboardType: TextInputType.phone,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: "Telefon Numarası",
                                hintText: "05XX XXX XX XX",
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: theme.colorScheme.outline,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: Validators.validatePhone,
                            ),

                            const SizedBox(height: 16),

                            // Adres TextFormField
                            TextFormField(
                              controller: _addressController,
                              enabled: _isEditable,
                              maxLines: 3,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: "Adres",
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: theme.colorScheme.outline,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Düzenleme / Kaydet Butonu
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : (!_isEditable
                                        ? () {
                                            setState(() {
                                              _isEditable = true;
                                            });
                                          }
                                        : _onSave),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isSaving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isEditable
                                                ? 'Değişiklikleri Kaydet'
                                                : 'Bilgileri Düzenle',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            _isEditable
                                                ? Icons.save_outlined
                                                : Icons.edit_outlined,
                                            size: 20,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


