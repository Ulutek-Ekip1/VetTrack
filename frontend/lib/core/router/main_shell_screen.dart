import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_dimensions.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

// URL segmentlerini Türkçe isimlere eşlemek için bir sözlük
const Map<String, String> _routeNames = {
  'vet': 'Veteriner Paneli',
  'search': 'Hasta Arama',
  'history': 'Muayene Geçmişi',
  'profile': 'Profilim',
  'visit': 'Muayene',
  'active': 'Aktif Muayene',
  'treatment': 'Tedavi Girişi',
  'recommendation': 'Öneri Girişi',
  'add': 'Ekle',
  'notifications': 'Bildirimler',
};

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
    final theme = Theme.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard, color: theme.colorScheme.primary),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets, color: theme.colorScheme.primary),
            label: 'Hayvanlarım',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
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

  List<Widget> _buildBreadcrumbs(BuildContext context) {
    final theme = Theme.of(context);
    final String location = GoRouterState.of(context).matchedLocation;
    final List<String> segments =
        location.split('/').where((s) => s.isNotEmpty).toList();

    List<Widget> breadcrumbWidgets = [];
    String currentPath = '';

    // İlk başlangıç noktası olarak bir ev/kök simgesi ekleyelim
    breadcrumbWidgets.add(
      IconButton(
        icon: const Icon(Icons.home_outlined, size: 18),
        onPressed: () => context.go('/vet/search'),
        tooltip: 'Veteriner Paneli',
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      currentPath += '/$segment';

      // UUID veya sayısal ID tespiti
      bool isId = segment.length > 8 || int.tryParse(segment) != null;
      final String displayName =
          isId ? 'Detay' : (_routeNames[segment] ?? segment);

      breadcrumbWidgets.add(
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
          child: Icon(Icons.chevron_right,
              size: 16, color: theme.colorScheme.outline),
        ),
      );

      final isLast = i == segments.length - 1;
      breadcrumbWidgets.add(
        InkWell(
          onTap: isLast ? null : () => context.go(currentPath),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXs,
              vertical: AppDimensions.spacingXs / 2,
            ),
            child: Text(
              displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                color: isLast
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return breadcrumbWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width >= 800; // Breakpoint for responsive layout
    final bool isMobile = width < 600; // Mobile view breakpoint

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is Authenticated ? authState.user : null;
        final userName = user?.name ?? 'Klinik Hekimi';
        final userInitial = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'V';

        if (isMobile) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    border: Border(
                      bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sol Taraf: Logo + Breadcrumb
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _buildBreadcrumbs(context),
                          ),
                        ),
                      ),
                      // Sağ Taraf: Hızlı İşlemler + Profil
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notification_add_outlined),
                            onPressed: () => context.push('/notifications'),
                            tooltip: 'Bildirimler',
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            child: Text(
                              userInitial,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sayfanın İçeriği
                Expanded(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: navigationShell,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Hasta Arama',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: 'Muayeneler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services),
                  label: 'Profil',
                ),
              ],
            ),
          );
        }

        // Masaüstü / Tablet geniş ekran yerleşimi
        return Scaffold(
          body: Row(
            children: [
              // Sol Menü (Sidebar) - Sadece Web için tasarlanmış geniş yapı
              NavigationRail(
                extended: isLargeScreen,
                minExtendedWidth: 220,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                backgroundColor: theme.colorScheme.surfaceContainerLowest,
                elevation: 1,
                leading: Column(
                  children: [
                    const SizedBox(height: AppDimensions.spacingLg),
                    if (isLargeScreen) ...[
                      SvgPicture.asset(
                        "assets/icons/VetTrack.svg",
                        width: 130,
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        'Web Klinik Paneli',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      SvgPicture.asset(
                        "assets/icons/VetTrack.svg",
                        width: 32,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.search_outlined, size: 22),
                    selectedIcon: Icon(Icons.search,
                        color: theme.colorScheme.primary, size: 22),
                    label: const Text('Hasta Arama',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.assignment_outlined, size: 22),
                    selectedIcon: Icon(Icons.assignment,
                        color: theme.colorScheme.primary, size: 22),
                    label: const Text('Muayeneler',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline, size: 22),
                    selectedIcon: Icon(Icons.person,
                        color: theme.colorScheme.primary, size: 22),
                    label: const Text('Profilim',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              // Dikey çizgi ayırıcı
              VerticalDivider(
                  width: 1, thickness: 1, color: theme.colorScheme.outlineVariant),

              // Sağ Ana İçerik ve Üst Header Alanı
              Expanded(
                child: Column(
                  children: [
                    // Üst Header Alanı (Breadcrumb + Profil/Bildirim)
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingLg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        border: Border(
                          bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Sol Taraf: Dinamik Breadcrumbs
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _buildBreadcrumbs(context),
                              ),
                            ),
                          ),
                          // Sağ Taraf: Hızlı İşlemler & Profil
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () => context.push('/notifications'),
                                tooltip: 'Bildirimler',
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              InkWell(
                                onTap: () => context.go('/vet/profile'),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXs),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                        child: Text(
                                          userInitial,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isLargeScreen) ...[
                                        const SizedBox(width: AppDimensions.spacingSm),
                                        Text(
                                          userName,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Sayfanın Kendi İçeriği
                    Expanded(
                      child: Container(
                        color: theme.scaffoldBackgroundColor,
                        child: navigationShell,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
