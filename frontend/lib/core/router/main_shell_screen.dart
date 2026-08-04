import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OwnerShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: const Color(0xFFDBEAFE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: primaryBlue),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets, color: primaryBlue),
            label: 'Hayvanlarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: primaryBlue),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class VetShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const VetShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: Colors.teal.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Colors.teal),
            label: 'Hasta Arama',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Colors.teal),
            label: 'Muayeneler',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Colors.teal),
            label: 'Bildirimler',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services, color: Colors.teal),
            label: 'Klinik Profil',
          ),
        ],
      ),
    );
  }
}
