// Form Doğrulayıcılar (Email, Şifre, Ad Soyad, Telefon, Hasta Kodu)
// VetTrack API Sözleşmesi (docs/api-contract.md) kuralları temel alınmıştır.

class Validators {
  /// E-posta doğrulama (Zorunlu, geçerli e-posta formatı)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  /// Şifre doğrulama (Zorunlu, en az 8 karakter, harf ve rakam içermelidir)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre zorunludur';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Şifreniz en az bir harf ve bir rakam içermelidir';
    }
    return null;
  }

  /// Ad Soyad doğrulama (Zorunlu, 1-100 karakter)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad zorunludur';
    }
    if (value.trim().length > 100) {
      return 'Ad soyad en fazla 100 karakter olabilir';
    }
    return null;
  }

  /// Telefon doğrulama (Opsiyonel, max 20 karakter)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opsiyonel
    }
    if (value.trim().length > 20) {
      return 'Telefon numarası en fazla 20 karakter olabilir';
    }
    return null;
  }

  /// Hasta Kodu doğrulama (Kodu ile hasta bulma için - FR-01 / EC-01)
  static String? validateUniqueCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hasta benzersiz kodu zorunludur';
    }
    return null;
  }
}
