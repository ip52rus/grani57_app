import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:printing/printing.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../mock_data/demo_patient_documents.dart';
import 'patient_document_pdf_service.dart';

class PatientConclusionPdfScreen extends StatelessWidget {
  const PatientConclusionPdfScreen({
    required this.document,
    required this.patientName,
    this.onSave,
    super.key,
  });

  final DemoPatientDocument document;
  final String patientName;
  final Future<void> Function()? onSave;

  Future<void> _savePdf(BuildContext context) async {
    if (onSave case final callback?) {
      await callback();
      return;
    }

    try {
      final bytes = await PatientDocumentPdfService.buildConclusion(
        document: document,
        patientName: patientName,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'zaklyuchenie_${document.date.year}_'
            '${document.date.month.toString().padLeft(2, '0')}_'
            '${document.date.day.toString().padLeft(2, '0')}.pdf',
        subject: 'Заключение врача — ${_formatDocumentDate(document.date)}',
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить PDF. Повторите ещё раз.'),
        ),
      );
    }
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
            const _PdfHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '1 из 1 страницы',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PdfPage(document: document, patientName: patientName),
                  ],
                ),
              ),
            ),
            Container(
              height: 88,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              color: AppColors.surface,
              child: AppButton(
                label: 'Сохранить PDF',
                variant: AppButtonVariant.secondary,
                onPressed: () async => _savePdf(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PdfHeader extends StatelessWidget {
  const _PdfHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Назад к заключению',
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
              'Заключение · PDF',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PdfPage extends StatelessWidget {
  const _PdfPage({required this.document, required this.patientName});

  final DemoPatientDocument document;
  final String patientName;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius12,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/brand/logo_primary_clean.svg',
          width: 140,
          height: 40.13,
        ),
        const SizedBox(height: 40),
        Text(
          'ЗАКЛЮЧЕНИЕ ВРАЧА',
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        _PdfField(label: 'Дата', value: _formatDocumentDate(document.date)),
        const SizedBox(height: 12),
        _PdfField(label: 'Пациент', value: patientName),
        const SizedBox(height: 12),
        _PdfField(label: 'Врач', value: document.doctor),
        const SizedBox(height: 12),
        Text(document.performed, style: AppTypography.body),
        const SizedBox(height: 12),
        Text(
          'Индивидуальные рекомендации\nпо уходу обсуждены на приёме.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 40),
        Text(
          'Подписано врачом\n${_formatSignedAt(document.signedAt)}',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _PdfField extends StatelessWidget {
  const _PdfField({required this.label, required this.value});

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

String _formatSignedAt(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.${date.year} · '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

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
