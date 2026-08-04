import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_cubit.dart';

class PetCard extends StatelessWidget {
  final PetEntity pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Evcil Hayvanı Sil'),
        content: Text('${pet.name} isimli evcil hayvanı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PetCubit>().deletePet(id: pet.id);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showUniqueCodeDialog(BuildContext context) {
    final theme = Theme.of(context);
    const peachBg = Color(0xFFFFECE5);
    const peachAccent = Color(0xFFFFB89C);
    const peachText = Color(0xFFD9531E);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pet.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Eşsiz Kimlik Kodu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: peachBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: peachAccent,
                    width: 1.5,
                  ),
                ),
                child: SelectableText(
                  pet.uniqueCode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: peachText,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kapat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pet.uniqueCode));
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('${pet.name} kodu panoya kopyalandı!'),
                              ],
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: peachText,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Kodu Kopyala'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const peachBg = Color(0xFFFFECE5);
    const peachBorder = Color(0xFFFFB89C);
    const peachText = Color(0xFFD9531E);
    const primaryBlue = Color(0xFF004AC6);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          context.push('/owner/pets/${pet.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                        ? NetworkImage(pet.photoUrl!)
                        : null,
                    child: pet.photoUrl == null || pet.photoUrl!.isEmpty
                        ? Icon(
                            Icons.pets,
                            size: 28,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      pet.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF131B2E),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/owner/pets/${pet.id}/edit');
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sil',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (pet.uniqueCode.isNotEmpty) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showUniqueCodeDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: peachBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: peachBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag_rounded,
                              size: 16,
                              color: peachText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pet.uniqueCode,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: peachText,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.open_in_full,
                              size: 14,
                              color: peachText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/owner/pets/${pet.id}');
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16, color: primaryBlue),
                      label: const Text(
                        'Detaylar',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
