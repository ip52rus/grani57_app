import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../../mock_data/demo_patient_documents.dart';
import 'patient_conclusion_pdf_screen.dart';

class PatientConclusionScreen extends StatelessWidget {
  const PatientConclusionScreen({
    required this.document,
    required this.patientName,
    super.key,
  });

  final DemoPatientDocument document;
  final String patientName;

  void _openPdf(BuildContext context) {
    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) => PatientConclusionPdfScreen(
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
            const _ConclusionHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _SignedPill(),
                    ),
                    const SizedBox(height: 20),
                    const _ConclusionTitle(),
                    const SizedBox(height: 20),
                    Text(
                      '${_formatDocumentDate(document.date)} · '
                      'приём завершён',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DoctorCard(doctor: document.doctor),
                    const SizedBox(height: 20),
                    _ConclusionInfoCard(
                      document: document,
                      patientName: patientName,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Медицинский документ содержит данные только этого '
                      'приёма.',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 88,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              color: AppColors.surface,
              child: AppButton(
                label: 'Скачать заключение',
                onPressed: () => _openPdf(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ConclusionHeader extends StatelessWidget {
  const _ConclusionHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Назад к документам',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.maybePop(context),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'assets/icons/actions/news_back.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Документ',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SignedPill extends StatelessWidget {
  const _SignedPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: const BoxDecoration(
      color: AppColors.successBg,
      borderRadius: AppRadii.radiusFull,
    ),
    child: Text(
      'Подписано врачом',
      style: AppTypography.caption.copyWith(color: AppColors.success),
    ),
  );
}

class _ConclusionTitle extends StatelessWidget {
  const _ConclusionTitle();

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
    stops: [0, 0.20104, 0.31832, 0.40209, 0.48586, 0.55287, 0.70365, 0.83768],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (_) =>
          _gradient.createShader(const Rect.fromLTWH(0, 0, 345, 36)),
      child: const Text('Заключение врача', style: AppTypography.title),
    ),
  );
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final String doctor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24082152),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            DemoAssetPaths.doctorAnnaSmirnova,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor, style: AppTypography.label),
              const SizedBox(height: 4),
              Text(
                'Стоматолог-терапевт',
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConclusionInfoCard extends StatelessWidget {
  const _ConclusionInfoCard({
    required this.document,
    required this.patientName,
  });

  final DemoPatientDocument document;
  final String patientName;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoField(label: 'Пациент', value: patientName),
        const SizedBox(height: 12),
        _InfoField(label: 'Приём', value: document.service),
        const SizedBox(height: 12),
        _InfoField(label: 'Выполнено', value: document.performed),
        const SizedBox(height: 12),
        _InfoField(label: 'Рекомендации', value: document.recommendations),
        const SizedBox(height: 12),
        _InfoField(label: 'Следующий визит', value: document.nextVisit),
      ],
    ),
  );
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTypography.small.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 4),
      Text(value, style: AppTypography.body),
    ],
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
