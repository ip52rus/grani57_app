import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../mock_data/demo_asset_paths.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.fadeDuration = const Duration(milliseconds: 1500),
  });

  final Duration fadeDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }

    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            const SizedBox(height: _SplashFigma.statusHeight),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: _SplashFigma.bottomPadding,
                ),
                child: Center(
                  child: SizedBox(
                    width: _SplashFigma.logoGroupWidth,
                    height: _SplashFigma.logoGroupHeight,
                    child: FadeTransition(
                      key: const ValueKey('splash.logo.fade'),
                      opacity: _opacity,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: SvgPicture.asset(
                              key: const ValueKey('splash.logo'),
                              DemoAssetPaths.logoWelcome,
                              width: _SplashFigma.logoWidth,
                              height: _SplashFigma.logoHeight,
                            ),
                          ),
                          Positioned(
                            left: _SplashFigma.taglineLeft,
                            top: _SplashFigma.taglineTop,
                            width: _SplashFigma.taglineWidth,
                            height: _SplashFigma.taglineHeight,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                              child: Text(
                                'клиники стоматологии',
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.043,
                                  color: AppColors.brand,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _SplashFigma {
  static const statusHeight = 44.0;
  static const bottomPadding = 44.0;
  static const logoGroupWidth = 260.0;
  static const logoGroupHeight = 78.0;
  static const logoWidth = 260.0;
  static const logoHeight = 74.5276;
  static const taglineLeft = 79.98314666748047;
  static const taglineTop = 62.0;
  static const taglineWidth = 181.016845703125;
  static const taglineHeight = 15.0;
}
