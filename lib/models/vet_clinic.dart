import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Klinik kategorisi; marker rengini ve lejantı belirler.
/// [myVet] bir klinik kategorisi değildir; kullanıcının seçtiği kliniği
/// haritada ve lejantta beyaz göstermek için kullanılır.
enum ClinicCategory {
  nightOpen('Gece Açık', Colors.blue),
  emergency('Acil Servis', Colors.red),
  standard('Standart', Colors.green),
  myVet('Kendi Veterinerim', Colors.white);

  const ClinicCategory(this.label, this.color);

  final String label;
  final Color color;
}

class VetClinic {
  const VetClinic({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    required this.category,
    required this.hours,
  });

  final String id;
  final String name;
  final String address;
  final LatLng position;
  final ClinicCategory category;
  final String hours;
}
