import 'package:flutter/widgets.dart';
import 'package:yandex_maps_mapkit_lite/init.dart' as mapkit_init;
import 'package:yandex_maps_mapkit_lite/mapkit_factory.dart';

import '../../core/maps/mapkit_config.dart';
import '../app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (MapkitConfig.hasApiKey) {
    try {
      await mapkit_init.initMapkit(apiKey: MapkitConfig.apiKey);
      MapkitConfig.initialized = true;
      _mapkitLifecycle.start();
      WidgetsBinding.instance.addObserver(_mapkitLifecycle);
    } catch (error, stackTrace) {
      debugPrint('Yandex MapKit initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  runApp(const Grani57App());
}

final _mapkitLifecycle = _MapkitLifecycleObserver();

class _MapkitLifecycleObserver with WidgetsBindingObserver {
  var _started = false;

  void start() {
    if (_started) return;
    mapkit.onStart();
    _started = true;
  }

  void stop() {
    if (!_started) return;
    mapkit.onStop();
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        start();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stop();
      case AppLifecycleState.inactive:
        break;
    }
  }
}
