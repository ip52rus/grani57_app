import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: FadeTransition(
          key: const ValueKey('splash.logo.fade'),
          opacity: _opacity,
          child: SvgPicture.asset(
            key: const ValueKey('splash.logo'),
            DemoAssetPaths.logoWelcome,
            width: 260,
            height: 75,
          ),
        ),
      ),
    );
  }
}
