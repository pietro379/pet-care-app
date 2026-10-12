import 'package:flutter/material.dart';

import '../models/vet_visit.dart';
import '../services/vet_repository.dart';
import '../utils/date_format.dart';

/// Veteriner ziyareti ekleme formu.
/// Başarıyla kaydedilirse `true` ile kapanır.
class AddVetRecordScreen extends StatefulWidget {
  const AddVetRecordScreen({super.key});

  @override
  State<AddVetRecordScreen> createState() => _AddVetRecordScreenState();
}

class _AddVetRecordScreenState extends State<AddVetRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  final _repository = VetRepository();

  DateTime? _visitDate;
  // true: devam seansı yok ("Son seans"), false: sonraki seans planlı.
  bool _isFinalSession = true;
  DateTime? _nextDate;
  TimeOfDay _nextTime = const TimeOfDay(hour: 10, minute: 0);
  bool _showDateErrors = false;

  @override
  void dispose() {
    _procedureController.dispose();
    super.dispose();
  }

  Future<void> _pickVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _pickNextDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _nextDate = picked);
  }

  Future<void> _pickNextTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _nextTime,
      // Türkiye'de 24 saatlik biçim kullanılır.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextTime = picked);
  }

  Future<void> _save() async {
    setState(() => _showDateErrors = true);
    final formValid = _formKey.currentState!.validate();
    final visitDate = _visitDate;
    final nextDate = _nextDate;
    if (!formValid ||
        visitDate == null ||
        (!_isFinalSession && nextDate == null)) {
      return;
    }

    DateTime? nextSession;
    if (!_isFinalSession && nextDate != null) {
      nextSession = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        _nextTime.hour,
        _nextTime.minute,
      );
    }

    await _repository.addRecord(
      VetRecord(
        date: visitDate,
        procedure: _procedureController.text.trim(),
        nextSession: nextSession,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Veteriner Kaydı Ekle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateField(
                  label: 'Ziyaret tarihi',
                  icon: Icons.calendar_today_outlined,
                  value: _visitDate == null ? null : formatDate(_visitDate!),
                  errorText: _showDateErrors && _visitDate == null
                      ? 'Lütfen tarih seç'
                      : null,
                  onTap: _pickVisitDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _procedureController,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Yapılan işlemler',
                    hintText: 'Örn: Karma aşı, kontrol muayenesi',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Lütfen yapılan işlemi yaz'
                      : null,
                ),
                const SizedBox(height: 24),
                Text('Sonraki seans', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.check_circle_outline),
                      label: Text('Son seans'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.event_repeat),
                      label: Text('Sonraki seans var'),
                    ),
                  ],
                  selected: {_isFinalSession},
                  onSelectionChanged: (s) =>
                      setState(() => _isFinalSession = s.first),
                ),
                if (!_isFinalSession) ...[
                  const SizedBox(height: 16),
                  _DateField(
                    label: 'Sonraki seans tarihi',
                    icon: Icons.event_outlined,
                    value: _nextDate == null ? null : formatDate(_nextDate!),
                    errorText: _showDateErrors && _nextDate == null
                        ? 'Lütfen sonraki seans tarihini seç'
                        : null,
                    onTap: _pickNextDate,
                  ),
                  const SizedBox(height: 16),
                  _DateField(
                    label: 'Sonraki seans saati',
                    icon: Icons.schedule,
                    value:
                        '${_nextTime.hour.toString().padLeft(2, '0')}:${_nextTime.minute.toString().padLeft(2, '0')}',
                    onTap: _pickNextTime,
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _save,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dokununca seçici açan, salt okunur alan görünümlü satır.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
    this.errorText,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: errorText,
        ),
        child: Text(value ?? 'Seç'),
      ),
    );
  }
}
