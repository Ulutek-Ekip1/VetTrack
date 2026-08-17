import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/utils/validators.dart';

void main() {
  group('Validators.validateUniqueCode', () {
    test('accepts a six-character alphanumeric code', () {
      expect(Validators.validateUniqueCode('a8x23j'), isNull);
    });

    test('rejects a code with an invalid length or character', () {
      expect(Validators.validateUniqueCode('A8X23'), isNotNull);
      expect(Validators.validateUniqueCode('A8X-3J'), isNotNull);
    });
  });

  group('pet validators', () {
    test('requires a pet name and species', () {
      expect(Validators.validatePetName('  '), isNotNull);
      expect(Validators.validatePetSpecies('Kedi'), isNull);
    });

    test('validates age and image upload constraints', () {
      expect(Validators.validatePetAge('31'), isNotNull);
      expect(Validators.validatePetAge('12'), isNull);
      expect(
        Validators.validatePetPhoto(
          fileName: 'pet.gif',
          sizeInBytes: 1024,
        ),
        isNotNull,
      );
      expect(
        Validators.validatePetPhoto(
          fileName: 'pet.jpg',
          sizeInBytes: Validators.maxPetPhotoSizeInBytes,
        ),
        isNull,
      );
    });
  });
}
