import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/main_screen/pet_detail_screen/profile_screen.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void changeTab(int index) => emit(index);
}

class NeoScreen extends StatelessWidget {
  const NeoScreen({super.key});

  final _items = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.pets_outlined),
      label: 'Hayvanlarım',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.event_note_outlined),
      label: 'Randevularım',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Profilim',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state,
              children: const [
                Center(child: Text('Home Screen')),
                Center(child: Text('Search Screen')),
                PetDetailScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state,
              onTap: (index) =>
                  context.read<NavigationCubit>().changeTab(index),
              items: _items,
            ),
          );
        },
      ),
    );
  }
}
