import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/gradients/app_gradients.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../development_demo/employee_auth_placeholder.dart';
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
  bool _isSubmitting = false;
  String? _phoneError;
  bool _showUnknownPatientState = false;

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
        _showUnknownPatientState = false;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _phoneError = null;
      _showUnknownPatientState = false;
    });

    final phone = '+7 ${_phoneController.text}';
    final lookup = _authService.lookupPatientByPhone(phone);
    if (!lookup.isRegistered || lookup.patient == null) {
      setState(() {
        _isSubmitting = false;
        _showUnknownPatientState = true;
      });
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => PatientSmsCodeScreen(
              phone: phone,
              patientId: lookup.patient!.id,
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
      MaterialPageRoute<void>(builder: (_) => const EmployeeAuthPlaceholder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusHeight = MediaQuery.paddingOf(context).top;
    final contentHeight =
        MediaQuery.sizeOf(context).height -
        statusHeight -
        _AuthFigma.headerHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: statusHeight),
          _AuthHeader(
            title: 'Вход и регистрация',
            onBack: Navigator.of(context).canPop()
                ? () => Navigator.of(context).pop()
                : null,
          ),
          SizedBox(
            height: contentHeight,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        DemoAssetPaths.logoPrimary,
                        width: 140,
                        height: 40.13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 72,
                      child: _GradientHeadline(
                        'Сохраняя здоровье\nВаших зубов.',
                      ),
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
                      errorText: _phoneError,
                      onChanged: (_) {
                        if (_phoneError != null || _showUnknownPatientState) {
                          setState(() {
                            _phoneError = null;
                            _showUnknownPatientState = false;
                          });
                        }
                      },
                      onSubmitted: (_) => _submitPhone(),
                    ),
                    if (_showUnknownPatientState) ...[
                      const SizedBox(height: AppSpacing.x8),
                      Text(
                        'Регистрация нового пациента будет реализована следующим этапом',
                        style: AppTypography.small.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const _ConsentRow(),
                    const SizedBox(height: 16),
                    _FigmaButton(
                      label: 'Получить код',
                      backgroundColor: AppColors.soft,
                      textColor: AppColors.secondary,
                      onPressed: _isSubmitting ? null : _submitPhone,
                    ),
                    const SizedBox(height: 16),
                    _FigmaButton(
                      label: 'Контакты клиник',
                      backgroundColor: AppColors.soft,
                      textColor: AppColors.brand,
                      onPressed: () {},
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
        ],
      ),
    );
  }
}

class _FigmaPhoneField extends StatelessWidget {
  const _FigmaPhoneField({
    required this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

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
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final localPhone = value.text.trim();
                        final text = localPhone.isEmpty
                            ? '+7 (921) 000-00-00'
                            : '+7 $localPhone';
                        return SizedBox(
                          height: 24,
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _AuthFigma.inputText,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [RussianPhoneInputFormatter()],
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      maxLines: 1,
                      style: _AuthFigma.inputText,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '(921) 000-00-00',
                      ),
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
  const _ConsentRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.secondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: Text(
                'Согласен на обработку\nперсональных данных',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _AuthFigma.secondaryText.copyWith(
                  color: AppColors.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _AuthFigma.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Назад',
                onPressed: onBack,
                icon: Transform.translate(
                  offset: const Offset(-10, 0),
                  child: SvgPicture.asset(
                    DemoAssetPaths.back,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}

class _GradientHeadline extends StatelessWidget {
  const _GradientHeadline(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppGradients.brandHeader.createShader(bounds),
      child: Text(
        text,
        style: AppTypography.title.copyWith(color: AppColors.brand),
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
          overlayColor: WidgetStatePropertyAll(
            textColor.withValues(alpha: 0.08),
          ),
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
  static const headerHeight = 56.0;

  static final secondaryText = AppTypography.small.copyWith(
    color: AppColors.secondary,
  );

  static final inputText = AppTypography.body.copyWith(color: AppColors.text);
}
