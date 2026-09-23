import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/design_system/gradients/app_gradients.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../development_demo/patient_shell_placeholder.dart';
import 'birth_date_input.dart';

class PatientNewDataScreen extends StatefulWidget {
  const PatientNewDataScreen({
    required this.phone,
    required this.sessionStore,
    super.key,
  });

  final String phone;
  final DemoSessionStore sessionStore;

  @override
  State<PatientNewDataScreen> createState() => _PatientNewDataScreenState();
}

class _PatientNewDataScreenState extends State<PatientNewDataScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _birthDateController = TextEditingController();
  final _birthDateFocusNode = FocusNode();
  String? _nameError;
  String? _birthDateError;
  bool _isSubmitting = false;

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      BirthDateInput.isCompleteValid(_birthDateDigits);

  String get _birthDateDigits =>
      BirthDateInput.digits(_birthDateController.text);

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _birthDateController.dispose();
    _birthDateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _finishProfile() async {
    if (_isSubmitting) {
      return;
    }

    final name = _nameController.text.trim();
    final nameIsValid =
        name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).length >= 2;
    final birthDateIsValid = BirthDateInput.isCompleteValid(_birthDateDigits);
    if (!nameIsValid || !birthDateIsValid) {
      setState(() {
        _nameError = nameIsValid ? null : 'Укажите фамилию и имя';
        _birthDateError = birthDateIsValid
            ? null
            : 'Введите существующую дату рождения';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    final session = DemoAuthService().createNewPatientSession(
      rawPhone: widget.phone,
      name: name,
    );
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

  @override
  Widget build(BuildContext context) {
    const statusHeight = 44.0;
    const headerHeight = 56.0;
    final contentHeight =
        MediaQuery.sizeOf(context).height - statusHeight - headerHeight;

    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _NewDataFigma.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: statusHeight),
              const _RegistrationHeader(),
              SizedBox(
                height: contentHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: FocusManager.instance.primaryFocus?.unfocus,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 72,
                            child: _RegistrationHeadline(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 20,
                            child: Text(
                              'Эти данные понадобятся для записи на приём.',
                              style: _NewDataFigma.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RegistrationTextField(
                            fieldKey: const ValueKey(
                              'patient.new_data.name.input',
                            ),
                            label: 'Фамилия, имя, отчество',
                            hintText: 'Петрова Мария Сергеевна',
                            helperText: _nameError ?? 'Отчество — при наличии',
                            helperColor: _nameError == null
                                ? AppColors.secondary
                                : AppColors.error,
                            hasError: _nameError != null,
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              } else {
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _BirthDateField(
                            controller: _birthDateController,
                            focusNode: _birthDateFocusNode,
                            errorText: _birthDateError,
                            onChanged: (_) {
                              setState(() => _birthDateError = null);
                            },
                          ),
                          const SizedBox(height: 16),
                          _VerifiedPhoneCard(phone: widget.phone),
                          const SizedBox(height: 16),
                          _RegistrationButton(
                            label: 'Продолжить',
                            enabled: _canContinue && !_isSubmitting,
                            onPressed: _finishProfile,
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

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Регистрация', style: AppTypography.label),
        ),
      ),
    );
  }
}

class _RegistrationHeadline extends StatelessWidget {
  const _RegistrationHeadline();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppGradients.brandHeader.createShader(
        Rect.fromLTWH(0, 0, 345, bounds.height),
      ),
      child: const Text('Давайте\nпознакомимся', style: AppTypography.title),
    );
  }
}

class _RegistrationTextField extends StatelessWidget {
  const _RegistrationTextField({
    required this.fieldKey,
    required this.label,
    required this.hintText,
    required this.helperText,
    required this.helperColor,
    required this.hasError,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.textInputAction,
    required this.textCapitalization,
    required this.autofillHints,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final String hintText;
  final String helperText;
  final Color helperColor;
  final bool hasError;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String> autofillHints;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Text(label, style: _NewDataFigma.secondaryText),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(15, 0, 16, 0),
            child: TextField(
              key: fieldKey,
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              autofillHints: autofillHints,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              onChanged: onChanged,
              style: _NewDataFigma.inputText,
              cursorColor: AppColors.brand,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: _NewDataFigma.inputText.copyWith(
                  color: AppColors.secondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Text(
              helperText,
              style: _NewDataFigma.secondaryText.copyWith(color: helperColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Text('Дата рождения', style: _NewDataFigma.secondaryText),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(
                color: errorText == null ? AppColors.border : AppColors.error,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: TextField(
              key: const ValueKey('patient.new_data.birth_date.input'),
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.birthday],
              inputFormatters: [BirthDateInputFormatter()],
              onChanged: onChanged,
              style: _NewDataFigma.inputText,
              cursorColor: AppColors.brand,
              decoration: InputDecoration(
                hintText: 'ДД.ММ.ГГГГ',
                hintStyle: _NewDataFigma.inputText.copyWith(
                  color: AppColors.secondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Text(
              errorText ?? 'ДД.ММ.ГГГГ',
              style: _NewDataFigma.secondaryText.copyWith(
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

class _VerifiedPhoneCard extends StatelessWidget {
  const _VerifiedPhoneCard({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: AppColors.soft,
        borderRadius: AppRadii.radius20,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
            child: Text(
              'Телефон подтверждён',
              style: AppTypography.caption.copyWith(color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: Text(
              phone,
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationButton extends StatelessWidget {
  const _RegistrationButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = enabled ? AppColors.brand : AppColors.soft;
    final foreground = enabled ? AppColors.onBrand : AppColors.secondary;
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(background),
          foregroundColor: WidgetStatePropertyAll(foreground),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.radius12),
          ),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: foreground),
        ),
      ),
    );
  }
}

abstract final class _NewDataFigma {
  static const background = Color(0xFFF5F8FC);

  static final secondaryText = AppTypography.small.copyWith(
    color: AppColors.secondary,
  );
  static final inputText = AppTypography.body.copyWith(color: AppColors.text);
}
