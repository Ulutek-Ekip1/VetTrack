import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';

void main() {
  group('Formatters - formatDate', () {
    test('should return "-" when input is null, empty or invalid', () {
      expect(Formatters.formatDate(null), '-');
      expect(Formatters.formatDate(''), '-');
      expect(Formatters.formatDate('invalid-date'), '-');
    });

    test('should format ISO string to Turkish date', () {
      expect(Formatters.formatDate('2026-07-29T14:32:11Z'), '29 Temmuz 2026');
      expect(Formatters.formatDate('2026-01-01T00:00:00Z'), '1 Ocak 2026');
    });
  });

  group('Formatters - formatDateTime', () {
    test('should return "-" when input is null, empty or invalid', () {
      expect(Formatters.formatDateTime(null), '-');
      expect(Formatters.formatDateTime(''), '-');
      expect(Formatters.formatDateTime('invalid-date'), '-');
    });

    test('should format ISO string to Turkish date and time (using local timezone)', () {
      // Since it converts to local time, we parse a local date to avoid timezone offset discrepancies in tests
      final localDateTime = DateTime(2026, 7, 29, 17, 32);
      final isoString = localDateTime.toIso8601String();
      expect(Formatters.formatDateTime(isoString), '29 Temmuz 2026, 17:32');
    });
  });

  group('Formatters - formatTimeAgo', () {
    test('should return "-" when input is null, empty or invalid', () {
      expect(Formatters.formatTimeAgo(null), '-');
      expect(Formatters.formatTimeAgo(''), '-');
      expect(Formatters.formatTimeAgo('invalid-date'), '-');
    });

    test('should return relative time for recent events', () {
      final now = DateTime.now();

      final justNow = now.subtract(const Duration(seconds: 15)).toIso8601String();
      expect(Formatters.formatTimeAgo(justNow), 'az önce');

      final minutesAgo = now.subtract(const Duration(minutes: 5)).toIso8601String();
      expect(Formatters.formatTimeAgo(minutesAgo), '5 dakika önce');

      final hoursAgo = now.subtract(const Duration(hours: 3)).toIso8601String();
      expect(Formatters.formatTimeAgo(hoursAgo), '3 saat önce');

      final daysAgo = now.subtract(const Duration(days: 4)).toIso8601String();
      expect(Formatters.formatTimeAgo(daysAgo), '4 gün önce');
    });

    test('should fall back to absolute date formatting for older events (> 7 days)', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      final isoString = oldDate.toIso8601String();
      expect(Formatters.formatTimeAgo(isoString), Formatters.formatDate(isoString));
    });
  });

  group('Formatters - normalizeUniqueCode', () {
    test('should return empty string if input is null', () {
      expect(Formatters.normalizeUniqueCode(null), '');
    });

    test('should remove spaces and uppercase the code', () {
      expect(Formatters.normalizeUniqueCode('7k4r 9m'), '7K4R9M');
      expect(Formatters.normalizeUniqueCode('  7K4r9m  '), '7K4R9M');
      expect(Formatters.normalizeUniqueCode('7K4R9M'), '7K4R9M');
    });
  });

  group('Formatters - formatPhone', () {
    test('should return "-" if input is null or empty', () {
      expect(Formatters.formatPhone(null), '-');
      expect(Formatters.formatPhone(''), '-');
    });

    test('should format 10-digit phone number without leading 0', () {
      expect(Formatters.formatPhone('5551234567'), '0 (555) 123 45 67');
      expect(Formatters.formatPhone('(555) 123 45 67'), '0 (555) 123 45 67');
    });

    test('should format 11-digit phone number starting with 0', () {
      expect(Formatters.formatPhone('05551234567'), '0 (555) 123 45 67');
    });

    test('should return original value for other lengths', () {
      expect(Formatters.formatPhone('123456'), '123456');
    });
  });
}
