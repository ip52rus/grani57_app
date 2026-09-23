import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../mock_data/demo_patient_documents.dart';

abstract final class PatientDocumentPdfService {
  static Future<Uint8List> buildConclusion({
    required DemoPatientDocument document,
    required String patientName,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Regular.ttf'),
    );
    final semiBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-SemiBold.ttf'),
    );
    final logo = await rootBundle.loadString(
      'assets/icons/brand/logo_primary_clean.svg',
    );
    final pdf = pw.Document(
      title: 'Заключение врача — ${_formatDocumentDate(document.date)}',
      author: document.doctor,
      subject: document.service,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        theme: pw.ThemeData.withFont(base: regular, bold: semiBold),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SvgImage(svg: logo, width: 140, height: 41),
            pw.SizedBox(height: 48),
            pw.Text(
              'ЗАКЛЮЧЕНИЕ ВРАЧА',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#00318F'),
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 24),
            _field('Дата', _formatDocumentDate(document.date)),
            _field('Пациент', patientName),
            _field('Врач', document.doctor),
            _field('Приём', document.service),
            _field('Выполнено', document.performed),
            _field('Рекомендации', document.recommendations),
            _field('Следующий визит', document.nextVisit),
            pw.Spacer(),
            pw.Text(
              'Подписано врачом\n${_formatSignedAt(document.signedAt)}',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#576A86'),
                fontSize: 10,
                lineSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _field(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 16),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(color: PdfColor.fromHex('#576A86'), fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#172B4D'),
            fontSize: 12,
            lineSpacing: 3,
          ),
        ),
      ],
    ),
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
