import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_bottom_sheet.dart';

/// Helper function to display generic image picker bottom sheet.
Future<void> showImagePickerBottomSheet({
  required BuildContext context,
  required void Function(String? path) onPhotoSelected,
  String title = 'Fotoğraf Seç',
  bool showDeleteOption = true,
  double maxFileSizeMB = 15.0,
  List<String> allowedExtensions = const ['.jpg', '.jpeg', '.png', '.webp'],
}) {
  return showAppModalBottomSheet(
    context: context,
    child: ImagePickerBottomSheet(
      title: title,
      onPhotoSelected: onPhotoSelected,
      showDeleteOption: showDeleteOption,
      maxFileSizeMB: maxFileSizeMB,
      allowedExtensions: allowedExtensions,
    ),
  );
}

/// Generic BottomSheet for selecting photos from Camera, Gallery or deleting photo.
class ImagePickerBottomSheet extends StatefulWidget {
  final String title;
  final void Function(String? url) onPhotoSelected;
  final bool showDeleteOption;
  final String cameraTitle;
  final String galleryTitle;
  final double maxFileSizeMB;
  final List<String> allowedExtensions;

  const ImagePickerBottomSheet({
    super.key,
    this.title = 'Fotoğraf Seç',
    required this.onPhotoSelected,
    this.showDeleteOption = true,
    this.cameraTitle = 'Kamera',
    this.galleryTitle = 'Galeri',
    this.maxFileSizeMB = 15.0,
    this.allowedExtensions = const ['.jpg', '.jpeg', '.png', '.webp'],
  });

  @override
  State<ImagePickerBottomSheet> createState() => _ImagePickerBottomSheetState();
}

class _ImagePickerBottomSheetState extends State<ImagePickerBottomSheet> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (!mounted) return;
    if (image == null) return;

    final file = File(image.path);
    final fileSizeInBytes = file.lengthSync();
    final extension = image.path.toLowerCase();

    final maxBytes = widget.maxFileSizeMB * 1024 * 1024;
    final isSizeValid = fileSizeInBytes <= maxBytes;
    final isExtensionValid = widget.allowedExtensions.any((ext) => extension.endsWith(ext));

    if (isSizeValid && isExtensionValid) {
      widget.onPhotoSelected(image.path);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hatalı format veya dosya boyutu çok büyük (Max ${widget.maxFileSizeMB.toStringAsFixed(0)}MB)',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheetContainer(
      title: widget.title,
      trailingAction: widget.showDeleteOption
          ? IconButton(
              onPressed: () {
                widget.onPhotoSelected(null);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
              ),
              tooltip: 'Fotoğrafı Sil',
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kamera
          _ImageSourceOptionTile(
            icon: Icons.camera_alt_outlined,
            title: widget.cameraTitle,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          // Galeri
          _ImageSourceOptionTile(
            icon: Icons.photo_outlined,
            title: widget.galleryTitle,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImageSourceOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 28),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

