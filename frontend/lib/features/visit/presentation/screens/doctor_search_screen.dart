import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  VisitSearchResult? _searchResult;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _searchPatient() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showMessage('Lütfen geçerli bir hasta erişim kodu girin.', isError: true);
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
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
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
                        if (_searchResult != null && _searchResult!.result.activeVisit == null) ...[
                          const Divider(height: 36),
                          Text(_searchResult!.result.pet.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text('${_searchResult!.result.visits.length} geçmiş ziyaret bulundu.'),
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
