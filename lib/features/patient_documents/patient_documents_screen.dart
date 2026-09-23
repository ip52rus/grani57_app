import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_patient_documents.dart';
import '../patient_home/patient_home_screen.dart';
import 'patient_conclusion_screen.dart';

class PatientDocumentsScreen extends StatelessWidget {
  const PatientDocumentsScreen({
    required this.patientName,
    this.bottomNavigation,
    super.key,
  });

  final String patientName;
  final Widget? bottomNavigation;

  void _openDocument(BuildContext context, DemoPatientDocument document) {
    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) => PatientConclusionScreen(
          document: document,
          patientName: patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            const SizedBox(height: 44),
            const _DocumentsHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 104),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _DocumentsTitle(),
                        const SizedBox(height: 20),
                        Text(
                          'Заключения и рекомендации врачей',
                          style: AppTypography.small.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (
                          var index = 0;
                          index < DemoPatientDocuments.items.length;
                          index++
                        ) ...[
                          _DocumentCard(
                            document: DemoPatientDocuments.items[index],
                            onTap: () => _openDocument(
                              context,
                              DemoPatientDocuments.items[index],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        const _PrivacyCard(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child:
                        bottomNavigation ??
                        const PatientBottomNavigation(selectedIndex: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 56,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Документы',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brand,
          ),
        ),
      ),
    ),
  );
}

class _DocumentsTitle extends StatelessWidget {
  const _DocumentsTitle();

  static const _gradient = LinearGradient(
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
    stops: [0, 0.22748, 0.36017, 0.45496, 0.54974, 0.62557, 0.79617, 0.94783],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (_) =>
          _gradient.createShader(const Rect.fromLTWH(0, 0, 345, 36)),
      child: const Text('Всё о вашем лечении', style: AppTypography.title),
    ),
  );
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.onTap});

  final DemoPatientDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${document.title}, ${_formatDocumentDate(document.date)}',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.radius20,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/documents/document_file.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title, style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDocumentDate(document.date)} · '
                    '${document.listDetails}',
                    style: AppTypography.small.copyWith(
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
  );
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('patient.documents.privacy'),
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/actions/lock_clean.svg',
          width: 24,
          height: 24,
        ),
        const SizedBox(height: 12),
        Text(
          'Только для вас',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          'Документы доступны после входа. Новое заключение появится здесь '
          'после подписания врачом.',
          maxLines: 3,
          overflow: TextOverflow.clip,
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

String _formatDocumentDate(DateTime date) =>
    '${date.day} ${_monthNameGenitive(date.month)} ${date.year}';

String _monthNameGenitive(int month) => const [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
][month - 1];
