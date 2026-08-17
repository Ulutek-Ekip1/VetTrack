import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/core/utils/validators.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _resultFocusNode = FocusNode();
  final _activeVisitActionFocusNode = FocusNode();
  VisitSearchResult? _searchResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    _resultFocusNode.dispose();
    _activeVisitActionFocusNode.dispose();
    super.dispose();
  }

  void _searchPatient() {
    final code = _codeController.text.trim();
    final validationMessage = Validators.validateUniqueCode(code);
    if (validationMessage != null) {
      _showMessage(validationMessage, isError: true);
      return;
    }
    context.read<VisitCubit>().searchByCode(code);
  }

  void _startVisit() {
    final result = _searchResult;
    if (result == null) return;
    context.read<VisitCubit>().startVisit(result.result.pet.id);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.teal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitCubit, VisitState>(
      listener: (context, state) {
        if (state is VisitSearchResult) {
          setState(() => _searchResult = state);
          final activeVisit = state.result.activeVisit;
          if (activeVisit != null) {
            _showMessage(
              'Bu hasta için açık bir muayene bulundu. Devam etmek için aşağıdaki aksiyonu kullanın.',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _activeVisitActionFocusNode.requestFocus();
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _resultFocusNode.requestFocus();
            });
          }
        } else if (state is VisitStarted) {
          context.push('/vet/visit/active/${state.visit.id}');
        } else if (state is VisitError) {
          setState(() => _searchResult = null);
          _showMessage(state.message, isError: true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _codeFocusNode.requestFocus();
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is VisitLoading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Veteriner Hekim Paneli'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
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
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.local_hospital_rounded, size: 64, color: Colors.teal),
                        const SizedBox(height: 16),
                        Text('Hasta Arama & Muayene',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text('Hasta sahibinin paylaştığı erişim kodunu giriniz.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            LengthLimitingTextInputFormatter(6),
                            TextInputFormatter.withFunction((oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(), selection: newValue.selection)),
                          ],
                          onSubmitted: (_) => _searchPatient(),
                          enabled: !isLoading,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Geçici Erişim Kodu', hintText: 'Örn: A8X23J',
                            prefixIcon: Icon(Icons.qr_code_scanner), border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _searchPatient,
                          icon: isLoading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                          label: const Text('Hastayı Ara'),
                        ),
                        if (_searchResult != null && _searchResult!.result.activeVisit != null) ...[
                          const Divider(height: 36),
                          Semantics(
                              liveRegion: true,
                              label: 'Bu hasta için açık bir muayene var',
                              child: Card(
                                color: Colors.amber.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.amber.shade900,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Açık muayene bulundu',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Yeni muayene başlatılamaz. Devam eden muayeneyi açarak işlemlere devam edin.',
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        focusNode: _activeVisitActionFocusNode,
                                        onPressed: isLoading
                                            ? null
                                            : () => context.push(
                                                  '/vet/visit/active/${_searchResult!.result.activeVisit!.id}',
                                                ),
                                        icon: const Icon(Icons.open_in_new),
                                        label: const Text('Açık Muayeneye Git'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                        ],
                        if (_searchResult != null && _searchResult!.result.activeVisit == null) ...[
                          const Divider(height: 36),
                          Focus(
                            focusNode: _resultFocusNode,
                            child: Semantics(
                              liveRegion: true,
                              label: '${_searchResult!.result.pet.name} bulundu. ${_searchResult!.result.visits.length} geçmiş ziyaret kaydı var.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _searchResult!.result.pet.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text('${_searchResult!.result.visits.length} geçmiş ziyaret bulundu.'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _startVisit,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Yeni Muayeneyi Başlat'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
