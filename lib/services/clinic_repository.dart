import 'package:latlong2/latlong.dart';

import '../models/vet_clinic.dart';

/// Veteriner klinikleri için demo veri kaynağı (Ankara).
/// Backend gelince içi değişecek.
class ClinicRepository {
  Future<List<VetClinic>> getClinics() async {
    return const [
      VetClinic(
        id: 'kizilay',
        name: 'Kızılay 7/24 Hayvan Hastanesi',
        address: 'Kızılay, Çankaya',
        position: LatLng(39.9208, 32.8541),
        category: ClinicCategory.emergency,
        hours: '7/24 açık • Acil servis',
      ),
      VetClinic(
        id: 'etimesgut',
        name: 'Etimesgut Acil Hayvan Kliniği',
        address: 'Eryaman, Etimesgut',
        position: LatLng(39.9500, 32.6800),
        category: ClinicCategory.emergency,
        hours: '7/24 açık • Acil servis',
      ),
      VetClinic(
        id: 'yenimahalle',
        name: 'Yenimahalle Gece Veteriner',
        address: 'Batıkent, Yenimahalle',
        position: LatLng(39.9660, 32.8100),
        category: ClinicCategory.nightOpen,
        hours: '18:00 - 06:00',
      ),
      VetClinic(
        id: 'kecioren',
        name: 'Keçiören Gece Kliniği',
        address: 'Etlik, Keçiören',
        position: LatLng(39.9890, 32.8640),
        category: ClinicCategory.nightOpen,
        hours: '20:00 - 08:00',
      ),
      VetClinic(
        id: 'mamak',
        name: 'Mamak Pati Veteriner',
        address: 'Tuzluçayır, Mamak',
        position: LatLng(39.9330, 32.9150),
        category: ClinicCategory.standard,
        hours: '09:00 - 19:00',
      ),
      VetClinic(
        id: 'oran',
        name: 'Oran Dost Veteriner',
        address: 'Oran, Çankaya',
        position: LatLng(39.8900, 32.8200),
        category: ClinicCategory.standard,
        hours: '09:30 - 18:30',
      ),
      VetClinic(
        id: 'golbasi',
        name: 'Gölbaşı Hayvan Sağlığı Merkezi',
        address: 'Gölbaşı',
        position: LatLng(39.7900, 32.8070),
        category: ClinicCategory.standard,
        hours: '10:00 - 19:00',
      ),
      VetClinic(
        id: 'cayyolu',
        name: 'Çayyolu Patili Dostlar Veteriner',
        address: 'Çayyolu, Çankaya',
        position: LatLng(39.8870, 32.6900),
        category: ClinicCategory.standard,
        hours: '09:00 - 19:00',
      ),
    ];
  }
}
