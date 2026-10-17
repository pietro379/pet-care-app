import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care_app/utils/date_format.dart';

void main() {
  test('formatDate Türkçe ay adıyla yazar', () {
    expect(formatDate(DateTime(2026, 10, 12)), '12 Ekim 2026');
    expect(formatDate(DateTime(2027, 1, 3)), '3 Ocak 2027');
  });

  test('formatWeekday haftanın gününü Türkçe verir', () {
    expect(formatWeekday(DateTime(2026, 10, 12)), 'Pazartesi');
    expect(formatWeekday(DateTime(2026, 10, 18)), 'Pazar');
  });

  test('formatTime saat ve dakikayı iki haneli yazar', () {
    expect(formatTime(DateTime(2026, 10, 12, 9, 5)), '09:05');
    expect(formatTime(DateTime(2026, 10, 12, 14, 30)), '14:30');
  });
}
