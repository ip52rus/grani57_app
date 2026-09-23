import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/admin_demo_store.dart';
import '../../core/mock_runtime/doctor_access_store.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_admin_models.dart';
import 'admin_doctor_access_screen.dart';
import 'admin_widgets.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({
    required this.store,
    required this.accessStore,
    super.key,
    this.embedded = false,
    this.onBackToHome,
  });

  final AdminDemoStore store;
  final DoctorAccessStore accessStore;
  final bool embedded;
  final VoidCallback? onBackToHome;

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final normalized = _query.trim().toLowerCase();
      final doctors = widget.store.doctors.where((doctor) {
        return normalized.isEmpty ||
            doctor.name.toLowerCase().contains(normalized) ||
            doctor.description.toLowerCase().contains(normalized);
      }).toList();
      return Column(
        children: [
          const SizedBox(height: 44),
          AdminScreenHeader(title: 'Врачи', onBack: widget.onBackToHome),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminGradientTitle('Врачи и услуги'),
                  Text(
                    'Профили, которые видят пациенты при записи',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    key: const ValueKey('admin.doctors.create'),
                    label: '+ Добавить врача',
                    onPressed: _create,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const ValueKey('admin.doctors.search'),
                    onChanged: (value) => setState(() => _query = value),
                    enableInteractiveSelection: false,
                    magnifierConfiguration: TextMagnifierConfiguration.disabled,
                    style: AppTypography.small.copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Поиск по имени или специальности',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: AppColors.secondary),
                            ),
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: _border(AppColors.border),
                      enabledBorder: _border(AppColors.border),
                      focusedBorder: _border(AppColors.brand),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (doctors.isEmpty)
                    AdminCard(
                      child: Text(
                        'Врачи не найдены',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  else
                    for (var index = 0; index < doctors.length; index++) ...[
                      _DoctorCard(
                        doctor: doctors[index],
                        onEdit: () => _edit(doctors[index]),
                        onDelete: () => _delete(doctors[index]),
                      ),
                      if (index != doctors.length - 1)
                        const SizedBox(height: 18),
                    ],
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: AppRadii.radius12,
    borderSide: BorderSide(color: color),
  );

  Future<void> _create() async {
    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => AdminDoctorFormScreen(
          store: widget.store,
          accessStore: widget.accessStore,
        ),
      ),
    );
  }

  Future<void> _edit(DemoDoctorProfile doctor) async {
    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => AdminDoctorFormScreen(
          store: widget.store,
          accessStore: widget.accessStore,
          doctor: doctor,
        ),
      ),
    );
  }

  Future<void> _delete(DemoDoctorProfile doctor) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteDoctorSheet(doctor: doctor),
    );
    if (confirmed == true) {
      await widget.store.deleteDoctor(doctor.id);
      await widget.accessStore.remove(doctor.id);
    }
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onEdit,
    required this.onDelete,
  });

  final DemoDoctorProfile doctor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorPhoto(doctor: doctor, size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: AppTypography.label.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                '${doctor.services.length} услуги отмечено',
                style: AppTypography.caption.copyWith(color: AppColors.brand),
              ),
            ),
            _DoctorAction(label: 'Изменить', onPressed: onEdit),
            const SizedBox(width: 6),
            _DoctorAction(label: 'Удалить', danger: true, onPressed: onDelete),
          ],
        ),
      ],
    ),
  );
}

class _DoctorPhoto extends StatelessWidget {
  const _DoctorPhoto({required this.doctor, required this.size});

  final DemoDoctorProfile doctor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = doctor.photoAsset;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.soft,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: asset == null
          ? Center(
              child: Text(
                '57',
                style: AppTypography.label.copyWith(color: AppColors.brand),
              ),
            )
          : Image.asset(asset, fit: BoxFit.cover),
    );
  }
}

class _DoctorAction extends StatelessWidget {
  const _DoctorAction({
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: danger ? AppColors.surface : AppColors.soft,
        foregroundColor: danger ? AppColors.accent : AppColors.brand,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radius12,
          side: danger
              ? const BorderSide(color: Color(0xFFFF8A94))
              : BorderSide.none,
        ),
      ),
      child: Text(label, style: AppTypography.caption),
    ),
  );
}

class AdminDoctorFormScreen extends StatefulWidget {
  const AdminDoctorFormScreen({
    required this.store,
    required this.accessStore,
    super.key,
    this.doctor,
  });

  final AdminDemoStore store;
  final DoctorAccessStore accessStore;
  final DemoDoctorProfile? doctor;

  @override
  State<AdminDoctorFormScreen> createState() => _AdminDoctorFormScreenState();
}

class _AdminDoctorFormScreenState extends State<AdminDoctorFormScreen> {
  static const _services = <String>[
    'Лечение зубов',
    'Консультация стоматолога',
    'Профессиональная гигиена',
    'Хирургия',
    'Имплантация',
    'Ортодонтия',
    'Протезирование',
    'Отбеливание',
    'Детская стоматология',
  ];

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final Set<String> _selectedServices;
  String? _photoAsset;
  String? _error;
  bool _saving = false;

  bool get _editing => widget.doctor != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.doctor?.name);
    _description = TextEditingController(text: widget.doctor?.description);
    _selectedServices = {...?widget.doctor?.services};
    _photoAsset = widget.doctor?.photoAsset;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
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
                title: _editing ? 'Редактирование врача' : 'Новый врач',
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
                          _editing ? 'Профиль врача' : 'Добавить врача',
                        ),
                        Text(
                          _editing
                              ? 'Данные, которые видят пациенты'
                              : 'Создайте карточку специалиста',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        if (doctor != null) ...[
                          const SizedBox(height: 16),
                          _AccessEntryCard(
                            doctor: doctor,
                            accessStore: widget.accessStore,
                          ),
                        ],
                        const SizedBox(height: 20),
                        _PhotoEditor(
                          doctor: DemoDoctorProfile(
                            id: doctor?.id ?? 'new',
                            name: _name.text,
                            description: _description.text,
                            services: _selectedServices.toList(),
                            photoAsset: _photoAsset,
                          ),
                          onPickDemo: () => setState(
                            () => _photoAsset =
                                'assets/images/doctors/doctor_any_specialist.png',
                          ),
                        ),
                        const SizedBox(height: 20),
                        AdminFormField(
                          label: 'ФИО',
                          hint: 'Введите имя и фамилию',
                          helper: 'Показывается в списке врачей',
                          controller: _name,
                        ),
                        const SizedBox(height: 14),
                        AdminFormField(
                          label: 'Описание для пациентов',
                          hint:
                              'Специальность, стаж, квалификация и достижения',
                          helper: 'Например: Стоматолог-терапевт · стаж 12 лет',
                          maxLines: 4,
                          controller: _description,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Оказываемые услуги',
                          style: AppTypography.heading.copyWith(
                            color: AppColors.brand,
                          ),
                        ),
                        Text(
                          'Отметьте всё, на что можно записаться к этому врачу',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final service in _services) ...[
                          _ServiceCheckbox(
                            label: service,
                            value: _selectedServices.contains(service),
                            onChanged: (value) => setState(() {
                              if (value) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.remove(service);
                              }
                            }),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_error != null)
                          Text(
                            _error!,
                            style: AppTypography.small.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: AppButton(
                  key: const ValueKey('admin.doctor.save'),
                  label: _editing ? 'Сохранить изменения' : 'Добавить врача',
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _description.text.trim().isEmpty) {
      setState(() => _error = 'Заполните ФИО и описание врача');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await widget.store.saveDoctor(
      DemoDoctorProfile(
        id:
            widget.doctor?.id ??
            'doctor_${DateTime.now().microsecondsSinceEpoch}',
        name: _name.text.trim(),
        description: _description.text.trim(),
        services: _selectedServices.toList()..sort(),
        photoAsset: _photoAsset,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _AccessEntryCard extends StatelessWidget {
  const _AccessEntryCard({required this.doctor, required this.accessStore});

  final DemoDoctorProfile doctor;
  final DoctorAccessStore accessStore;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: accessStore,
    builder: (context, _) {
      final access = accessStore.accessForDoctor(doctor.id);
      return AdminCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          key: const ValueKey('admin.doctor.openAccess'),
          onTap: () => Navigator.of(context).push<void>(
            appPageRoute<void>(
              context,
              builder: (_) => AdminDoctorAccessScreen(
                doctor: doctor,
                accessStore: accessStore,
              ),
            ),
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: AppRadii.radius20,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Доступ в приложение',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        access == null
                            ? 'Логин и пароль ещё не созданы'
                            : access.isEnabled
                            ? 'Доступ включён · ${access.login}'
                            : 'Доступ отключён · ${access.login}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '›',
                  style: AppTypography.heading.copyWith(
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PhotoEditor extends StatelessWidget {
  const _PhotoEditor({required this.doctor, required this.onPickDemo});

  final DemoDoctorProfile doctor;
  final VoidCallback onPickDemo;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Фотография врача *',
        style: AppTypography.caption.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 8),
      if (doctor.photoAsset == null)
        InkWell(
          onTap: onPickDemo,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: AppRadii.radius12,
          child: Container(
            height: 118,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radius12,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: AppTypography.title.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добавить фотографию',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG или WebP · до 5 МБ',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      else
        Row(
          children: [
            _DoctorPhoto(doctor: doctor, size: 92),
            const SizedBox(width: 20),
            Expanded(
              child: AppButton(
                label: 'Заменить фотографию',
                variant: AppButtonVariant.secondary,
                onPressed: onPickDemo,
              ),
            ),
          ],
        ),
      const SizedBox(height: 8),
      Text(
        'JPG, PNG или WebP · квадрат от 800×800 px · до 5 МБ',
        style: AppTypography.caption.copyWith(color: AppColors.secondary),
      ),
    ],
  );
}

class _ServiceCheckbox extends StatelessWidget {
  const _ServiceCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: AppRadii.radius12,
    child: CheckboxListTile(
      value: value,
      onChanged: (next) => onChanged(next ?? false),
      title: Text(
        label,
        style: AppTypography.small.copyWith(color: AppColors.text),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      activeColor: AppColors.brand,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

class _DeleteDoctorSheet extends StatelessWidget {
  const _DeleteDoctorSheet({required this.doctor});

  final DemoDoctorProfile doctor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Удалить врача?',
            style: AppTypography.heading.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            '${doctor.name} исчезнет из выбора врача. Уже созданные записи и история лечения сохранятся.',
            style: AppTypography.small.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: AppRadii.radius12,
            ),
            child: Text(
              'Проверьте будущие записи врача перед удалением.',
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            key: const ValueKey('admin.doctor.confirmDelete'),
            label: 'Удалить врача',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Отмена',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    ),
  );
}
