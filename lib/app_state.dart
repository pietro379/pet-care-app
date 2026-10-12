import 'package:flutter/material.dart';

/// Uygulama genelindeki tema modu. Profil sekmesindeki anahtar bunu değiştirir.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

/// Evcil hayvan bilgisi (ör. profil fotoğrafı) değiştiğinde artırılır;
/// diğer sekmeler bunu dinleyip kendilerini yeniler.
final ValueNotifier<int> petRevisionNotifier = ValueNotifier(0);
