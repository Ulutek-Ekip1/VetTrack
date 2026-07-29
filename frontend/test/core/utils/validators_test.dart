import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/utils/validators.dart';

void main() {
  group('Validators - isNotEmpty', () {
    test('should return error message when value is null or empty', () {
      expect(Validators.isNotEmpty(null, 'Ad'), 'Ad boş bırakılamaz.');
      expect(Validators.isNotEmpty('', 'Ad'), 'Ad boş bırakılamaz.');
      expect(Validators.isNotEmpty('   ', 'Ad'), 'Ad boş bırakılamaz.');
    });

    test('should return null when value is valid', () {
      expect(Validators.isNotEmpty('Mehmet', 'Ad'), null);
    });
  });

  group('Validators - isValidEmail', () {
    test('should return error message when email is empty or null', () {
      expect(Validators.isValidEmail(null), 'E-posta adresi boş bırakılamaz.');
      expect(Validators.isValidEmail(''), 'E-posta adresi boş bırakılamaz.');
    });

    test('should return error message when email format is invalid', () {
      expect(Validators.isValidEmail('invalid-email'), 'Geçersiz e-posta adresi formatı.');
      expect(Validators.isValidEmail('test@'), 'Geçersiz e-posta adresi formatı.');
      expect(Validators.isValidEmail('@example.com'), 'Geçersiz e-posta adresi formatı.');
      expect(Validators.isValidEmail('test@example'), 'Geçersiz e-posta adresi formatı.');
    });

    test('should return null when email is valid', () {
      expect(Validators.isValidEmail('ayse@example.com'), null);
      expect(Validators.isValidEmail('test.user+tag@domain.co.uk'), null);
    });
  });

  group('Validators - isValidPassword', () {
    test('should return error message when password is empty or null', () {
      expect(Validators.isValidPassword(null), 'Şifre boş bırakılamaz.');
      expect(Validators.isValidPassword(''), 'Şifre boş bırakılamaz.');
    });

    test('should return error message when password is too short', () {
      expect(Validators.isValidPassword('1234567'), 'Şifre en az 8 karakter olmalıdır.');
    });

    test('should return null when password is valid', () {
      expect(Validators.isValidPassword('12345678'), null);
      expect(Validators.isValidPassword('strongPassword123!'), null);
    });
  });

  group('Validators - isValidName', () {
    test('should return error message when name is empty', () {
      expect(Validators.isValidName('', 'İsim'), 'İsim boş bırakılamaz.');
    });

    test('should return error message when name exceeds 100 characters', () {
      final longName = 'A' * 101;
      expect(Validators.isValidName(longName, 'İsim'), 'İsim en fazla 100 karakter olabilir.');
    });

    test('should return null when name is valid', () {
      expect(Validators.isValidName('Boncuk', 'Pet Adı'), null);
    });
  });

  group('Validators - isValidPhone', () {
    test('should return null when phone is null or empty (since it is optional)', () {
      expect(Validators.isValidPhone(null), null);
      expect(Validators.isValidPhone(''), null);
    });

    test('should return error message when phone format is invalid', () {
      expect(Validators.isValidPhone('12345'), 'Geçersiz telefon numarası formatı.');
      expect(Validators.isValidPhone('abcdefghijk'), 'Geçersiz telefon numarası formatı.');
    });

    test('should return null when phone is valid', () {
      expect(Validators.isValidPhone('5551234567'), null);
      expect(Validators.isValidPhone('+905551234567'), null);
      expect(Validators.isValidPhone('0 (555) 123 45 67'), null);
    });
  });

  group('Validators - isValidUniqueCode', () {
    test('should return error message when code is empty', () {
      expect(Validators.isValidUniqueCode(null), 'Hayvan kodu boş bırakılamaz.');
      expect(Validators.isValidUniqueCode(''), 'Hayvan kodu boş bırakılamaz.');
    });

    test('should return error message when code is not exactly 6 characters after trimming', () {
      expect(Validators.isValidUniqueCode('12345'), 'Hayvan kodu tam olarak 6 haneli olmalıdır.');
      expect(Validators.isValidUniqueCode('1234567'), 'Hayvan kodu tam olarak 6 haneli olmalıdır.');
    });

    test('should return error message when code has non-alphanumeric characters', () {
      expect(Validators.isValidUniqueCode('12345#'), 'Hayvan kodu sadece harf ve rakamlardan oluşmalıdır.');
    });

    test('should return null when code is valid (even with spaces)', () {
      expect(Validators.isValidUniqueCode('7K4R9M'), null);
      expect(Validators.isValidUniqueCode('7k4r 9m'), null); // Spaces are removed inside validator
    });
  });

  group('Validators - isValidAge', () {
    test('should return null when age is null or empty', () {
      expect(Validators.isValidAge(null), null);
      expect(Validators.isValidAge(''), null);
    });

    test('should return error when age is not an integer', () {
      expect(Validators.isValidAge('five'), 'Yaş geçerli bir sayı olmalıdır.');
      expect(Validators.isValidAge('3.5'), 'Yaş geçerli bir sayı olmalıdır.');
    });

    test('should return error when age is out of bounds (0-50)', () {
      expect(Validators.isValidAge('-1'), 'Yaş 0 ile 50 arasında olmalıdır.');
      expect(Validators.isValidAge('51'), 'Yaş 0 ile 50 arasında olmalıdır.');
    });

    test('should return null when age is valid', () {
      expect(Validators.isValidAge('0'), null);
      expect(Validators.isValidAge('5'), null);
      expect(Validators.isValidAge('50'), null);
    });
  });
}
