import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates a route with the navigation convention of the current platform.
///
/// iOS receives Cupertino's interactive edge-swipe back gesture. Android uses
/// Material navigation and the system back action. Screens retain their Figma
/// content; only the transition and navigation behavior adapt.
Route<T> appPageRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
  TargetPlatform? platform,
}) {
  final effectivePlatform = platform ?? Theme.of(context).platform;
  Widget pageBuilder(BuildContext context) => _WideBackSwipeRegion(
    platform: effectivePlatform,
    child: builder(context),
  );

  if (effectivePlatform == TargetPlatform.iOS) {
    return CupertinoPageRoute<T>(
      builder: pageBuilder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  return MaterialPageRoute<T>(
    builder: pageBuilder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );
}

/// Adds a comfortable one-handed back gesture without replacing native route
/// transitions. The system iOS edge gesture keeps handling the first 24 px;
/// this detector extends the same action through the left 40% of the screen.
class _WideBackSwipeRegion extends StatefulWidget {
  const _WideBackSwipeRegion({required this.platform, required this.child});

  final TargetPlatform platform;
  final Widget child;

  @override
  State<_WideBackSwipeRegion> createState() => _WideBackSwipeRegionState();
}

class _WideBackSwipeRegionState extends State<_WideBackSwipeRegion> {
  static const _activationWidthFactor = 0.4;
  static const _minimumTravel = 64.0;
  static const _nativeIosEdgeWidth = 24.0;

  int? _pointer;
  Offset? _start;

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || !Navigator.of(context).canPop()) return;
    final width = MediaQuery.sizeOf(context).width;
    final startsInsideExtendedArea =
        event.position.dx <= width * _activationWidthFactor;
    final belongsToNativeIosEdge =
        widget.platform == TargetPlatform.iOS &&
        event.position.dx < _nativeIosEdgeWidth;
    if (!startsInsideExtendedArea || belongsToNativeIosEdge) return;
    _pointer = event.pointer;
    _start = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_pointer != event.pointer || _start == null) return;
    final delta = event.position - _start!;
    _clearPointer();
    final isIntentionalBackSwipe =
        delta.dx >= _minimumTravel && delta.dx > delta.dy.abs() * 1.25;
    if (isIntentionalBackSwipe && Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_pointer == event.pointer) _clearPointer();
  }

  void _clearPointer() {
    _pointer = null;
    _start = null;
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _handlePointerDown,
    onPointerUp: _handlePointerUp,
    onPointerCancel: _handlePointerCancel,
    child: widget.child,
  );
}
