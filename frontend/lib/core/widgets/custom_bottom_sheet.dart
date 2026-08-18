import 'package:flutter/material.dart';

/// App-wide helper for displaying standard modal bottom sheets.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
  Color backgroundColor = Colors.white,
  double borderRadius = 28.0,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(borderRadius),
      ),
    ),
    builder: (context) => child,
  );
}

/// Generic container widget with drag handle, standard header and title layout.
class CustomBottomSheetContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final Widget? trailingAction;
  final bool showHandleBar;
  final EdgeInsetsGeometry padding;

  const CustomBottomSheetContainer({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.trailingAction,
    this.showHandleBar = true,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHandleBar) ...[
              Center(
                child: Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Header row
            Row(
              children: [
                IconButton(
                  onPressed: onClose ?? () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF131B2E),
                  ),
                  tooltip: 'Kapat',
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF131B2E),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailingAction != null)
                  trailingAction!
                else
                  const SizedBox(width: 48), // Spacer to balance close button
              ],
            ),

            const SizedBox(height: 16),

            // Content
            child,
          ],
        ),
      ),
    );
  }
}
