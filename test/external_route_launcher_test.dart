import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/navigation/external_route_launcher.dart';

void main() {
  const latitude = 60.053122;
  const longitude = 30.325969;

  test('driving route candidates keep the required provider order', () {
    final candidates = drivingRouteCandidates(
      latitude: latitude,
      longitude: longitude,
    );

    expect(candidates.map((uri) => uri.scheme), [
      'yandexnavi',
      'yandexmaps',
      'https',
    ]);
    expect(candidates.first.queryParameters['lat_to'], '60.053122');
    expect(candidates.first.queryParameters['lon_to'], '30.325969');
    expect(
      candidates.last.queryParameters['destination'],
      '60.053122,30.325969',
    );
  });

  test('driving route falls back to Yandex Maps', () async {
    final launched = <Uri>[];

    final didOpen = await launchDrivingRoute(
      latitude: latitude,
      longitude: longitude,
      canOpen: (uri) async => uri.scheme == 'yandexmaps',
      open: (uri) async {
        launched.add(uri);
        return true;
      },
    );

    expect(didOpen, isTrue);
    expect(launched.single.scheme, 'yandexmaps');
  });

  test('driving route falls back to Google Maps URL', () async {
    final launched = <Uri>[];

    final didOpen = await launchDrivingRoute(
      latitude: latitude,
      longitude: longitude,
      canOpen: (uri) async => uri.scheme == 'https',
      open: (uri) async {
        launched.add(uri);
        return true;
      },
    );

    expect(didOpen, isTrue);
    expect(launched.single.host, 'www.google.com');
  });
}
