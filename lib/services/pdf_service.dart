import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/kitab.dart';

class PdfService {
  static Future<void> generateAndShareKitabPDF(Kitab kitab) async {
    final pdf = pw.Document();
    final stats = kitab.stats;
    final nowFormatted = DateFormat('MM/dd/yyyy, h:mm:ss a').format(DateTime.now());

    final headerColor = PdfColor.fromInt(0xFF166534); // Tailwind ledger-800 approx
    final lightGreenBg = PdfColor.fromInt(0xFFF5FAF5);

    // Filter saved days
    final savedDays = kitab.days.where((d) => d.saved).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header title
              pw.Text(
                'Khisab Kitab Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: headerColor,
                ),
              ),
              pw.SizedBox(height: 6),
              // Subtitle
              pw.Text(
                'Title: ${kitab.title}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 4),
              // Summary Stats
              pw.Text(
                'Days Completed: ${stats.daysCompleted} / 15',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 14),

              // Table
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                headerDecoration: pw.BoxDecoration(color: headerColor),
                cellStyle: const pw.TextStyle(fontSize: 9.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                cellAlignment: pw.Alignment.centerLeft,
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                oddRowDecoration: pw.BoxDecoration(color: lightGreenBg),
                headers: <String>['Day', 'Date', 'Notes', 'Income (PKR)'],
                data: savedDays.isEmpty
                    ? [
                        ['-', 'No data entered yet', '-', '-']
                      ]
                    : savedDays.map((day) {
                        final dateStr = '${Kitab.formatDate(day.date)} (${Kitab.getDayName(day.date)})';
                        final incomeDisplay = day.income.trim().isNotEmpty
                            ? Kitab.formatPKR(day.incomeValue)
                            : '-';
                        return [
                          'Day ${day.dayNumber}',
                          dateStr,
                          day.notes.isNotEmpty ? day.notes : '-',
                          incomeDisplay,
                        ];
                      }).toList(),
              ),

              // Total Footer Row
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF0F0F0),
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    right: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                    pw.Text(
                      'Rs. ${Kitab.formatPKR(stats.totalIncome)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer timestamp
              pw.Text(
                'Generated on: $nowFormatted',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    // Open native print/preview or share dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${kitab.title.replaceAll(' ', '_')}.pdf',
    );
  }
}
