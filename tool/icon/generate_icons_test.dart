// Uygulama ikonunu (Android + iOS) Flutter'ın kendi çizim motoruyla üretir.
// Yeni bir paket gerektirmez. Proje kökünden çalıştırın:
//
//   flutter test tool/icon/generate_icons_test.dart
//
// Üretilenler:
// - Android: mipmap-*/ic_launcher.png (eski cihazlar),
//   ic_launcher_foreground/background/monochrome.png (adaptif + temalı ikon)
// - iOS: AppIcon.appiconset içindeki tüm boyutlar (Contents.json'dan okunur)
// - Önizleme: build/icon_preview.png
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _androidRes = 'android/app/src/main/res';
const _iosIconSet = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

/// Eski tip ikon (dp=48) ve adaptif katman (dp=108) yoğunlukları.
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

// --- Renkler (uygulamanın indigo ve altın paletiyle aynı) --------------------
const _indigoTop = Color(0xFF6A5CF2);
const _indigoBottom = Color(0xFF2B2090);
const _gold = Color(0xFFE9B949);

/// Zemin: indigo gradyan + sağ üstte sıcak altın ışık.
void paintBackground(Canvas canvas, Size size) {
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_indigoTop, _indigoBottom],
      ).createShader(rect),
  );
  final s = size.width;
  canvas.drawRect(
    rect,
    Paint()
      ..shader =
          RadialGradient(
            colors: [_gold.withValues(alpha: 0.40), _gold.withValues(alpha: 0)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(s * 0.92, s * 0.08),
              radius: s * 0.75,
            ),
          ),
  );
}

/// Pati izi: büyük ana ped ve dört parmak. [box]: içeriğin sığacağı kare alan.
void paintPaw(Canvas canvas, Rect box, {bool monochrome = false}) {
  final c = box.width;
  Offset at(double x, double y) => box.topLeft + Offset(c * x, c * y);

  final fill = Paint()..color = const Color(0xFFFFFFFF);
  final shadow = Paint()
    ..color = const Color(0x55000000)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * 0.025);

  // (merkez, genişlik, yükseklik, açı)
  final shapes = <(Offset, double, double, double)>[
    // Ana ped: yumuşak, aşağı doğru genişleyen bir gövde (iki oval birleşimi)
    (at(0.50, 0.68), c * 0.54, c * 0.40, 0),
    (at(0.50, 0.62), c * 0.40, c * 0.44, 0),
    // Parmaklar
    (at(0.16, 0.44), c * 0.17, c * 0.25, -0.50),
    (at(0.37, 0.25), c * 0.17, c * 0.26, -0.16),
    (at(0.63, 0.25), c * 0.17, c * 0.26, 0.16),
    (at(0.84, 0.44), c * 0.17, c * 0.25, 0.50),
  ];

  void draw(Paint paint, double dy) {
    for (final (center, w, h, angle) in shapes) {
      canvas.save();
      canvas.translate(center.dx, center.dy + dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          Radius.circular(h * 0.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  // Önce tüm gölgeler, sonra tüm dolgular: birleşik şekiller arasında iç gölge kalmaz.
  if (!monochrome) draw(shadow, c * 0.02);
  draw(fill, 0);
}

Future<void> writePng(
  String path,
  int size,
  void Function(Canvas canvas, Size size) draw,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  draw(canvas, Size(size.toDouble(), size.toDouble()));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Eski Android cihazlar için: yuvarlatılmış kare, köşeler şeffaf.
void legacyIcon(Canvas canvas, Size size) {
  final rrect = RRect.fromRectAndRadius(
    Offset.zero & size,
    Radius.circular(size.width * 0.22),
  );
  canvas.save();
  canvas.clipRRect(rrect);
  paintBackground(canvas, size);
  paintPaw(canvas, _contentBox(size, 0.62));
  canvas.restore();
}

/// iOS: tam dolu kare (iOS köşeleri kendisi yuvarlar; şeffaflık olmamalı).
void iosIcon(Canvas canvas, Size size) {
  paintBackground(canvas, size);
  paintPaw(canvas, _contentBox(size, 0.62));
}

/// Adaptif ikonun ön katmanı: içerik, maskelerin kesmediği güvenli alanda.
void adaptiveForeground(Canvas canvas, Size size) =>
    paintPaw(canvas, _contentBox(size, 0.46));

void adaptiveMonochrome(Canvas canvas, Size size) =>
    paintPaw(canvas, _contentBox(size, 0.46), monochrome: true);

Rect _contentBox(Size size, double fraction) => Rect.fromCenter(
  center: size.center(Offset.zero),
  width: size.width * fraction,
  height: size.height * fraction,
);

void main() {
  test('uygulama ikonlarını üret', () async {
    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      final dir = '$_androidRes/mipmap-$density';
      await writePng('$dir/ic_launcher.png', (48 * scale).round(), legacyIcon);
      final layer = (108 * scale).round();
      await writePng(
        '$dir/ic_launcher_foreground.png',
        layer,
        adaptiveForeground,
      );
      await writePng('$dir/ic_launcher_background.png', layer, paintBackground);
      await writePng(
        '$dir/ic_launcher_monochrome.png',
        layer,
        adaptiveMonochrome,
      );
    }

    File('$_androidRes/mipmap-anydpi-v26/ic_launcher.xml')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<!-- tool/icon/generate_icons_test.dart tarafından üretildi -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
''');

    final contents = jsonDecode(
      File('$_iosIconSet/Contents.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final image in contents['images'] as List<dynamic>) {
      final entry = image as Map<String, dynamic>;
      final points = double.parse((entry['size'] as String).split('x').first);
      final scale = double.parse(
        (entry['scale'] as String).replaceAll('x', ''),
      );
      await writePng(
        '$_iosIconSet/${entry['filename']}',
        (points * scale).round(),
        iosIcon,
      );
    }

    await writePng('build/icon_preview.png', 512, legacyIcon);
    await writePng('build/icon_preview_adaptive.png', 432, (canvas, size) {
      // Android'in dairesel maskesiyle nasıl görüneceği
      canvas.clipPath(Path()..addOval(Offset.zero & size));
      paintBackground(canvas, size);
      adaptiveForeground(canvas, size);
    });
  });
}
