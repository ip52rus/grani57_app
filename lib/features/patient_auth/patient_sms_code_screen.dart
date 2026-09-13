import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/components/app_text_field.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../development_demo/patient_shell_placeholder.dart';
import '../../mock_data/demo_asset_paths.dart';

class PatientSmsCodeScreen extends StatefulWidget {
  const PatientSmsCodeScreen({
    required this.phone,
    required this.patientId,
    required this.authService,
    required this.sessionStore,
    super.key,
  });

  final String phone;
  final String patientId;
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
    if (code.length != 6) {
      setState(() => _codeError = 'Введите 6 цифр из SMS');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _codeError = null;
    });

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
      MaterialPageRoute<void>(
        builder: (_) =>
            PatientShellPlaceholder(sessionStore: widget.sessionStore),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.x24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Назад',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          DemoAssetPaths.back,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        DemoAssetPaths.logoPrimary,
                        width: 140,
                        height: 41,
                      ),
                    ),
                    const SizedBox(height: 72),
                    Text(
                      'Код подтверждения',
                      style: AppTypography.title.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x12),
                    Text(
                      'Введите код из SMS, отправленный на ${widget.phone}',
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x32),
                    AppTextField(
                      label: 'Код из SMS',
                      controller: _codeController,
                      hintText: '000000',
                      errorText: _codeError,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (_) {
                        if (_codeError != null) {
                          setState(() => _codeError = null);
                        }
                      },
                      onSubmitted: (_) => _submitCode(),
                    ),
                    const SizedBox(height: AppSpacing.x20),
                    AppButton(
                      label: 'Войти',
                      semanticLabel: 'Войти по коду подтверждения',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitCode,
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Изменить номер',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
