import 'package:flutter/material.dart';
import '../../../../core/widgets/image_picker_bottom_sheet.dart';

/// Legacy wrapper for pet profile photo selection.
/// Delegated to generic [ImagePickerBottomSheet].
class PetProfilePhotoBottomSheet extends StatelessWidget {
  const PetProfilePhotoBottomSheet({
    super.key,
    required this.getPhotoUrl,
    this.title = 'Dost resmi',
  });

  final void Function(String? url) getPhotoUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ImagePickerBottomSheet(
      title: title,
      onPhotoSelected: getPhotoUrl,
    );
  }
}
