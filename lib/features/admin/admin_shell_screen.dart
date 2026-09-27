import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/admin_demo_store.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../core/mock_runtime/doctor_access_store.dart';
import '../../core/navigation/app_page_route.dart';
import '../patient_auth/patient_phone_login_screen.dart';
import 'admin_doctors_screen.dart';
import 'admin_publications_screen.dart';
import 'admin_widgets.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({
    super.key,
    this.store,
    this.accessStore,
    this.sessionStore,
    this.initialTab = 0,
  });

  final AdminDemoStore? store;
  final DoctorAccessStore? accessStore;
  final DemoSessionStore? sessionStore;
  final int initialTab;

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  late final AdminDemoStore _store;
  late final DoctorAccessStore _accessStore;
  late final DemoSessionStore _sessionStore;
  late int _tab;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? AdminDemoStore();
    _accessStore = widget.accessStore ?? DoctorAccessStore();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
    _tab = widget.initialTab.clamp(0, 2);
    _ready = Future.wait([_store.initialize(), _accessStore.initialize()]);
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: FutureBuilder<void>(
          future: _ready,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              );
            }
            return Column(
              children: [
                Expanded(child: _activeScreen()),
                AdminBottomNavigation(index: _tab, onChanged: _selectTab),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _activeScreen() => switch (_tab) {
    0 => _AdminHome(
      store: _store,
      onSelectTab: _selectTab,
      onSignOut: _signOut,
    ),
    1 => AdminPublicationsScreen(
      store: _store,
      embedded: true,
      onBackToHome: () => _selectTab(0),
    ),
    _ => AdminDoctorsScreen(
      store: _store,
      accessStore: _accessStore,
      embedded: true,
      onBackToHome: () => _selectTab(0),
    ),
  };

  void _selectTab(int tab) => setState(() => _tab = tab);

  Future<void> _signOut() async {
    await _sessionStore.clearSession();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil<void>(
      appPageRoute<void>(
        context,
        builder: (_) => PatientPhoneLoginScreen(sessionStore: _sessionStore),
      ),
      (_) => false,
    );
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome({
    required this.store,
    required this.onSelectTab,
    required this.onSignOut,
  });

  final AdminDemoStore store;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Column(
      children: [
        const SizedBox(height: 44),
        AdminScreenHeader(
          title: 'АДМИНКА',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdminBadge('АДМИН'),
              const SizedBox(width: 8),
              TextButton(
                key: const ValueKey('admin.signOut'),
                onPressed: onSignOut,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  overlayColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 40),
                ),
                child: const Text('Выйти'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminGradientTitle('Управление'),
                const SizedBox(height: 4),
                Text(
                  'Добрый день, Ирина',
                  style: AppTypography.body.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Изменения сразу попадут в приложение пациентов',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        count: store.publications
                            .where((item) => item.isPublished)
                            .length,
                        label: 'активные публикации',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CountCard(
                        count: store.doctors.length,
                        label: 'врача в приложении',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _AdminHomeLink(
                  key: const ValueKey('admin.home.publications'),
                  asset: 'assets/icons/documents/document_file.svg',
                  title: 'Новости и акции',
                  subtitle: 'Создавайте карточки для карусели на главной',
                  footer:
                      '${store.publications.where((e) => e.isPublished).length} '
                      'опубликовано · '
                      '${store.publications.where((e) => !e.isPublished).length} '
                      'черновик',
                  onTap: () => onSelectTab(1),
                ),
                const SizedBox(height: 20),
                _AdminHomeLink(
                  key: const ValueKey('admin.home.doctors'),
                  asset:
                      'assets/icons/navigation/nav_profile_inactive_clean.svg',
                  title: 'Врачи и услуги',
                  subtitle: 'Редактируйте профили и отмечайте доступные услуги',
                  footer: '${_serviceCount(store)} услуг для фильтрации записи',
                  onTap: () => onSelectTab(2),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: AppRadii.radius20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Изменения синхронизируются',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Публикации и карточки врачей обновятся у пациентов после сохранения.',
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
        ),
      ],
    ),
  );

  int _serviceCount(AdminDemoStore store) =>
      store.doctors.expand((doctor) => doctor.services).toSet().length;
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 94,
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: AppTypography.title.copyWith(color: AppColors.brand),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _AdminHomeLink extends StatelessWidget {
  const _AdminHomeLink({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.onTap,
    super.key,
  });

  final String asset;
  final String title;
  final String subtitle;
  final String footer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AdminCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: AppRadii.radius20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: AppRadii.radius12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SvgPicture.asset(asset),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.label.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    footer,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                ),
                Text(
                  '›',
                  style: AppTypography.heading.copyWith(color: AppColors.brand),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
