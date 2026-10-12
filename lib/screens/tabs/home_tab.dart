import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/vet_visit.dart';
import '../../services/storage_service.dart';
import '../../services/vet_repository.dart';
import '../../utils/date_format.dart';
import '../add_vet_record_screen.dart';

/// Ana Sayfa sekmesi: veteriner geçmişi kartları.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _storage = StorageService();
  final _vetRepository = VetRepository();

  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    // Profilde fotoğraf değişince karşılama başlığı da güncellensin.
    petRevisionNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    petRevisionNotifier.removeListener(_refresh);
    super.dispose();
  }

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      _storage.loadPet(),
      _vetRepository.getLastVisit(),
      _vetRepository.getUpcomingAppointment(),
    ]);
    return _HomeData(
      pet: results[0] as PetProfile?,
      lastVisit: results[1] as VetVisit?,
      appointment: results[2] as VetAppointment?,
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    if (!mounted) return;
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _openAddRecord() async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddVetRecordScreen()));
    if (added == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Veriler yüklenemedi.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _GreetingHeader(pet: data.pet, onAdd: _openAddRecord),
                const SizedBox(height: 24),
                _SectionTitle('Veteriner Geçmişi'),
                const SizedBox(height: 12),
                _LastVisitCard(visit: data.lastVisit),
                const SizedBox(height: 16),
                _UpcomingAppointmentCard(appointment: data.appointment),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.pet,
    required this.lastVisit,
    required this.appointment,
  });

  final PetProfile? pet;
  final VetVisit? lastVisit;
  final VetAppointment? appointment;
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.pet, required this.onAdd});

  final PetProfile? pet;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pet = this.pet;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: pet?.photoBytes == null
              ? null
              : MemoryImage(pet!.photoBytes!),
          child: pet?.photoBytes == null
              ? Icon(Icons.pets, color: theme.colorScheme.onPrimaryContainer)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba!', style: theme.textTheme.bodyMedium),
              Text(
                pet == null ? 'Evcil dostun' : '${pet.name} nasıl?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton.filled(
          tooltip: 'Veteriner kaydı ekle',
          onPressed: onAdd,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// Kartlar için ortak iskelet: ikonlu başlık + içerik.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.accent,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _LastVisitCard extends StatelessWidget {
  const _LastVisitCard({required this.visit});

  final VetVisit? visit;

  @override
  Widget build(BuildContext context) {
    final visit = this.visit;
    return _InfoCard(
      icon: Icons.history,
      title: 'Son Veteriner Ziyareti',
      child: visit == null
          ? const _DetailRow(
              icon: Icons.info_outline,
              text: 'Henüz kayıtlı bir ziyaret yok.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: formatDate(visit.date),
                ),
                _DetailRow(
                  icon: Icons.medical_services_outlined,
                  text: visit.procedure,
                ),
                if (visit.clinic != null)
                  _DetailRow(
                    icon: Icons.local_hospital_outlined,
                    text: visit.clinic!,
                  ),
              ],
            ),
    );
  }
}

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({required this.appointment});

  final VetAppointment? appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointment = this.appointment;
    return _InfoCard(
      icon: Icons.event_available,
      title: 'Yaklaşan Seans/Randevu',
      accent: theme.colorScheme.tertiary,
      child: appointment == null
          ? const _EmptyAppointment()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  text:
                      '${formatDate(appointment.dateTime)}, ${formatWeekday(appointment.dateTime)}',
                ),
                _DetailRow(
                  icon: Icons.schedule,
                  text: formatTime(appointment.dateTime),
                ),
                _DetailRow(
                  icon: Icons.medical_services_outlined,
                  text: appointment.procedure,
                ),
                if (appointment.clinic != null)
                  _DetailRow(
                    icon: Icons.local_hospital_outlined,
                    text: appointment.clinic!,
                  ),
              ],
            ),
    );
  }
}

/// Randevu olmadığında gösterilen boş durum tasarımı.
class _EmptyAppointment extends StatelessWidget {
  const _EmptyAppointment();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 36,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Yaklaşan randevu bulunmuyor',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Yeni bir randevu planlandığında burada görünecek.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
