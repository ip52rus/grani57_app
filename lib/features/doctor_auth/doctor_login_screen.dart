import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../core/mock_runtime/user_role.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../../mock_data/demo_employees.dart';
import '../admin/admin_shell_screen.dart';
import '../doctor_schedule/doctor_schedule_screen.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key, this.authService, this.sessionStore});

  final DemoAuthService? authService;
  final DemoSessionStore? sessionStore;

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  late final DemoAuthService _authService;
  late final DemoSessionStore _sessionStore;
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? DemoAuthService();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
    _loginController = TextEditingController(
      text: DemoEmployees.doctor.username ?? DemoEmployees.doctor.login,
    );
    _passwordController = TextEditingController(
      text: DemoEmployees.doctor.password,
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    final session = await _authService.authenticateEmployee(
      login: _loginController.text,
      password: _passwordController.text,
    );
    if (session == null) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Неверный логин или пароль';
        });
      }
      return;
    }

    await _sessionStore.saveSession(session);
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil<void>(
      appPageRoute<void>(
        context,
        builder: (_) => switch (session.role) {
          UserRole.doctor => DoctorScheduleScreen(
            sessionStore: _sessionStore,
            doctorId: session.userId,
            doctorName: session.name,
          ),
          UserRole.administrator => AdminShellScreen(
            store: _authService.adminStore,
            accessStore: _authService.doctorAccessStore,
            sessionStore: _sessionStore,
          ),
          _ => DoctorLoginScreen(
            authService: _authService,
            sessionStore: _sessionStore,
          ),
        },
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: 44),
              const _DoctorLoginHeader(),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: FocusManager.instance.primaryFocus?.unfocus,
                  onVerticalDragStart: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset(
                            DemoAssetPaths.logoPrimaryClean,
                            width: 140,
                            height: 40.13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _DoctorLoginTitle(),
                        const SizedBox(height: 20),
                        Text(
                          'Войдите с учётной записью клиники',
                          style: AppTypography.small.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DoctorLoginField(
                          key: const ValueKey('doctor.login.field'),
                          label: 'Логин',
                          helper: 'Логин выдаёт администратор клиники',
                          controller: _loginController,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => _clearError(),
                        ),
                        const SizedBox(height: 20),
                        _DoctorLoginField(
                          key: const ValueKey('doctor.password.field'),
                          label: 'Пароль',
                          helper: _error,
                          controller: _passwordController,
                          obscureText: true,
                          isError: _error != null,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => _clearError(),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          key: const ValueKey('doctor.login.submit'),
                          label: 'Войти',
                          isLoading: _submitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Нет доступа или забыли пароль?\n'
                          'Обратитесь к администратору клиники.',
                          style: AppTypography.small.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _PersonalScheduleCard(),
                      ],
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

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }
}

class _DoctorLoginHeader extends StatelessWidget {
  const _DoctorLoginHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Вход для сотрудников',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
      ),
    ),
  );
}

class _DoctorLoginTitle extends StatelessWidget {
  const _DoctorLoginTitle();

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => const LinearGradient(
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
      stops: [0, .15791, .25003, .31583, .38162, .43426, .55270, .65797],
    ).createShader(bounds),
    child: Text('Кабинет врача', style: AppTypography.title),
  );
}

class _DoctorLoginField extends StatelessWidget {
  const _DoctorLoginField({
    required this.label,
    required this.controller,
    required this.textInputAction,
    required this.onChanged,
    this.helper,
    this.obscureText = false,
    this.isError = false,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String? helper;
  final TextEditingController controller;
  final bool obscureText;
  final bool isError;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTypography.small.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 56,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          enableSuggestions: false,
          autocorrect: false,
          enableInteractiveSelection: false,
          magnifierConfiguration: TextMagnifierConfiguration.disabled,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: AppTypography.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(16),
            border: _border(isError ? AppColors.error : AppColors.border),
            enabledBorder: _border(
              isError ? AppColors.error : AppColors.border,
            ),
            focusedBorder: _border(
              isError ? AppColors.error : AppColors.brand,
              width: 1.5,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 20,
        child: Text(
          helper ?? '',
          maxLines: 1,
          style: AppTypography.small.copyWith(
            color: isError ? AppColors.error : AppColors.secondary,
          ),
        ),
      ),
    ],
  );

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadii.radius12,
        borderSide: BorderSide(color: color, width: width),
      );
}

class _PersonalScheduleCard extends StatelessWidget {
  const _PersonalScheduleCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(DemoAssetPaths.doctorLock, width: 24, height: 24),
        const SizedBox(height: 12),
        Text(
          'Персональное расписание',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          'После входа вы увидите свои приёмы\n'
          'и данные пациентов, записанных к вам.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}
