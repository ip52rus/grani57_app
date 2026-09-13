import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/components/app_text_field.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../development_demo/employee_auth_placeholder.dart';
import '../../mock_data/demo_asset_paths.dart';
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
  final _phoneController = TextEditingController(text: '+7 ');
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
    final normalizedPhone = normalizeRussianPhone(_phoneController.text);
    if (normalizedPhone.length != 11 || !normalizedPhone.startsWith('7')) {
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

    final lookup = _authService.lookupPatientByPhone(_phoneController.text);
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
              phone: _phoneController.text,
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
                      'Вход',
                      style: AppTypography.title.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x12),
                    Text(
                      'Введите номер телефона, чтобы получить код подтверждения',
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x32),
                    AppTextField(
                      label: 'Телефон',
                      controller: _phoneController,
                      hintText: '+7 999 000-00-01',
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [RussianPhoneInputFormatter()],
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
                    const SizedBox(height: AppSpacing.x20),
                    AppButton(
                      label: 'Получить код',
                      semanticLabel: 'Получить код подтверждения',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitPhone,
                    ),
                    const SizedBox(height: AppSpacing.x16),
                    TextButton(
                      onPressed: _openEmployeePlaceholder,
                      child: Text(
                        'Вход для сотрудников',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                    const SizedBox(height: 96),
                    Text(
                      'Development demo: вход доступен только для трёх зарегистрированных пациентов',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
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
