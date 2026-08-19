import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  PatientSearchResult? _searchResult;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _searchPatient() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMessage('Lütfen geçerli bir hasta erişim kodu girin.', isError: true);
      _focusNode.requestFocus();
      return;
    }

    if (code.length != 6) {
      _showMessage('Hasta erişim kodu 6 haneli olmalıdır (Örn: A8X23J).', isError: true);
      _focusNode.requestFocus();
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final clinicId = authState.user.clinicId ?? '';
      context.read<VisitCubit>().searchByCode(code, clinicId);
    } else {
      _showMessage('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.', isError: true);
    }
  }

  void _startVisit() {
    final visitState = context.read<VisitCubit>().state;
    final result = visitState is VisitSearchResult ? visitState.result : _searchResult;
    if (result == null) return;
    context.read<VisitCubit>().startVisit(result.pet.id);
  }

  void _showMessage(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<VisitCubit, VisitState>(
      listener: (context, state) {
        if (state is VisitSearchResult) {
          setState(() => _searchResult = state.result);
          final activeVisit = state.result.activeVisit;
          if (activeVisit != null) {
            _showMessage('Bu hasta için açık bir muayene bulundu.');
            context.push('/vet/visit/active/${activeVisit.id}');
          }
        } else if (state is VisitStarted) {
          context.push('/vet/visit/active/${state.visit.id}');
        } else if (state is VisitError) {
          setState(() => _searchResult = null);
          _showMessage(state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is VisitLoading;
        final currentResult = state is VisitSearchResult ? state.result : _searchResult;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hasta Kabul & Arama'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Çıkış Yap',
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arama Kartı
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 32,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hasta Erişim Kodu',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hasta sahibinin mobil uygulamasından paylaştığı 6 haneli geçici kodu giriniz.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Kod Giriş Alanı
                            TextField(
                              controller: _codeController,
                              focusNode: _focusNode,
                              autofocus: true,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.search,
                              maxLength: 6,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6.0,
                                color: theme.colorScheme.primary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                                TextInputFormatter.withFunction(
                                  (oldValue, newValue) => TextEditingValue(
                                    text: newValue.text.toUpperCase(),
                                    selection: newValue.selection,
                                  ),
                                ),
                              ],
                              onSubmitted: (_) => _searchPatient(),
                              enabled: !isLoading,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Örn: A8X23J',
                                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.outline,
                                  letterSpacing: 2.0,
                                ),
                                counterText: '',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixIcon: _codeController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        tooltip: 'Temizle',
                                        onPressed: () {
                                          _codeController.clear();
                                          setState(() => _searchResult = null);
                                          _focusNode.requestFocus();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Arama Butonu
                            ElevatedButton.icon(
                              onPressed: isLoading ? null : _searchPatient,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: isLoading
                                  ? SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.search_rounded),
                              label: Text(
                                isLoading ? 'Hasta Aranıyor...' : 'Hastayı Bul & Getir',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Arama Sonucu ve Hasta Künyesi Kartı
                    if (currentResult != null) ...[
                      const SizedBox(height: 20),
                      _buildPatientSummaryCard(context, currentResult, isLoading),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientSummaryCard(
    BuildContext context,
    PatientSearchResult searchResult,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final pet = searchResult.pet;
    final activeVisit = searchResult.activeVisit;
    final hasActiveVisit = activeVisit != null;

    final genderText = pet.gender.name.toLowerCase() == 'female' ? 'Dişi' : 'Erkek';
    final ageText = pet.age != null ? '${pet.age} Yaşında' : 'Yaş bilinmiyor';
    final weightText = pet.weight != null ? '${pet.weight} kg' : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: hasActiveVisit
              ? theme.colorScheme.tertiary.withValues(alpha: 0.6)
              : theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Bilgi: Fotoğraf & Temel Künye
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                      ? NetworkImage(pet.photoUrl!)
                      : null,
                  child: pet.photoUrl == null || pet.photoUrl!.isEmpty
                      ? Icon(
                          Icons.pets_rounded,
                          size: 34,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              pet.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pet.uniqueCode,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.breed ?? "Irk / Tür Belirtilmemiş",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$genderText • $ageText${weightText != null ? " • $weightText" : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Alerji veya Kronik Rahatsızlık Rozetleri
            if ((pet.allergies != null && pet.allergies!.isNotEmpty) ||
                (pet.chronicIllnesses != null && pet.chronicIllnesses!.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (pet.allergies != null && pet.allergies!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      label: Text('Alerji: ${pet.allergies}'),
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                  if (pet.chronicIllnesses != null && pet.chronicIllnesses!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.medical_information_outlined, size: 16, color: Colors.redAccent),
                      label: Text('Kronik: ${pet.chronicIllnesses}'),
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                ],
              ),
            ],

            const Divider(height: 32),

            // Muayene Durum Kartı & Aksiyon Butonları
            if (hasActiveVisit) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      color: theme.colorScheme.onTertiaryContainer,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Devam Eden Aktif Muayene Var',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Başlangıç: ${activeVisit.startedAt.toFormattedDateTime()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/vet/visit/active/${activeVisit.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Aktif Muayeneye Git', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${searchResult.visits.length} geçmiş muayene kaydı bulundu.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: isLoading ? null : _startVisit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Yeni Muayene Başlat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
