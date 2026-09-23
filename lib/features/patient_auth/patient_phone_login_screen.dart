import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../development_demo/employee_auth_placeholder.dart';
import 'patient_consent_screen.dart';
import 'patient_sms_code_screen.dart';
import 'russian_phone_input_formatter.dart';

class PatientPhoneLoginScreen extends StatefulWidget {
  const PatientPhoneLoginScreen({
    super.key,
    this.authService,
    this.sessionStore,
  });

  final DemoAuthService? authService;
  final DemoSessionStore? sessionStore;

  @override
  State<PatientPhoneLoginScreen> createState() =>
      _PatientPhoneLoginScreenState();
}

class _PatientPhoneLoginScreenState extends State<PatientPhoneLoginScreen> {
  late final DemoAuthService _authService;
  late final DemoSessionStore _sessionStore;
  final _phoneController = TextEditingController();
  final _phoneFormatter = RussianPhoneInputFormatter();
  bool _isSubmitting = false;
  bool _hasAcceptedConsent = false;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? DemoAuthService();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    final localDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (localDigits.length != 10) {
      setState(() {
        _phoneError = 'Введите номер телефона';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _phoneError = null;
    });

    final phone = '+7 ${_phoneController.text}';
    final lookup = _authService.lookupPatientByPhone(phone);
    Navigator.of(context)
        .push(
          appPageRoute<void>(
            context,
            builder: (_) => PatientSmsCodeScreen(
              phone: phone,
              patientId: lookup.patient?.id,
              isNewPatient: !lookup.isRegistered,
              authService: _authService,
              sessionStore: _sessionStore,
            ),
          ),
        )
        .whenComplete(() {
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
        });
  }

  void _openEmployeePlaceholder() {
    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) => EmployeeAuthPlaceholder(sessionStore: _sessionStore),
      ),
    );
  }

  void _openConsentDocument() {
    Navigator.of(context).push(
      appPageRoute<void>(context, builder: (_) => const PatientConsentScreen()),
    );
  }

  void _clearPhoneState() {
    if (_phoneError != null) {
      setState(() => _phoneError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentHeight =
        MediaQuery.sizeOf(context).height -
        _AuthFigma.statusHeight -
        _AuthFigma.headerHeight;

    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _AuthFigma.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: _AuthFigma.statusHeight),
              const _AuthHeader(title: 'Вход и регистрация'),
              SizedBox(
                height: contentHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: FocusManager.instance.primaryFocus?.unfocus,
                  onVerticalDragStart: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset(
                              _AuthFigma.logoAsset,
                              width: 140,
                              height: 40.13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            height: 72,
                            child: _GradientHeadline(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: Text(
                              'Войдите или создайте аккаунт\nпо номеру телефона.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _AuthFigma.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FigmaPhoneField(
                            controller: _phoneController,
                            formatter: _phoneFormatter,
                            errorText: _phoneError,
                            onChanged: (_) => _clearPhoneState(),
                          ),
                          const SizedBox(height: 16),
                          _ConsentRow(
                            isAccepted: _hasAcceptedConsent,
                            onChanged: (value) {
                              setState(() => _hasAcceptedConsent = value);
                            },
                            onOpenDocument: _openConsentDocument,
                          ),
                          const SizedBox(height: 16),
                          _FigmaButton(
                            label: 'Получить код',
                            backgroundColor: _hasAcceptedConsent
                                ? AppColors.brand
                                : AppColors.soft,
                            textColor: _hasAcceptedConsent
                                ? AppColors.onBrand
                                : AppColors.secondary,
                            onPressed: _isSubmitting || !_hasAcceptedConsent
                                ? null
                                : _submitPhone,
                          ),
                          const SizedBox(height: 16),
                          _FigmaButton(
                            label: 'Вход для сотрудников',
                            backgroundColor: AppColors.surface,
                            textColor: AppColors.brand,
                            onPressed: _openEmployeePlaceholder,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaPhoneField extends StatelessWidget {
  const _FigmaPhoneField({
    required this.controller,
    required this.formatter,
    this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final TextInputFormatter formatter;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: errorText == null ? 112 : 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Text(
              'Номер телефона',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _AuthFigma.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            key: const ValueKey('patient.phone.field.surface'),
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(
                color: errorText == null ? AppColors.border : AppColors.error,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              children: [
                Text('+7 ', style: _AuthFigma.inputText),
                Expanded(
                  child: TextField(
                    key: const ValueKey('patient.phone.input'),
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [formatter],
                    onChanged: onChanged,
                    style: _AuthFigma.inputText,
                    cursorColor: AppColors.brand,
                    decoration: InputDecoration(
                      hintText: '(___) ___-__-__',
                      hintStyle: _AuthFigma.inputText.copyWith(
                        color: AppColors.secondary,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Text(
              errorText ?? 'Отправим одноразовый код по SMS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _AuthFigma.secondaryText.copyWith(
                color: errorText == null
                    ? AppColors.secondary
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.isAccepted,
    required this.onChanged,
    required this.onOpenDocument,
  });

  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44,
            child: TextButton(
              key: const ValueKey('patient.consent.checkbox'),
              onPressed: () => onChanged(!isAccepted),
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: WidgetStatePropertyAll(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isAccepted ? AppColors.brand : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isAccepted ? AppColors.brand : AppColors.secondary,
                    ),
                  ),
                  child: isAccepted
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CustomPaint(painter: _ConsentCheckPainter()),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton(
              key: const ValueKey('patient.consent.document'),
              onPressed: onOpenDocument,
              style: const ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: WidgetStatePropertyAll(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: SizedBox(
                height: 40,
                child: Text(
                  'Согласен на обработку\nперсональных данных',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _AuthFigma.secondaryText.copyWith(
                    color: AppColors.brand,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckPainter extends CustomPainter {
  const _ConsentCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * (4.16663 / 20), size.height * (10 / 20))
        ..lineTo(size.width * (7.49996 / 20), size.height * (13.3333 / 20))
        ..lineTo(size.width * (15.8333 / 20), size.height * (5 / 20)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConsentCheckPainter oldDelegate) => false;
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _AuthFigma.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 24,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientHeadline extends StatelessWidget {
  const _GradientHeadline();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: _AuthFigma.contentWidth,
      height: _AuthFigma.headlineHeight,
      child: Column(
        children: [
          _GradientHeadlineLine(
            text: 'Сохраняя здоровье',
            gradient: _AuthFigma.firstHeadlineLineGradient,
          ),
          _GradientHeadlineLine(
            text: 'Ваших зубов.',
            gradient: _AuthFigma.secondHeadlineLineGradient,
          ),
        ],
      ),
    );
  }
}

class _GradientHeadlineLine extends StatelessWidget {
  const _GradientHeadlineLine({required this.text, required this.gradient});

  final String text;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, _AuthFigma.contentWidth, bounds.height),
      ),
      child: SizedBox(
        width: _AuthFigma.contentWidth,
        height: _AuthFigma.headlineLineHeight,
        child: Text(
          text,
          style: AppTypography.title.copyWith(color: AppColors.brand),
        ),
      ),
    );
  }
}

class _FigmaButton extends StatelessWidget {
  const _FigmaButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: WidgetStatePropertyAll(textColor),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.radius12),
          ),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          textStyle: const WidgetStatePropertyAll(AppTypography.label),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label.copyWith(color: textColor),
        ),
      ),
    );
  }
}

abstract final class _AuthFigma {
  static const statusHeight = 44.0;
  static const headerHeight = 56.0;
  static const contentWidth = 345.0;
  static const headlineLineHeight = 36.0;
  static const headlineHeight = 72.0;
  static const background = Color(0xFFF5F8FC);
  static const logoAsset = 'assets/icons/brand/logo_primary_clean.svg';

  static const firstHeadlineLineGradient = LinearGradient(
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
    stops: [0, 0.21287, 0.33704, 0.42574, 0.51443, 0.58539, 0.74504, 0.88696],
  );

  static const secondHeadlineLineGradient = LinearGradient(
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
    stops: [0, 0.14122, 0.22359, 0.28243, 0.34128, 0.38835, 0.49426, 0.58841],
  );

  static final secondaryText = AppTypography.small.copyWith(
    color: AppColors.secondary,
  );

  static final inputText = AppTypography.body.copyWith(color: AppColors.text);
}
