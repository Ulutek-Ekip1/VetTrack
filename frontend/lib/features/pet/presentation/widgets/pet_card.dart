import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: widget.pet.uniqueCode,
                  version: QrVersions.auto,
                  size: 180.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Eşsiz Kimlik Kodu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.tertiary,
                    width: 1.5,
                  ),
                ),
                child: SelectableText(
                  widget.pet.uniqueCode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onTertiaryContainer,
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
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
    final hasPhoto =
        widget.pet.photoUrl != null && widget.pet.photoUrl!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.diagonal3Values(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            color: theme.colorScheme.surfaceContainerHighest,
            image: hasPhoto
                ? DecorationImage(
                    image: NetworkImage(widget.pet.photoUrl!),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                : null,
            gradient: !hasPhoto
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Hero Tag için görünmez katman
              Hero(
                tag: 'pet-photo-${widget.pet.id}',
                child: const SizedBox.expand(),
              ),

              // Resim yoksa ortada büyük pet simgesi
              if (!hasPhoto)
                Center(
                  child: Icon(
                    Icons.pets,
                    size: 72,
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.35),
                  ),
                ),

              // Metinlerin Okunabilirliği İçin Koyu Gradyan Maskesi (Overlay)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // --- ÜST SAĞ: CİNSİYET & KOD ROZETLERİ ---
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Eşsiz Kod Rozeti
                    if (widget.pet.uniqueCode.isNotEmpty)
                      InkWell(
                        onTap: () => _showUniqueCodeDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.pet.uniqueCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(),

                    // Cinsiyet Rozeti
                    if (widget.pet.gender != Gender.unknown)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (widget.pet.gender == Gender.male
                                  ? const Color(0xFF1E88E5)
                                  : const Color(0xFFE91E63))
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.pet.gender == Gender.male
                                  ? Icons.male_rounded
                                  : Icons.female_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.pet.gender == Gender.male
                                  ? 'Erkek'
                                  : 'Dişi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // --- ALT BİLGİ ALANI ---
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Sol Taraf: İsim, Irk ve Çipler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Evcil Hayvan Adı
                          Text(
                            widget.pet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Irk (Breed)
                          if (widget.pet.breed != null &&
                              widget.pet.breed!.isNotEmpty)
                            Text(
                              widget.pet.breed!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),

                          // Çipler (Yaş, Kilo, Kısırlaştırma)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (widget.pet.age != null)
                                _buildGlassChip(
                                  icon: Icons.cake_outlined,
                                  label: '${widget.pet.age} Yaş',
                                ),
                              if (widget.pet.weight != null)
                                _buildGlassChip(
                                  icon: Icons.scale_outlined,
                                  label: '${widget.pet.weight} kg',
                                ),
                              if (widget.pet.isSpayedOrNeutered == true)
                                _buildGlassChip(
                                  icon: Icons.health_and_safety_outlined,
                                  label: 'Kısır',
                                  color: Colors.tealAccent,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sağ Taraf: Detaylar Butonu
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detaylar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dokunma (Ripple) Efekti
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push('/owner/pets/${widget.pet.id}');
                    },
                    splashColor: Colors.white.withValues(alpha: 0.15),
                    highlightColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipTextColor = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

