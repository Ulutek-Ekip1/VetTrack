import 'dart:async';
import 'package:flutter/material.dart';

class TopNotificationData {
  final String title;
  final String body;
  final String type;
  final VoidCallback? onTap;

  TopNotificationData(
      {required this.title,
      required this.body,
      this.type = 'SYSTEM',
      this.onTap});
}

final ValueNotifier<TopNotificationData?> topNotificationNotifier =
    ValueNotifier(null);
Timer? _hideTimer;

class TopNotification extends StatefulWidget {
  const TopNotification(
      {super.key,
      required this.title,
      required this.body,
      this.type = 'SYSTEM',
      this.onTap});
  final String title;
  final String body;
  final String type;
  final VoidCallback? onTap;

  static void show(
      {required String title,
      required String body,
      String type = 'SYSTEM',
      VoidCallback? onTap}) {
    _hideTimer?.cancel();
    topNotificationNotifier.value =
        TopNotificationData(title: title, body: body, type: type, onTap: onTap);
    _hideTimer = Timer(const Duration(seconds: 4), () {
      topNotificationNotifier.value = null;
      debugPrint("TopNotification overlay silindi.");
    });
  }

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _offset =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getNotificationWidget() {
    switch (widget.type.toUpperCase()) {
      case 'RECOMMENDATION':
        return Recommendation(widget: widget);
      case 'VACCINE':
        return Vaccine(widget: widget);
      case 'TREATMENT':
        return Treatment(widget: widget);
      case 'VISIT':
        return Visit(widget: widget);
      case 'SYSTEM':
      default:
        return System(widget: widget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: GestureDetector(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
            _hideTimer?.cancel();
            topNotificationNotifier.value = null;
          },
          child: _getNotificationWidget(),
        ),
      ),
    );
  }
}

class Recommendation extends StatelessWidget {
  const Recommendation({
    super.key,
    required this.widget,
  });

  final TopNotification widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFA06AEF),
              ),
            ),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFA06AEF),
                      Color(0xFF9460E9),
                      Color(0xFF8A56E3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  _hideTimer?.cancel();
                  topNotificationNotifier.value = null;
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  Colors.black.withValues(alpha: 0.08),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Vaccine extends StatelessWidget {
  const Vaccine({
    super.key,
    required this.widget,
  });

  final TopNotification widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Bildirim arka planı
        color: const Color(0xFFF0FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol accent çizgisi
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF28B3B0),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 64,
                width: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  // İkon kutusu
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3BBDB7),
                      Color(0xFF3FC1BA),
                    ],
                  ),

                  // Hafif turkuaz glow
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3CBFB8).withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.vaccines_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF075B6B),
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  _hideTimer?.cancel();
                  topNotificationNotifier.value = null;
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  const Color(0xFF22A4A4).withValues(alpha: 0.10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Color(0xFF22A4A4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Treatment extends StatelessWidget {
  const Treatment({
    super.key,
    required this.widget,
  });

  final TopNotification widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Açık yeşil background
        color: const Color(0xFFF6FAF3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol yeşil accent
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF69B451),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  // İkon kutusu
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8BC776),
                      Color(0xFF7FBA69),
                    ],
                  ),

                  // Hafif yeşil glow
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF86C170).withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.healing_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF397A2F),
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  _hideTimer?.cancel();
                  topNotificationNotifier.value = null;
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  const Color(0xFF6EAF59).withValues(alpha: 0.10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Color(0xFF6EAF59),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class System extends StatelessWidget {
  const System({
    super.key,
    required this.widget,
  });

  final TopNotification widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Açık mavi background
        color: const Color(0xFFF1F7FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol accent çizgisi
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF2689E8),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  // İkon kutusu
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3B94E5),
                      Color(0xFF2E82D5),
                    ],
                  ),

                  // Hafif mavi glow
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF348DDE).withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF14539A),
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  _hideTimer?.cancel();
                  topNotificationNotifier.value = null;
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  const Color(0xFF2784D8).withValues(alpha: 0.10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Color(0xFF2784D8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Visit extends StatelessWidget {
  const Visit({
    super.key,
    required this.widget,
  });

  final TopNotification widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol accent çizgisi
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFF0A43C),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  // İkon kutusu
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF6BA5B),
                      Color(0xFFEFA33A),
                    ],
                  ),

                  // Hafif turuncu glow
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF0A43C).withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF9A5B08),
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  _hideTimer?.cancel();
                  topNotificationNotifier.value = null;
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  const Color(0xFFE49A32).withValues(alpha: 0.10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Color(0xFFE49A32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
