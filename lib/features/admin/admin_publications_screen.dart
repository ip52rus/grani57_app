import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/admin_demo_store.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_admin_models.dart';
import 'admin_widgets.dart';

enum _PublicationFilter { all, published, drafts }

class AdminPublicationsScreen extends StatefulWidget {
  const AdminPublicationsScreen({
    required this.store,
    super.key,
    this.embedded = false,
    this.onBackToHome,
  });

  final AdminDemoStore store;
  final bool embedded;
  final VoidCallback? onBackToHome;

  @override
  State<AdminPublicationsScreen> createState() =>
      _AdminPublicationsScreenState();
}

class _AdminPublicationsScreenState extends State<AdminPublicationsScreen> {
  _PublicationFilter _filter = _PublicationFilter.all;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final publications = widget.store.publications.where((item) {
        return switch (_filter) {
          _PublicationFilter.all => true,
          _PublicationFilter.published => item.isPublished,
          _PublicationFilter.drafts => !item.isPublished,
        };
      }).toList();
      return Column(
        children: [
          const SizedBox(height: 44),
          AdminScreenHeader(
            title: 'Новости и акции',
            onBack: widget.onBackToHome,
            trailing: const AdminBadge('АДМИН'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Публикации',
                    style: AppTypography.title.copyWith(color: AppColors.brand),
                  ),
                  Text(
                    'Карточки для карусели на главной',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    key: const ValueKey('admin.publications.create'),
                    label: '+ Создать публикацию',
                    onPressed: _create,
                  ),
                  const SizedBox(height: 20),
                  _PublicationFilterControl(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 20),
                  if (publications.isEmpty)
                    AdminCard(
                      child: Text(
                        'В этом разделе пока нет публикаций',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  else
                    for (
                      var index = 0;
                      index < publications.length;
                      index++
                    ) ...[
                      _PublicationCard(
                        publication: publications[index],
                        onEdit: () => _edit(publications[index]),
                        onDelete: () => _delete(publications[index]),
                      ),
                      if (index != publications.length - 1)
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

  Future<void> _create() async {
    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => AdminPublicationFormScreen(store: widget.store),
      ),
    );
  }

  Future<void> _edit(DemoPublication publication) async {
    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => AdminPublicationFormScreen(
          store: widget.store,
          publication: publication,
        ),
      ),
    );
  }

  Future<void> _delete(DemoPublication publication) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeletePublicationSheet(publication: publication),
    );
    if (confirmed == true) {
      await widget.store.deletePublication(publication.id);
    }
  }
}

class _PublicationFilterControl extends StatelessWidget {
  const _PublicationFilterControl({
    required this.selected,
    required this.onChanged,
  });

  final _PublicationFilter selected;
  final ValueChanged<_PublicationFilter> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.all(4),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius12,
    ),
    child: Row(
      children: [
        _segment('Все', _PublicationFilter.all),
        _segment('Опубликовано', _PublicationFilter.published),
        _segment('Черновики', _PublicationFilter.drafts),
      ],
    ),
  );

  Widget _segment(String label, _PublicationFilter value) => Expanded(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected == value ? AppColors.surface : Colors.transparent,
          borderRadius: AppRadii.radius12,
        ),
        child: Text(
          label,
          maxLines: 1,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: selected == value ? AppColors.brand : AppColors.secondary,
          ),
        ),
      ),
    ),
  );
}

class _PublicationCard extends StatelessWidget {
  const _PublicationCard({
    required this.publication,
    required this.onEdit,
    required this.onDelete,
  });

  final DemoPublication publication;
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
            _PublicationThumb(asset: publication.imageAsset),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publication.title,
                    style: AppTypography.label.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${publication.type == DemoPublicationType.promotion ? 'Акция' : 'Новость'} · ${publication.clinic.toLowerCase()}',
                    maxLines: 2,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AdminBadge(
                    publication.isPublished ? 'Опубликовано' : 'Черновик',
                    success: publication.isPublished,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                publication.period,
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            _SmallAction(label: 'Изменить', onPressed: onEdit),
            const SizedBox(width: 6),
            _SmallAction(label: 'Удалить', danger: true, onPressed: onDelete),
          ],
        ),
      ],
    ),
  );
}

class _PublicationThumb extends StatelessWidget {
  const _PublicationThumb({this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius12,
    child: SizedBox(
      width: 74,
      height: 90,
      child: asset == null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE1EBFC), Color(0xFFFFE8EC)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '57',
                style: AppTypography.heading.copyWith(color: AppColors.brand),
              ),
            )
          : Image.asset(asset!, fit: BoxFit.cover),
    ),
  );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
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

class AdminPublicationFormScreen extends StatefulWidget {
  const AdminPublicationFormScreen({
    required this.store,
    super.key,
    this.publication,
  });

  final AdminDemoStore store;
  final DemoPublication? publication;

  @override
  State<AdminPublicationFormScreen> createState() =>
      _AdminPublicationFormScreenState();
}

class _AdminPublicationFormScreenState
    extends State<AdminPublicationFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _information;
  late final TextEditingController _clinic;
  late final TextEditingController _period;
  late DemoPublicationType _type;
  late bool _published;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.publication != null;

  @override
  void initState() {
    super.initState();
    final item = widget.publication;
    _title = TextEditingController(text: item?.title);
    _description = TextEditingController(text: item?.description);
    _information = TextEditingController(text: item?.information);
    _clinic = TextEditingController(text: item?.clinic ?? 'Все клиники');
    _period = TextEditingController(text: item?.period);
    _type = item?.type ?? DemoPublicationType.news;
    _published = item?.isPublished ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _information.dispose();
    _clinic.dispose();
    _period.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            const SizedBox(height: 44),
            AdminScreenHeader(
              title: _editing ? 'Редактирование' : 'Новая публикация',
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
                        _editing ? 'Изменить публикацию' : 'Создать публикацию',
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _editing
                            ? 'Измените карточку и сохраните'
                            : 'Заполните шаблон карточки для пациентов',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _PublicationTypeControl(
                        value: _type,
                        onChanged: (value) => setState(() => _type = value),
                      ),
                      const SizedBox(height: 20),
                      _ImagePickerDemo(hasImage: _editing),
                      const SizedBox(height: 14),
                      AdminFormField(
                        label: 'Заголовок',
                        hint: 'Введите заголовок до 60 символов',
                        helper: 'Главная строка карточки',
                        controller: _title,
                      ),
                      const SizedBox(height: 14),
                      AdminFormField(
                        label: 'Описание',
                        hint: 'Коротко опишите публикацию до 120 символов',
                        helper: 'Показывается под заголовком',
                        maxLines: 3,
                        controller: _description,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Информационный блок',
                        style: AppTypography.heading.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AdminFormField(
                        label: 'Дополнительная информация',
                        hint: 'Условия, даты и важные детали',
                        maxLines: 4,
                        controller: _information,
                      ),
                      const SizedBox(height: 14),
                      AdminFormField(
                        label: 'Клиника',
                        hint: 'Все клиники',
                        controller: _clinic,
                      ),
                      const SizedBox(height: 14),
                      AdminFormField(
                        label: 'Период',
                        hint: 'Например, 10–30 сентября 2026',
                        controller: _period,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile.adaptive(
                        value: _published,
                        onChanged: (value) =>
                            setState(() => _published = value),
                        activeTrackColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Опубликовать сразу',
                          style: AppTypography.label.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        subtitle: Text(
                          _published
                              ? 'Публикация появится у пациентов'
                              : 'Сохранить как черновик',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
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
                key: const ValueKey('admin.publication.save'),
                label: _editing
                    ? 'Сохранить изменения'
                    : (_published ? 'Опубликовать' : 'Сохранить черновик'),
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
      setState(() => _error = 'Заполните заголовок и описание');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final existing = widget.publication;
    await widget.store.savePublication(
      DemoPublication(
        id:
            existing?.id ??
            'publication_${DateTime.now().microsecondsSinceEpoch}',
        type: _type,
        title: _title.text.trim(),
        description: _description.text.trim(),
        information: _information.text.trim(),
        clinic: _clinic.text.trim(),
        period: _period.text.trim(),
        isPublished: _published,
        imageAsset: existing?.imageAsset,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _PublicationTypeControl extends StatelessWidget {
  const _PublicationTypeControl({required this.value, required this.onChanged});

  final DemoPublicationType value;
  final ValueChanged<DemoPublicationType> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius12,
      border: Border.all(color: AppColors.soft),
    ),
    child: Row(
      children: [
        _item('Новость', DemoPublicationType.news),
        _item('Акция', DemoPublicationType.promotion),
      ],
    ),
  );

  Widget _item(String label, DemoPublicationType type) => Expanded(
    child: GestureDetector(
      onTap: () => onChanged(type),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: value == type ? AppColors.brand : AppColors.surface,
          borderRadius: AppRadii.radius12,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: value == type ? AppColors.onBrand : AppColors.brand,
          ),
        ),
      ),
    ),
  );
}

class _ImagePickerDemo extends StatefulWidget {
  const _ImagePickerDemo({required this.hasImage});

  final bool hasImage;

  @override
  State<_ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<_ImagePickerDemo> {
  late bool _selected = widget.hasImage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Изображение *',
        style: AppTypography.caption.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => setState(() => _selected = true),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: AppRadii.radius12,
        child: Container(
          height: _selected ? 140 : 184,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.radius12,
            border: Border.all(color: AppColors.border),
          ),
          child: _selected
              ? Row(
                  children: [
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('banner-publication.jpg · 1600×900 px'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selected = false),
                      child: const Text('Заменить'),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 36, color: AppColors.brand),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте изображение',
                      style: AppTypography.label.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JPG, PNG или WebP · до 10 МБ\n1600×900 px рекомендуется',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}

class _DeletePublicationSheet extends StatelessWidget {
  const _DeletePublicationSheet({required this.publication});

  final DemoPublication publication;

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
            'Удалить публикацию?',
            style: AppTypography.heading.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            '«${publication.title}» исчезнет из карусели пациентов. Восстановить публикацию после удаления нельзя.',
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
              'Перед удалением убедитесь, что акция завершена.',
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            key: const ValueKey('admin.publication.confirmDelete'),
            label: 'Удалить публикацию',
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
