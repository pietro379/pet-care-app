import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/vet_clinic.dart';
import '../../services/clinic_repository.dart';
import '../../services/storage_service.dart';

/// Harita sekmesi: veteriner kliniklerini kategoriye göre renkli marker'larla gösterir.
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  // Tüm demo klinikler ilk açılışta ekrana sığsın diye hafif batıya kaydırılmış merkez.
  static const _ankara = LatLng(39.90, 32.80);

  final _repository = ClinicRepository();
  final _storage = StorageService();
  late final Future<List<VetClinic>> _future = _repository.getClinics();

  /// Kullanıcının "kendi veterinerim" seçtiği kliniğin kimliği (yoksa null).
  String? _myVetId;

  @override
  void initState() {
    super.initState();
    _storage.loadMyVetId().then((id) {
      if (mounted) setState(() => _myVetId = id);
    });
  }

  Future<void> _setMyVet(String? id) async {
    setState(() => _myVetId = id);
    await _storage.saveMyVetId(id);
  }

  void _showClinic(VetClinic clinic) {
    final isMine = clinic.id == _myVetId;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _ClinicSheet(
        clinic: clinic,
        isMine: isMine,
        onToggleMine: () {
          Navigator.of(sheetContext).pop();
          _setMyVet(isMine ? null : clinic.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VetClinic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final clinics = snapshot.data ?? const <VetClinic>[];
        return Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _ankara,
                initialZoom: 10.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.petcare.pet_care_app',
                ),
                MarkerLayer(
                  markers: [
                    for (final clinic in clinics)
                      Marker(
                        point: clinic.position,
                        width: 44,
                        height: 44,
                        // Pinin ucu koordinatı göstersin diye üst-merkez hizalama.
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _showClinic(clinic),
                          child: _Pin(
                            color: clinic.id == _myVetId
                                ? ClinicCategory.myVet.color
                                : clinic.category.color,
                            size: 44,
                          ),
                        ),
                      ),
                  ],
                ),
                const RichAttributionWidget(
                  alignment: AttributionAlignment.bottomRight,
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap katkıda bulunanlar'),
                  ],
                ),
              ],
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _Legend()),
            ),
          ],
        );
      },
    );
  }
}

/// Harita pini. Beyaz pin de seçilsin diye koyu bir dış çizgi ile çizilir.
class _Pin extends StatelessWidget {
  const _Pin({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, size: size, color: Colors.black87),
        Icon(Icons.location_on, size: size - 4, color: color),
      ],
    );
  }
}

/// Marker renklerinin anlamını gösteren lejant çubuğu.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final category in ClinicCategory.values)
                _LegendItem(category: category),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.category});

  final ClinicCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pin(color: category.color, size: 20),
        const SizedBox(width: 4),
        Text(category.label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ClinicSheet extends StatelessWidget {
  const _ClinicSheet({
    required this.clinic,
    required this.isMine,
    required this.onToggleMine,
  });

  final VetClinic clinic;
  final bool isMine;
  final VoidCallback onToggleMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Pin(
                  color: isMine
                      ? ClinicCategory.myVet.color
                      : clinic.category.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  clinic.category.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: clinic.category.color,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 10),
                  const Chip(
                    avatar: Icon(Icons.favorite, size: 16),
                    label: Text('Kendi Veterinerim'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              clinic.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(clinic.address)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(clinic.hours)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: isMine
                  ? OutlinedButton.icon(
                      onPressed: onToggleMine,
                      icon: const Icon(Icons.heart_broken_outlined),
                      label: const Text('Kendi Veterinerimden Kaldır'),
                    )
                  : FilledButton.icon(
                      onPressed: onToggleMine,
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Kendi Veterinerim Yap'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
