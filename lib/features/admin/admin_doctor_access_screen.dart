import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/doctor_access_store.dart';
import '../../mock_data/demo_admin_models.dart';
import 'admin_widgets.dart';

class AdminDoctorAccessScreen extends StatefulWidget {
  const AdminDoctorAccessScreen({
    required this.doctor,
    required this.accessStore,
    super.key,
  });

  final DemoDoctorProfile doctor;
  final DoctorAccessStore accessStore;

  @override
  State<AdminDoctorAccessScreen> createState() =>
      _AdminDoctorAccessScreenState();
}

class _AdminDoctorAccessScreenState extends State<AdminDoctorAccessScreen> {
  late final TextEditingController _login;
  late final TextEditingController _password;
  String? _error;
  bool _saving = false;

  DemoDoctorAccess? get _access =>
      widget.accessStore.accessForDoctor(widget.doctor.id);

  @override
  void initState() {
    super.initState();
    final access = _access;
    _login = TextEditingController(text: access?.login);
    _password = TextEditingController(text: access?.password);
  }

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.accessStore,
    builder: (context, _) {
      final access = _access;
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
                AdminScreenHeader(
                  title: 'Доступ врача',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: FocusManager.instance.primaryFocus?.unfocus,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminGradientTitle(
                            access == null
                                ? 'Доступ в приложение'
                                : 'Доступ создан',
                          ),
                          const SizedBox(height: 2),
                          Text(
                            access == null
                                ? 'Создайте логин и пароль для ${widget.doctor.name}'
                                : '${widget.doctor.name} может войти в приложение',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          if (access != null) ...[
                            const SizedBox(height: 20),
                            _AccessStatus(enabled: access.isEnabled),
                          ],
                          const SizedBox(height: 28),
                          AdminFormField(
                            label: 'Логин',
                            hint: 'Задайте логин',
                            helper: access == null
                                ? 'Например: doctor.smirnova'
                                : 'Изменения логина применятся после сохранения',
                            controller: _login,
                            onChanged: (_) => _clearError(),
                          ),
                          const SizedBox(height: 20),
                          AdminFormField(
                            label: 'Пароль',
                            hint: 'Задайте пароль',
                            helper: access == null
                                ? 'Не менее 8 символов'
                                : 'Передайте данные врачу безопасным способом',
                            controller: _password,
                            onChanged: (_) => _clearError(),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.soft,
                              borderRadius: AppRadii.radius12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  access == null
                                      ? 'Данные для входа'
                                      : 'Управление доступом',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.brand,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  access == null
                                      ? 'После создания передайте логин и пароль врачу безопасным способом.'
                                      : 'Логин и пароль можно изменить, а доступ — отключить в любой момент.',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: AppTypography.small.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: access == null
                      ? AppButton(
                          key: const ValueKey('admin.doctorAccess.create'),
                          label: 'Создать доступ',
                          isLoading: _saving,
                          onPressed: _save,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton(
                              key: const ValueKey('admin.doctorAccess.save'),
                              label: 'Изменить пароль',
                              isLoading: _saving,
                              onPressed: _save,
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              key: const ValueKey('admin.doctorAccess.toggle'),
                              onPressed: () => _setEnabled(!access.isEnabled),
                              style: TextButton.styleFrom(
                                overlayColor: Colors.transparent,
                                foregroundColor: access.isEnabled
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                              child: Text(
                                access.isEnabled
                                    ? 'Отключить доступ'
                                    : 'Включить доступ',
                              ),
                            ),
                            if (!access.isEnabled)
                              TextButton(
                                key: const ValueKey(
                                  'admin.doctorAccess.remove',
                                ),
                                onPressed: _remove,
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                  foregroundColor: AppColors.error,
                                ),
                                child: const Text('Удалить доступ'),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Future<void> _save() async {
    final login = _login.text.trim();
    final password = _password.text;
    if (login.isEmpty) {
      setState(() => _error = 'Задайте логин');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Пароль должен содержать не менее 8 символов');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.accessStore.save(
        DemoDoctorAccess(
          doctorId: widget.doctor.id,
          login: login,
          password: password,
          isEnabled: _access?.isEnabled ?? true,
        ),
      );
    } on ArgumentError catch (error) {
      if (mounted) {
        setState(() => _error = error.message?.toString() ?? '$error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    await widget.accessStore.setEnabled(widget.doctor.id, enabled);
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Удалить доступ?'),
        content: Text(
          '${widget.doctor.name} больше не сможет войти в приложение.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.accessStore.remove(widget.doctor.id);
    _login.clear();
    _password.clear();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }
}

class _AccessStatus extends StatelessWidget {
  const _AccessStatus({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: enabled ? AppColors.successBg : const Color(0xFFFFE8EA),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      enabled ? 'Доступ включён' : 'Доступ отключён',
      style: AppTypography.caption.copyWith(
        color: enabled ? AppColors.success : AppColors.error,
      ),
    ),
  );
}
