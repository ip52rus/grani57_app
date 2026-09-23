import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const sourcePath = 'assets/icon/app_icon.png';
  const outputPath = 'assets/images/maps/clinic_marker.png';
  const outputSize = 96;
  const sourceSize = 88;
  const center = outputSize / 2;
  const outerRadius = 46.0;
  const innerRadius = 43.0;

  final source = img.decodePng(File(sourcePath).readAsBytesSync());
  if (source == null) {
    throw StateError('Could not decode $sourcePath');
  }

  final resized = img.copyResize(
    source,
    width: sourceSize,
    height: sourceSize,
    interpolation: img.Interpolation.linear,
  );
  final marker = img.Image(
    width: outputSize,
    height: outputSize,
    numChannels: 4,
  );

  for (var y = 0; y < outputSize; y++) {
    for (var x = 0; x < outputSize; x++) {
      final dx = x + 0.5 - center;
      final dy = y + 0.5 - center;
      final distanceSquared = dx * dx + dy * dy;

      if (distanceSquared > outerRadius * outerRadius) {
        marker.setPixelRgba(x, y, 0, 0, 0, 0);
      } else if (distanceSquared > innerRadius * innerRadius) {
        marker.setPixelRgba(x, y, 220, 230, 245, 255);
      } else {
        final pixel = resized.getPixel(x - 4, y - 4);
        marker.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
      }
    }
  }

  File(outputPath).writeAsBytesSync(img.encodePng(marker));
}
