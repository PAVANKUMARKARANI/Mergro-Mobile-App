// Renders every brand image from the code-drawn Mergro logo:
// native-splash logos, iOS app icons, Android launcher icons.
//
// Run:  flutter test tool/render_brand_assets_test.dart
// then: dart run flutter_native_splash:create   (only if the splash changed)
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/theme/app_colors.dart';
import 'package:mergro_ai_voice_assistant/core/theme/app_spacing.dart';
import 'package:mergro_ai_voice_assistant/shared/widgets/mergro_logo.dart';

const String _iosIconDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const String _androidRes = 'android/app/src/main/res';

/// Android density buckets → scale factor.
const Map<String, double> _densities = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

/// Bars painted at this fraction of the iOS icon (full-bleed navy behind).
const double _iosLogoFraction = 0.8;

/// Bars on the 108 dp adaptive canvas stay inside the 66 dp safe zone.
const double _adaptiveLogoFraction = 0.66;

/// What to draw on one square canvas of [px] pixels.
typedef _Paint = void Function(Canvas canvas, double px);

/// Draws the logo bars (optionally with tile) at [fraction] of [px], centred.
void _paintLogo(
  Canvas canvas,
  double px,
  double fraction, {
  bool drawTile = false,
  Color barColor = AppColors.darkAccent,
}) {
  final logo = px * fraction;
  canvas.save();
  canvas.translate((px - logo) / 2, (px - logo) / 2);
  MergroLogoPainter(
    barFactors: MergroLogoMark.restingBarFactors,
    drawTile: drawTile,
    barColor: barColor,
  ).paint(canvas, Size.square(logo));
  canvas.restore();
}

/// Renders [paint] to an image of [px] × [px].
Future<ui.Image> _render(int px, _Paint paint) {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder), px.toDouble());
  return recorder.endRecording().toImage(px, px);
}

/// Writes [image] as a normal RGBA PNG.
Future<void> _writePng(String path, ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

/// Writes [image] as an opaque RGB PNG. App Store icons must not contain an
/// alpha channel, and the engine's PNG encoder always writes RGBA.
Future<void> _writeOpaquePng(String path, ui.Image image) async {
  final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final width = image.width;
  final raw = BytesBuilder();
  for (var y = 0; y < image.height; y++) {
    raw.addByte(0); // PNG filter type: none.
    for (var x = 0; x < width; x++) {
      final offset = (y * width + x) * 4;
      raw.add([
        rgba.getUint8(offset),
        rgba.getUint8(offset + 1),
        rgba.getUint8(offset + 2),
      ]);
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, image.height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2); // colour type: truecolour (RGB)
  final png = BytesBuilder()
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    ..add(_chunk('IHDR', header.buffer.asUint8List()))
    ..add(_chunk('IDAT', ZLibCodec(level: 9).encode(raw.takeBytes())))
    ..add(_chunk('IEND', const []));
  await File(path).writeAsBytes(png.takeBytes());
}

/// One PNG chunk: length, type, data, CRC-32 of type + data.
List<int> _chunk(String type, List<int> data) {
  final typeAndData = [...ascii.encode(type), ...data];
  final length = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32(typeAndData));
  return [
    ...length.buffer.asUint8List(),
    ...typeAndData,
    ...crc.buffer.asUint8List(),
  ];
}

/// Standard CRC-32 (polynomial 0xEDB88320) as used by PNG.
int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}

/// iOS: full-bleed navy square with the bars; iOS applies its own mask.
Future<void> _renderIosIcons() async {
  final contents = jsonDecode(
    await File('$_iosIconDir/Contents.json').readAsString(),
  ) as Map<String, dynamic>;
  for (final entry in contents['images'] as List<dynamic>) {
    final image = entry as Map<String, dynamic>;
    final points = double.parse((image['size'] as String).split('x').first);
    final scale = double.parse((image['scale'] as String).replaceAll('x', ''));
    final px = (points * scale).round();
    final icon = await _render(px, (canvas, size) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = AppColors.lightBrandNavy,
      );
      _paintLogo(canvas, size, _iosLogoFraction);
    });
    await _writeOpaquePng('$_iosIconDir/${image['filename']}', icon);
  }
}

/// Android: legacy rounded tile (48 dp) plus adaptive foreground and
/// monochrome layers (108 dp) for every density.
Future<void> _renderAndroidIcons() async {
  for (final MapEntry(key: bucket, value: scale) in _densities.entries) {
    final dir = '$_androidRes/mipmap-$bucket';
    final legacy = await _render(
      (48 * scale).round(),
      (canvas, px) => _paintLogo(canvas, px, 1, drawTile: true),
    );
    await _writePng('$dir/ic_launcher.png', legacy);
    final layerPx = (108 * scale).round();
    final foreground = await _render(
      layerPx,
      (canvas, px) => _paintLogo(canvas, px, _adaptiveLogoFraction),
    );
    await _writePng('$dir/ic_launcher_foreground.png', foreground);
    final monochrome = await _render(
      layerPx,
      (canvas, px) => _paintLogo(
        canvas,
        px,
        _adaptiveLogoFraction,
        barColor: AppColors.white,
      ),
    );
    await _writePng('$dir/ic_launcher_monochrome.png', monochrome);
  }
}

/// Native-splash logos (treated as 4x assets by flutter_native_splash).
Future<void> _renderSplashLogos() async {
  const ratio = 4.0;
  const logoDp = AppSizes.logoLg;
  for (final (path, canvasDp) in [
    ('assets/splash/splash_logo.png', logoDp),
    ('assets/splash/splash_logo_android12.png', 288.0),
  ]) {
    final image = await _render(
      (canvasDp * ratio).round(),
      (canvas, px) => _paintLogo(canvas, px, logoDp / canvasDp, drawTile: true),
    );
    await _writePng(path, image);
  }
}

void main() {
  testWidgets('render brand assets', (tester) async {
    await tester.runAsync(() async {
      await _renderSplashLogos();
      await _renderIosIcons();
      await _renderAndroidIcons();
    });
  });
}
