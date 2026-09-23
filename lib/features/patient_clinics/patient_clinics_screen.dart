import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_maps_mapkit_lite/image.dart' as mapkit_image;
import 'package:yandex_maps_mapkit_lite/mapkit.dart' as yandex_mapkit;
import 'package:yandex_maps_mapkit_lite/yandex_map.dart' show YandexMap;

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/maps/mapkit_config.dart';
import '../../core/navigation/external_route_launcher.dart';
import '../patient_home/patient_home_screen.dart';

class PatientClinicsScreen extends StatelessWidget {
  const PatientClinicsScreen({
    super.key,
    this.bottomNavigation,
    this.onPhonePressed,
    this.onEmailPressed,
    this.onProsveshcheniyaRoutePressed,
    this.onBolsheokhtinskiyAddressPressed,
  });

  final Widget? bottomNavigation;
  final VoidCallback? onPhonePressed;
  final VoidCallback? onEmailPressed;
  final VoidCallback? onProsveshcheniyaRoutePressed;
  final VoidCallback? onBolsheokhtinskiyAddressPressed;

  Future<void> _openExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _ClinicsFigma.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: 44),
              const _ClinicsHeader(),
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 104),
                      children: [
                        const _ClinicsTitle(),
                        const SizedBox(height: 20),
                        const Text(
                          'Санкт-Петербург · 2 филиала',
                          style: _ClinicsFigma.small,
                        ),
                        const SizedBox(height: 20),
                        const _ClinicsMap(),
                        const SizedBox(height: 20),
                        _ContactCard(
                          iconAsset: 'assets/icons/actions/phone_clean.svg',
                          title: '+7 (812) 565-55-55',
                          subtitle: 'Единый номер клиник',
                          semanticLabel: 'Позвонить в клинику',
                          onTap:
                              onPhonePressed ??
                              () => _openExternal(
                                Uri(scheme: 'tel', path: '+78125655555'),
                              ),
                        ),
                        const SizedBox(height: 20),
                        _ContactCard(
                          iconAsset: 'assets/icons/actions/email.svg',
                          title: 'info@57g.ru',
                          subtitle: 'Написать в клинику',
                          semanticLabel: 'Написать в клинику',
                          onTap:
                              onEmailPressed ??
                              () => _openExternal(
                                Uri(scheme: 'mailto', path: 'info@57g.ru'),
                              ),
                        ),
                        const SizedBox(height: 20),
                        _ClinicCard(
                          title: 'На Просвещения',
                          address: 'пр. Просвещения, 15',
                          schedule: 'Ежедневно · 09:00–21:00',
                          buttonLabel: 'Построить маршрут',
                          onPressed:
                              onProsveshcheniyaRoutePressed ??
                              () => launchDrivingRoute(
                                latitude:
                                    _ClinicsFigma.prosveshcheniyaPoint.latitude,
                                longitude: _ClinicsFigma
                                    .prosveshcheniyaPoint
                                    .longitude,
                              ),
                        ),
                        const SizedBox(height: 20),
                        _ClinicCard(
                          badge: 'Скоро открытие',
                          badgeBackground: AppColors.soft,
                          badgeColor: AppColors.secondary,
                          title: 'На Большеохтинском',
                          address: 'Большеохтинский пр., 12',
                          buttonLabel: 'Посмотреть адрес',
                          onPressed:
                              onBolsheokhtinskiyAddressPressed ??
                              () => launchDrivingRoute(
                                latitude: _ClinicsFigma
                                    .bolsheokhtinskiyPoint
                                    .latitude,
                                longitude: _ClinicsFigma
                                    .bolsheokhtinskiyPoint
                                    .longitude,
                              ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 80,
                      child:
                          bottomNavigation ??
                          const PatientBottomNavigation(selectedIndex: 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicsHeader extends StatelessWidget {
  const _ClinicsHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Клиники',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
      ),
    ),
  );
}

class _ClinicsTitle extends StatelessWidget {
  const _ClinicsTitle();

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => _ClinicsFigma.titleGradient.createShader(
      const Rect.fromLTWH(0, 0, 345, 36),
    ),
    child: const SizedBox(
      width: 345,
      height: 36,
      child: Text('Мы рядом', style: AppTypography.title),
    ),
  );
}

class _ClinicsMap extends StatelessWidget {
  const _ClinicsMap();

  @override
  Widget build(BuildContext context) {
    if (!MapkitConfig.canShowLiveMap) {
      return const _StaticClinicsMap();
    }

    return ClipRRect(
      borderRadius: AppRadii.radius20,
      child: SizedBox(
        width: 345,
        height: 230,
        child: YandexMap(
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
          onMapCreated: (mapWindow) {
            final map = mapWindow.map;
            final markerImage = mapkit_image.ImageProvider.fromImageProvider(
              const AssetImage('assets/images/maps/clinic_marker.png'),
              id: 'clinic-marker-image',
            );
            map.move(
              const yandex_mapkit.CameraPosition(
                _ClinicsFigma.clinicsCenterPoint,
                zoom: 10.2,
                azimuth: 0,
                tilt: 0,
              ),
            );
            for (final clinic in _ClinicsFigma.mapClinics) {
              map.mapObjects.addPlacemarkWithImageStyle(
                clinic.point,
                markerImage,
                const yandex_mapkit.IconStyle(
                  scale: _ClinicsFigma.clinicMarkerScale,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _StaticClinicsMap extends StatelessWidget {
  const _StaticClinicsMap();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius20,
    child: SizedBox(
      width: 345,
      height: 230,
      child: OverflowBox(
        minWidth: 375,
        maxWidth: 375,
        minHeight: 287,
        maxHeight: 287,
        alignment: const Alignment(0, -0.54386),
        child: Image.asset(
          'assets/images/maps/clinic_prosveshcheniya_map.png',
          width: 375,
          height: 287,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

class _MapClinic {
  const _MapClinic({required this.id, required this.point});

  final String id;
  final yandex_mapkit.Point point;
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 345,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.radius20,
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: _ClinicsFigma.small),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    this.badge,
    this.badgeBackground,
    this.badgeColor,
    required this.title,
    required this.address,
    required this.buttonLabel,
    this.schedule,
    this.onPressed,
  });

  final String? badge;
  final Color? badgeBackground;
  final Color? badgeColor;
  final String title;
  final String address;
  final String? schedule;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: 345,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badge case final badge?) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: AppRadii.radiusFull,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                badge,
                style: AppTypography.caption.copyWith(color: badgeColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          schedule == null ? address : '$address\n$schedule',
          style: AppTypography.body.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: 12),
        _ClinicActionButton(label: buttonLabel, onPressed: onPressed),
      ],
    ),
  );
}

class _ClinicActionButton extends StatelessWidget {
  const _ClinicActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.soft,
          borderRadius: AppRadii.radius12,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
      ),
    ),
  );
}

abstract final class _ClinicsFigma {
  static const background = Color(0xFFF5F8FC);

  static const prosveshcheniyaPoint = yandex_mapkit.Point(
    latitude: 60.053122,
    longitude: 30.325969,
  );

  static const bolsheokhtinskiyPoint = yandex_mapkit.Point(
    latitude: 59.953350,
    longitude: 30.409483,
  );

  static const mapClinics = <_MapClinic>[
    _MapClinic(id: 'prosveshcheniya', point: prosveshcheniyaPoint),
    _MapClinic(id: 'bolsheokhtinskiy', point: bolsheokhtinskiyPoint),
  ];

  static const clinicsCenterPoint = yandex_mapkit.Point(
    latitude: 60.003236,
    longitude: 30.367726,
  );
  static const clinicMarkerScale = 1.0;

  static const small = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
  );

  static const titleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.brand,
      AppColors.brand,
      AppColors.sky,
      Color(0xFFA46BD5),
      AppColors.coral,
      AppColors.accent,
      AppColors.brand,
      AppColors.brand,
    ],
    stops: [0, 0.10783, 0.17072, 0.21565, 0.26058, 0.29652, 0.37739, 0.44928],
  );
}
