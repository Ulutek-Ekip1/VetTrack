import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onStartVisit() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir hasta erişim kodu girin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    context.push('/vet/visit/active/$code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Veteriner Hekim Paneli'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 1.0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Çıkış Yap',
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.local_hospital_rounded,
                            size: 64, color: Colors.teal),
                        const SizedBox(height: 16),
                        Text(
                          'Hasta Arama & Muayene',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hasta sahibinin mobil uygulamadan paylaştığı erişim kodunu giriniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.4),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _codeController,
                          keyboardType:
                              TextInputType.text, //Harf ve sayi girisi icin
                          textCapitalization: TextCapitalization.characters,
                          //Girilen harfleri otomatik büyük harfe cevirmek icin
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => TextEditingValue(
                                text: newValue.text.toUpperCase(),
                                selection: newValue.selection,
                              ),
                            )
                          ],
                          //Enter tusuna basıldıgında muayene baslatmek icin
                          onSubmitted: (_) => _onStartVisit(),
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Geçici Erişim Kodu',
                            hintText: 'Örn: A8X23J',
                            prefixIcon: Icon(Icons.qr_code_scanner),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _onStartVisit,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'Muayeneyi Başlat',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ));
  }
}
