import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care_app/models/vet_visit.dart';

void main() {
  test('VetRecord JSON gidiş-dönüşünde veriyi korur', () {
    final record = VetRecord(
      date: DateTime(2026, 9, 21),
      procedure: 'Karma aşı',
      nextSession: DateTime(2026, 10, 21, 14, 30),
    );

    final restored = VetRecord.fromJson(record.toJson());

    expect(restored.date, record.date);
    expect(restored.procedure, 'Karma aşı');
    expect(restored.nextSession, record.nextSession);
  });

  test('Sonraki seansı olmayan kayıt "son seans" olarak kalır', () {
    final record = VetRecord(date: DateTime(2026, 9, 21), procedure: 'Kontrol');

    final restored = VetRecord.fromJson(record.toJson());

    expect(restored.nextSession, isNull);
  });
}
