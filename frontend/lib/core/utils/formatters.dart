class Formatters {
  static const List<String> _turkishMonths = [
    '', // 1-indexed
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

  /// Formats ISO 8601 string to Turkish date string (e.g., "29 Temmuz 2026").
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return '-';
    }
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) {
      return '-';
    }
    final local = dateTime.toLocal();
    return '${local.day} ${_turkishMonths[local.month]} ${local.year}';
  }

  /// Formats ISO 8601 string to Turkish date-time string (e.g., "29 Temmuz 2026, 17:32").
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return '-';
    }
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) {
      return '-';
    }
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${_turkishMonths[local.month]} ${local.year}, $hour:$minute';
  }

  /// Formats ISO 8601 string to Turkish relative time string (e.g., "3 dakika önce", "az önce").
  static String formatTimeAgo(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return '-';
    }
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) {
      return '-';
    }
    
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.isNegative) {
      return 'az önce';
    }

    if (difference.inSeconds < 60) {
      return 'az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return formatDate(isoString);
    }
  }

  /// Cleans unique pet code by removing spaces and transforming it to uppercase (e.g., "7k4r 9m" -> "7K4R9M").
  static String normalizeUniqueCode(String? code) {
    if (code == null) {
      return '';
    }
    return code.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  /// Formats standard Turkish phone number (e.g., "05551234567" -> "0 (555) 123 45 67").
  static String formatPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return '-';
    }
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '0 (${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return '0 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} ${cleaned.substring(9, 11)}';
    }
    return phone;
  }
}
