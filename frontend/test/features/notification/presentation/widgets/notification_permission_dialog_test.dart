import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/features/notification/presentation/widgets/notification_permission_dialog.dart';

void main() {
  testWidgets('NotificationPermissionDialog renders all UI elements properly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotificationPermissionDialog(),
        ),
      ),
    );

    expect(find.text('Bildirimleri Açın'), findsOneWidget);
    expect(find.text('Ayarlara Git'), findsOneWidget);
    expect(find.text('Daha Sonra'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    expect(find.text('Zamanlanmış tedavi ve aşı hatırlatmaları'), findsOneWidget);
    expect(find.text('Muayene sonucu ve hekim önerisi güncellemeleri'), findsOneWidget);
    expect(find.text('Acil durum ve klinik bilgilendirmeleri'), findsOneWidget);
  });

  testWidgets('Clicking close (X) button calls onDismissed and pops dialog', (tester) async {
    bool dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => NotificationPermissionDialog(
                      onDismissed: () => dismissed = true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirimleri Açın'), findsOneWidget);

    final closeButton = find.byIcon(Icons.close_rounded);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.text('Bildirimleri Açın'), findsNothing);
    expect(dismissed, isTrue);
  });

  testWidgets('Clicking "Daha Sonra" button calls onDismissed and pops dialog', (tester) async {
    bool dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => NotificationPermissionDialog(
                      onDismissed: () => dismissed = true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirimleri Açın'), findsOneWidget);

    final laterButton = find.text('Daha Sonra');
    await tester.tap(laterButton);
    await tester.pumpAndSettle();

    expect(find.text('Bildirimleri Açın'), findsNothing);
    expect(dismissed, isTrue);
  });

  testWidgets('Clicking "Ayarlara Git" button invokes onSettingsPressed callback', (tester) async {
    bool settingsPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => NotificationPermissionDialog(
                      onSettingsPressed: () => settingsPressed = true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirimleri Açın'), findsOneWidget);

    final settingsButton = find.text('Ayarlara Git');
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(settingsPressed, isTrue);
    expect(find.text('Bildirimleri Açın'), findsNothing);
  });
}
