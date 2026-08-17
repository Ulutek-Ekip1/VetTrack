import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/router/notification_navigation.dart';

void main() {
  group('NotificationNavigation', () {
    test('maps each notification type to its related pet screen', () {
      expect(
        NotificationNavigation.destinationFor(type: 'TREATMENT', petId: 'pet-1'),
        '/owner/pets/pet-1/treatments',
      );
      expect(
        NotificationNavigation.destinationFor(
          type: 'RECOMMENDATION',
          petId: 'pet-1',
        ),
        '/owner/pets/pet-1/recommendations',
      );
      expect(
        NotificationNavigation.destinationFor(type: 'VISIT', petId: 'pet-1'),
        '/owner/pets/pet-1/visits',
      );
    });

    test('uses the pet profile for generic notifications and ignores missing pets', () {
      expect(
        NotificationNavigation.destinationFor(type: 'SYSTEM', petId: 'pet-1'),
        '/owner/pets/pet-1',
      );
      expect(
        NotificationNavigation.destinationFor(type: 'VISIT'),
        isNull,
      );
    });
  });
}
