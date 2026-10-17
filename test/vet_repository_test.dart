import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care_app/models/vet_visit.dart';
import 'package:pet_care_app/services/vet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late VetRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = VetRepository();
  });

  test('kayıt yokken son ziyaret ve randevu boştur', () async {
    expect(await repo.getLastVisit(), isNull);
    expect(await repo.getUpcomingAppointment(), isNull);
  });

  test('son ziyaret tarihi en yeni olan kayıttır', () async {
    await repo.addRecord(
      VetRecord(date: DateTime(2026, 1, 10), procedure: 'Eski kayıt'),
    );
    await repo.addRecord(
      VetRecord(date: DateTime(2026, 6, 5), procedure: 'Yeni kayıt'),
    );

    final last = await repo.getLastVisit();

    expect(last?.procedure, 'Yeni kayıt');
  });

  test('yaklaşan randevu gelecekteki en yakın seanstır', () async {
    final now = DateTime.now();
    await repo.addRecord(
      VetRecord(
        date: now.subtract(const Duration(days: 30)),
        procedure: 'Geçmiş seans',
        nextSession: now.subtract(const Duration(days: 1)),
      ),
    );
    await repo.addRecord(
      VetRecord(
        date: now,
        procedure: 'Uzak',
        nextSession: now.add(const Duration(days: 20)),
      ),
    );
    await repo.addRecord(
      VetRecord(
        date: now,
        procedure: 'Yakın',
        nextSession: now.add(const Duration(days: 3)),
      ),
    );

    final next = await repo.getUpcomingAppointment();

    expect(next?.procedure, 'Yakın (devam seansı)');
  });

  test('sonraki seansı olmayan kayıt randevu oluşturmaz', () async {
    await repo.addRecord(
      VetRecord(date: DateTime.now(), procedure: 'Son seans'),
    );

    expect(await repo.getUpcomingAppointment(), isNull);
  });
}
