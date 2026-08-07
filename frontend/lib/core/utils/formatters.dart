// Kod temizleme/formatlama (7K4R9M), tarih dönüştürücü
class Formatters {
  static String formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == -1) {
      return 'Dün';
    } else if (difference == 1) {
      return 'Yarın';
    }

    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  static String _monthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return months[month - 1];
  }
}
