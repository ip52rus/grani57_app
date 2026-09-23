import 'package:url_launcher/url_launcher.dart';

typedef UriAvailabilityCheck = Future<bool> Function(Uri uri);
typedef ExternalUriLaunch = Future<bool> Function(Uri uri);

/// Opens driving directions using the preferred navigation apps.
///
/// The order is Yandex Navigator, Yandex Maps, then the cross-platform
/// Google Maps URL. The final URL can also work in a browser when the Google
/// Maps app is unavailable.
Future<bool> launchDrivingRoute({
  required double latitude,
  required double longitude,
  UriAvailabilityCheck? canOpen,
  ExternalUriLaunch? open,
}) async {
  final canOpenUri = canOpen ?? canLaunchUrl;
  final openUri =
      open ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  for (final uri in drivingRouteCandidates(
    latitude: latitude,
    longitude: longitude,
  )) {
    try {
      if (await canOpenUri(uri) && await openUri(uri)) return true;
    } on Exception {
      // Continue with the next navigation provider.
    }
  }

  return false;
}

List<Uri> drivingRouteCandidates({
  required double latitude,
  required double longitude,
}) {
  final lat = latitude.toStringAsFixed(6);
  final lon = longitude.toStringAsFixed(6);
  final destination = '$lat,$lon';

  return [
    Uri(
      scheme: 'yandexnavi',
      host: 'build_route_on_map',
      queryParameters: {'lat_to': lat, 'lon_to': lon},
    ),
    Uri(
      scheme: 'yandexmaps',
      host: 'maps.yandex.ru',
      path: '/',
      queryParameters: {'rtext': '~$destination', 'rtt': 'auto'},
    ),
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
      'dir_action': 'navigate',
    }),
  ];
}
