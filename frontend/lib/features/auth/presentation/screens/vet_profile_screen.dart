import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/theme/cubit/theme_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class VetProfileScreen extends StatelessWidget {
  const VetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veteriner Hekim Profili'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          final userName = user?.name ?? 'Klinik Hekimi';
          final userEmail = user?.email ?? 'E-posta belirtilmemiş';

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Icon(
                              Icons.local_hospital,
                              size: 40,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: BlocBuilder<ThemeCubit, ThemeMode>(
                              builder: (context, themeMode) {
                                String themeSubtitle;
                                switch (themeMode) {
                                  case ThemeMode.light:
                                    themeSubtitle = 'Açık Tema';
                                    break;
                                  case ThemeMode.dark:
                                    themeSubtitle = 'Koyu Tema';
                                    break;
                                  case ThemeMode.system:
                                    themeSubtitle = 'Sistem Teması (Otomatik)';
                                    break;
                                }
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.palette_outlined,
                                        color: theme.colorScheme.primary,
                                        size: 20),
                                  ),
                                  title: Text(
                                    'Uygulama Teması',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    themeSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _showThemeSelectionDialog(
                                      context, themeMode),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(
                              height:
                                  24), // Spacer sıkıştığında minimum dikey boşluk
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthCubit>().signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                              foregroundColor:
                                  theme.colorScheme.onErrorContainer,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Çıkış Yap'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, ThemeMode currentMode) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Uygulama Teması Seçin'),
          content: RadioGroup<ThemeMode>(
            groupValue: currentMode,
            onChanged: (val) {
              if (val != null) {
                Navigator.pop(dialogContext);
                context.read<ThemeCubit>().setThemeMode(val);
              }
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('Açık Tema'),
                  subtitle: Text('Gündüz kullanımı için aydınlık görünüm'),
                  secondary: Icon(Icons.light_mode_outlined),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Koyu Tema'),
                  subtitle: Text('Gece kullanımı için koyu zemin'),
                  secondary: Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Sistem Teması'),
                  subtitle: Text('Cihaz ayarlarınıza göre otomatik'),
                  secondary: Icon(Icons.brightness_auto_outlined),
                  value: ThemeMode.system,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
