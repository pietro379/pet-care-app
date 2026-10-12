/// Geçmiş bir veteriner ziyaretini temsil eder.
class VetVisit {
  const VetVisit({required this.date, required this.procedure, this.clinic});

  final DateTime date;
  final String procedure;
  final String? clinic;
}

/// Kullanıcının elle girdiği veteriner kaydı.
/// [nextSession] null ise bu kayıt "son seans"tır (devam seansı yok).
class VetRecord {
  const VetRecord({
    required this.date,
    required this.procedure,
    this.nextSession,
  });

  factory VetRecord.fromJson(Map<String, dynamic> json) => VetRecord(
    date: DateTime.parse(json['date'] as String),
    procedure: json['procedure'] as String,
    nextSession: json['nextSession'] == null
        ? null
        : DateTime.parse(json['nextSession'] as String),
  );

  final DateTime date;
  final String procedure;
  final DateTime? nextSession;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'procedure': procedure,
    'nextSession': nextSession?.toIso8601String(),
  };
}

/// Planlanmış bir veteriner randevusunu temsil eder.
class VetAppointment {
  const VetAppointment({
    required this.dateTime,
    required this.procedure,
    this.clinic,
  });

  final DateTime dateTime;
  final String procedure;
  final String? clinic;
}
