import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final baseDir = args.isEmpty ? 'docs/visual_tests/patient_auth' : args.first;
  final screens = args.length < 2 ? ['login', 'sms'] : args.skip(1);
  final results = <String, Object>{};

  for (final screen in screens) {
    final metrics = _compareScreen(baseDir, screen);
    results[screen] = metrics;
    stdout.writeln(
      '$screen: ${metrics.changedPixels} changed pixels '
      '(${metrics.changedPercentage.toStringAsFixed(2)}%)',
    );
  }

  File('$baseDir/metrics.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        for (final entry in results.entries)
          entry.key: (entry.value as DiffMetrics).toJson(),
      }),
    );
}

DiffMetrics _compareScreen(String baseDir, String screen) {
  final figmaPath = '$baseDir/${screen}_figma.png';
  final flutterPath = '$baseDir/${screen}_flutter.png';
  final diffPath = '$baseDir/${screen}_diff.png';
  final overlayPath = '$baseDir/${screen}_overlay.png';

  final figma = _readPng(figmaPath);
  final flutter = _readPng(flutterPath);
  if (figma.width != flutter.width || figma.height != flutter.height) {
    throw StateError(
      '$screen size mismatch: '
      'figma=${figma.width}x${figma.height}, '
      'flutter=${flutter.width}x${flutter.height}',
    );
  }

  final diff = img.Image(width: figma.width, height: figma.height);
  final overlay = img.Image(width: figma.width, height: figma.height);
  var changedPixels = 0;

  for (var y = 0; y < figma.height; y++) {
    for (var x = 0; x < figma.width; x++) {
      final a = figma.getPixel(x, y);
      final b = flutter.getPixel(x, y);
      final dr = (a.r - b.r).abs().toInt();
      final dg = (a.g - b.g).abs().toInt();
      final db = (a.b - b.b).abs().toInt();
      final da = (a.a - b.a).abs().toInt();
      if (dr != 0 || dg != 0 || db != 0 || da != 0) {
        changedPixels++;
      }

      diff.setPixelRgba(x, y, dr, dg, db, 255);
      overlay.setPixelRgba(
        x,
        y,
        ((a.r + b.r) / 2).round(),
        ((a.g + b.g) / 2).round(),
        ((a.b + b.b) / 2).round(),
        255,
      );
    }
  }

  File(diffPath).writeAsBytesSync(img.encodePng(diff));
  File(overlayPath).writeAsBytesSync(img.encodePng(overlay));

  final totalPixels = figma.width * figma.height;
  return DiffMetrics(
    width: figma.width,
    height: figma.height,
    changedPixels: changedPixels,
    changedPercentage: changedPixels * 100 / totalPixels,
  );
}

img.Image _readPng(String path) {
  final image = img.decodePng(File(path).readAsBytesSync());
  if (image == null) {
    throw StateError('Could not decode $path');
  }
  return image;
}

class DiffMetrics {
  const DiffMetrics({
    required this.width,
    required this.height,
    required this.changedPixels,
    required this.changedPercentage,
  });

  final int width;
  final int height;
  final int changedPixels;
  final double changedPercentage;

  Map<String, Object> toJson() {
    return {
      'width': width,
      'height': height,
      'changedPixels': changedPixels,
      'changedPercentage': changedPercentage,
    };
  }
}
