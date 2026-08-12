import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'photo_options.dart';

class PetProfilePhotoBottomSheet extends StatefulWidget {
  const PetProfilePhotoBottomSheet({super.key, required this.getPhotoUrl});
  final void Function(String? url) getPhotoUrl;

  @override
  State<PetProfilePhotoBottomSheet> createState() =>
      _PetProfilePhotoBottomSheetState();
}

class _PetProfilePhotoBottomSheetState
    extends State<PetProfilePhotoBottomSheet> {
  final _image = ImagePicker();

  Future<void> _getPhotoFromGallery() async {
    final XFile? image = await _image.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (image == null) return;

    final file = File(image.path);
    final fileSizeInBytes = file.lengthSync();
    final extension = image.path.toLowerCase();

    final isSizeValid = fileSizeInBytes <= (15 * 1024 * 1024);
    final isExtensionValid = extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.webp');

    if (isSizeValid && isExtensionValid) {
      widget.getPhotoUrl(image.path);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatalı format veya dosya boyutu çok büyük (Max 15MB)'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _getPhotoFromCamera() async {
    final XFile? image = await _image.pickImage(source: ImageSource.camera);

    if (!mounted) return;

    if (image == null) return;

    final file = File(image.path);
    final fileSizeInBytes = file.lengthSync();
    final extension = image.path.toLowerCase();

    final isSizeValid = fileSizeInBytes <= (15 * 1024 * 1024);
    final isExtensionValid = extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.webp');

    if (isSizeValid && isExtensionValid) {
      widget.getPhotoUrl(image.path);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatalı format veya dosya boyutu çok büyük (Max 15MB)'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Dost resmi',
                      style: TextStyle(
                        color: Color(0xFF131B2E),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.getPhotoUrl(null);
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Kamera
            PhotoOption(
              icon: Icons.camera_alt_outlined,
              title: 'Kamera',
              onTap: () {
                _getPhotoFromCamera();
              },
            ),

            // Galeri
            PhotoOption(
              icon: Icons.photo_outlined,
              title: 'Galeri',
              onTap: () {
                _getPhotoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
