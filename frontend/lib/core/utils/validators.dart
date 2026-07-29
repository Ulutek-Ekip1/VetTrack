class Validators {
  /// Validates that a value is not null and not empty.
  static String? isNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
  }

  /// Validates an email address format.
  static String? isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz.';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçersiz e-posta adresi formatı.';
    }
    return null;
  }

  /// Validates password strength (minimum 8 characters).
  static String? isValidPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz.';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }
    return null;
  }

  /// Validates name length (1-100 characters).
  static String? isValidName(String? value, String fieldName) {
    final emptyCheck = isNotEmpty(value, fieldName);
    if (emptyCheck != null) return emptyCheck;

    if (value!.trim().length > 100) {
      return '$fieldName en fazla 100 karakter olabilir.';
    }
    return null;
  }

  /// Validates phone number format.
  static String? isValidPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in some endpoints, null is handled externally if required.
    }
    // Clean spaces, parentheses, dashes, and dots: "0 (555) 123-45.67" -> "05551234567"
    final cleaned = value.replaceAll(RegExp(r'[\s\(\)\-\.]'), '');
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Geçersiz telefon numarası formatı.';
    }
    return null;
  }

  /// Validates unique code for pets (exactly 6 alphanumeric characters ignoring spaces).
  static String? isValidUniqueCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hayvan kodu boş bırakılamaz.';
    }
    // Remove spaces before validation
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    if (normalized.length != 6) {
      return 'Hayvan kodu tam olarak 6 haneli olmalıdır.';
    }
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(normalized)) {
      return 'Hayvan kodu sadece harf ve rakamlardan oluşmalıdır.';
    }
    return null;
  }

  /// Validates pet age (must be an integer between 0 and 50).
  static String? isValidAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Age is optional.
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Yaş geçerli bir sayı olmalıdır.';
    }
    if (age < 0 || age > 50) {
      return 'Yaş 0 ile 50 arasında olmalıdır.';
    }
    return null;
  }
}
