import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main(List<String> args) {
  if (args.length != 4 && args.length != 5) {
    stderr.writeln(
      'Usage: dart run dev/tools/png_diff_overlay.dart '
      '<reference.png> <candidate.png> <diff.png> <overlay.png> [threshold]',
    );
    exitCode = 64;
    return;
  }

  final referencePath = args[0];
  final candidatePath = args[1];
  final diffPath = args[2];
  final overlayPath = args[3];
  final threshold = args.length == 5 ? int.parse(args[4]) : 8;

  final reference = _readPng(referencePath);
  final candidate = _readPng(candidatePath);
  if (reference.width != candidate.width ||
      reference.height != candidate.height) {
    stderr.writeln(
      'Image sizes differ: '
      '${reference.width}x${reference.height} vs '
      '${candidate.width}x${candidate.height}',
    );
    exitCode = 65;
    return;
  }

  final diff = img.Image(width: reference.width, height: reference.height);
  final overlay = img.Image(width: reference.width, height: reference.height);
  var changed = 0;

  for (var y = 0; y < reference.height; y += 1) {
    for (var x = 0; x < reference.width; x += 1) {
      final a = reference.getPixel(x, y);
      final b = candidate.getPixel(x, y);
      final dr = (a.r - b.r).abs().toInt();
      final dg = (a.g - b.g).abs().toInt();
      final db = (a.b - b.b).abs().toInt();
      final da = (a.a - b.a).abs().toInt();
      final delta = math.max(math.max(dr, dg), math.max(db, da));
      final isChanged = delta > threshold;
      if (isChanged) {
        changed += 1;
      }

      if (isChanged) {
        diff.setPixelRgba(x, y, 255, 0, 64, 255);
      } else {
        diff.setPixelRgba(x, y, 245, 248, 253, 255);
      }

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

  final total = reference.width * reference.height;
  final percent = changed * 100 / total;

  _writePng(diffPath, diff);
  _writePng(overlayPath, overlay);

  stdout.writeln('reference: $referencePath');
  stdout.writeln('candidate: $candidatePath');
  stdout.writeln('changed pixels: $changed');
  stdout.writeln('changed percent: ${percent.toStringAsFixed(4)}%');
  stdout.writeln('threshold: $threshold');
}

img.Image _readPng(String path) {
  final bytes = File(path).readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) {
    throw FormatException('Could not decode PNG: $path');
  }
  return image;
}

void _writePng(String path, img.Image image) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
}
