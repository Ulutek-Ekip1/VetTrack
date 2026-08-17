import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vettrack_frontend/l10n/generated/app_localizations.dart';

class PetCard extends StatefulWidget {
  final PetEntity pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  double _scale = 1.0;



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
                widget.pet.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: widget.pet.uniqueCode, version: QrVersions.auto,
                  size: 180.0, // QR kodun büyüklüğü
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Eşsiz Kimlik Kodu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: peachBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: peachAccent,
                    width: 1.5,
                  ),
                ),
                child: SelectableText(
                  widget.pet.uniqueCode,
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
                        Clipboard.setData(ClipboardData(text: widget.pet.uniqueCode));
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('${widget.pet.name} kodu panoya kopyalandı!'),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const peachBg = Color(0xFFFFECE5);
    const peachBorder = Color(0xFFFFB89C);
    const peachText = Color(0xFFD9531E);

    return Semantics(
      button: true,
      label: l10n.openPetProfile(widget.pet.name),
      child: GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.diagonal3Values(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () {
              context.push('/owner/pets/${widget.pet.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'pet-photo-${widget.pet.id}',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.pet.photoUrl != null && widget.pet.photoUrl!.isNotEmpty
                              ? Image.network(
                                  widget.pet.photoUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: theme.colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.pets,
                                      size: 28,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.pets,
                                    size: 28,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.pet.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF131B2E),
                          ),
                        ),
                      ),

                    ],
                  ),
                  if (widget.pet.uniqueCode.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _showUniqueCodeDialog(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                  widget.pet.uniqueCode,
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
                            context.push('/owner/pets/${widget.pet.id}');
                          },
                          icon: Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                          label: Text(
                            'Detaylar',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
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
        ),
      ),
      ),
    );
  }
}
