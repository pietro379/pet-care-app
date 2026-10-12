import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vet_visit.dart';

/// Kullanıcının girdiği veteriner kayıtlarını cihaz hafızasında tutar.
class VetRepository {
  static const _kRecords = 'vet_records';

  Future<List<VetRecord>> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRecords);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => VetRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRecord(VetRecord record) async {
    final records = await _loadRecords();
    records.add(record);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kRecords,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }

  /// Tarihi en yeni olan kayıt; hiç kayıt yoksa null.
  Future<VetVisit?> getLastVisit() async {
    final records = await _loadRecords();
    if (records.isEmpty) return null;
    records.sort((a, b) => b.date.compareTo(a.date));
    final last = records.first;
    return VetVisit(date: last.date, procedure: last.procedure);
  }

  /// Gelecekteki en yakın sonraki seans; yoksa null (arayüz boş durum gösterir).
  Future<VetAppointment?> getUpcomingAppointment() async {
    final records = await _loadRecords();
    final now = DateTime.now();
    final upcoming =
        records
            .where((r) => r.nextSession != null && r.nextSession!.isAfter(now))
            .toList()
          ..sort((a, b) => a.nextSession!.compareTo(b.nextSession!));
    if (upcoming.isEmpty) return null;
    final next = upcoming.first;
    return VetAppointment(
      dateTime: next.nextSession!,
      procedure: '${next.procedure} (devam seansı)',
    );
  }
}
