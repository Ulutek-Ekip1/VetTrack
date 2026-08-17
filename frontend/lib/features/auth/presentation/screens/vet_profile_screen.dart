import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';

class VetProfileScreen extends StatelessWidget {
  const VetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vetProfileTitle),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal,
              child: Icon(Icons.local_hospital, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dr. Mehmet Yılmaz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(l10n.vetSpecialist, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
