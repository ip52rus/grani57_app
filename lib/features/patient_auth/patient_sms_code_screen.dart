import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../development_demo/patient_shell_placeholder.dart';
import 'patient_new_data_screen.dart';

class PatientSmsCodeScreen extends StatefulWidget {
  const PatientSmsCodeScreen({
    required this.phone,
    required this.patientId,
    this.isNewPatient = false,
    required this.authService,
    required this.sessionStore,
    super.key,
  });

  final String phone;
  final String? patientId;
  final bool isNewPatient;
  final DemoAuthService authService;
  final DemoSessionStore sessionStore;

  @override
  State<PatientSmsCodeScreen> createState() => _PatientSmsCodeScreenState();
}

class _PatientSmsCodeScreenState extends State<PatientSmsCodeScreen> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      setState(() => _codeError = 'Введите 6 цифр из SMS');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });

    final isVerified = widget.isNewPatient
        ? widget.authService.validateNewPatientSms(code)
        : widget.authService.authenticateRegisteredPatient(
                rawPhone: widget.phone,
                smsCode: code,
              ) !=
              null;

    if (!isVerified) {
      setState(() {
        _isSubmitting = false;
        _codeError = 'Неверный код подтверждения';
      });
      return;
    }

    if (widget.isNewPatient) {
      Navigator.of(context).pushAndRemoveUntil(
        appPageRoute<void>(
          context,
          builder: (_) => PatientNewDataScreen(
            phone: widget.phone,
            sessionStore: widget.sessionStore,
          ),
        ),
        (_) => false,
      );
      return;
    }

    final session = widget.authService.authenticateRegisteredPatient(
      rawPhone: widget.phone,
      smsCode: code,
    );
    if (session == null) {
      setState(() {
        _isSubmitting = false;
        _codeError = 'Неверный код подтверждения';
      });
      return;
    }

    await widget.sessionStore.saveSession(session);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      appPageRoute<void>(
        context,
        builder: (_) => PatientShellPlaceholder(
          sessionStore: widget.sessionStore,
          patientId: session.userId,
          phone: session.phone,
          patientName: session.name,
        ),
      ),
      (_) => false,
    );
  }

  void _clearCodeError() {
    if (_codeError != null) {
      setState(() => _codeError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    const statusHeight = 44.0;
    final contentHeight =
        MediaQuery.sizeOf(context).height -
        statusHeight -
        _SmsFigma.headerHeight;

    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _SmsFigma.background,
        body: Column(
          children: [
            SizedBox(height: statusHeight),
            _SmsHeader(
              title: 'Подтверждение номера',
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(
              height: contentHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: FocusManager.instance.primaryFocus?.unfocus,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 36,
                          child: _GradientHeadline('Введите код'),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 20,
                          child: Text(
                            'Отправили SMS на ${widget.phone}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _SmsFigma.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _FigmaSmsField(
                          controller: _codeController,
                          errorText: _codeError,
                          onChanged: (_) => _clearCodeError(),
                        ),
                        const SizedBox(height: 20),
                        _FigmaButton(
                          label: 'Продолжить',
                          backgroundColor: AppColors.brand,
                          textColor: AppColors.onBrand,
                          onPressed: _isSubmitting ? null : _submitCode,
                        ),
                        const SizedBox(height: 20),
                        _FigmaButton(
                          label: 'Изменить номер',
                          backgroundColor: AppColors.surface,
                          textColor: AppColors.brand,
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 20,
                          child: Text(
                            'Отправить новый код через 00:42',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _SmsFigma.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 116,
                          decoration: const BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: AppRadii.radius20,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                child: Text(
                                  'Не приходит SMS?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.brand,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: Text(
                                  'Проверьте номер и дождитесь повторной отправки. Код можно вставить из SMS.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _SmsFigma.secondaryText,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _FigmaSmsField extends StatelessWidget {
  const _FigmaSmsField({
    required this.controller,
    this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
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
              'Код из SMS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _SmsFigma.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(color: AppColors.brand),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: TextField(
              key: const ValueKey('patient.sms.input'),
              controller: controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: onChanged,
              maxLength: 6,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => null,
              style: _SmsFigma.inputText.copyWith(letterSpacing: 9),
              cursorColor: AppColors.brand,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Text(
              errorText ?? 'Код действует 5 минут',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _SmsFigma.secondaryText.copyWith(
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

class _SmsHeader extends StatelessWidget {
  const _SmsHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _SmsFigma.headerHeight,
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
      shaderCallback: (bounds) => _SmsFigma.headlineGradient.createShader(
        Rect.fromLTWH(0, 0, _SmsFigma.contentWidth, bounds.height),
      ),
      child: SizedBox(
        width: _SmsFigma.contentWidth,
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

abstract final class _SmsFigma {
  static const headerHeight = 56.0;
  static const contentWidth = 345.0;
  static const background = Color(0xFFF5F8FC);

  static const headlineGradient = LinearGradient(
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
    stops: [0, 0.13287, 0.21038, 0.26574, 0.32110, 0.36539, 0.46504, 0.55362],
  );

  static final secondaryText = AppTypography.small.copyWith(
    color: AppColors.secondary,
  );

  static final inputText = AppTypography.body.copyWith(color: AppColors.text);
}
