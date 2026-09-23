abstract final class MapkitConfig {
  static const apiKey = String.fromEnvironment('MAPKIT_API_KEY');

  static bool initialized = false;

  static bool get hasApiKey => apiKey.isNotEmpty;
  static bool get canShowLiveMap => hasApiKey && initialized;
}
