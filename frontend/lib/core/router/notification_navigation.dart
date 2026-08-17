/// Bildirim türünü, kullanıcının görebileceği en ilgili mevcut ekrana eşler.
/// Tekil tedavi ve ziyaret detay rotaları eklenene kadar ilgili geçmiş ekranı
/// kullanılır.
class NotificationNavigation {
  const NotificationNavigation._();

  static String? destinationFor({
    required String type,
    String? petId,
  }) {
    if (petId == null || petId.isEmpty) return null;

    switch (type.toUpperCase()) {
      case 'TREATMENT':
      case 'VACCINE':
        return '/owner/pets/$petId/treatments';
      case 'RECOMMENDATION':
        return '/owner/pets/$petId/recommendations';
      case 'VISIT':
        return '/owner/pets/$petId/visits';
      default:
        return '/owner/pets/$petId';
    }
  }
}
