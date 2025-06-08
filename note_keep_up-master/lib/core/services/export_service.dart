import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

import '../../features/domain/entities/note.dart';
import '../../features/domain/entities/statistics.dart';

enum ExportFormat { pdf, excel }

class ExportService {
  static Future<File?> exportReport({
    required List<Note> notes,
    required NoteStatistics statistics,
    required String period,
    required ExportFormat format,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = 'note_report_$dateStr';

    try {
      final file = await (format == ExportFormat.pdf
          ? _exportToPdf(notes, statistics, period)
          : _exportToExcel(notes, statistics, period));

      return file;
    } catch (e) {
      print('Error exporting report: $e');
      rethrow;
    }
  }

  static Future<File?> _exportToPdf(
    List<Note> notes,
    NoteStatistics statistics,
    String period,
  ) async {
    // Load Roboto font from assets
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Báo cáo thống kê ghi chú',
                style: pw.TextStyle(font: ttf, fontSize: 24)),
          ),
          pw.Paragraph(
              text: 'Thời gian: $period', style: pw.TextStyle(font: ttf)),
          pw.SizedBox(height: 20),

          // Statistics Overview
          pw.Header(
              level: 1,
              child: pw.Text('Tổng quan', style: pw.TextStyle(font: ttf))),
          pw.Table.fromTextArray(
            context: context,
            data: [
              ['Chỉ số', 'Giá trị'],
              ['Tổng số công việc', '${statistics.totalTasks}'],
              ['Đã hoàn thành', '${statistics.completedTasks}'],
              ['Đang thực hiện', '${statistics.ongoingTasks}'],
              ['Chưa bắt đầu', '${statistics.notStartedTasks}'],
              ['Đã xóa', '${statistics.trashedTasks}'],
            ],
            cellStyle: pw.TextStyle(font: ttf),
            headerStyle:
                pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          // Notes List
          pw.Header(
              level: 1,
              child: pw.Text('Chi tiết công việc',
                  style: pw.TextStyle(font: ttf))),
          pw.Table.fromTextArray(
            context: context,
            headers: ['Tiêu đề', 'Trạng thái', 'Cập nhật'],
            data: notes
                .map((note) => [
                      note.title,
                      _getStatusText(note.taskStatus),
                      DateFormat('dd/MM/yyyy').format(note.modifiedTime),
                    ])
                .toList(),
            cellStyle: pw.TextStyle(font: ttf),
            headerStyle:
                pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/note_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File?> _exportToExcel(
    List<Note> notes,
    NoteStatistics statistics,
    String period,
  ) async {
    final excel = Excel.createExcel();

    // Overview Sheet
    final overviewSheet = excel['Tổng quan'];
    overviewSheet.appendRow([TextCellValue('Báo cáo thống kê ghi chú')]);
    overviewSheet.appendRow([
      TextCellValue('Thời gian:'),
      TextCellValue(period),
    ]);
    overviewSheet.appendRow([]);
    overviewSheet.appendRow([
      TextCellValue('Chỉ số'),
      TextCellValue('Giá trị'),
    ]);
    overviewSheet.appendRow([
      TextCellValue('Tổng số công việc'),
      IntCellValue(statistics.totalTasks),
    ]);
    overviewSheet.appendRow([
      TextCellValue('Đã hoàn thành'),
      IntCellValue(statistics.completedTasks),
    ]);
    overviewSheet.appendRow([
      TextCellValue('Đang thực hiện'),
      IntCellValue(statistics.ongoingTasks),
    ]);
    overviewSheet.appendRow([
      TextCellValue('Chưa bắt đầu'),
      IntCellValue(statistics.notStartedTasks),
    ]);
    overviewSheet.appendRow([
      TextCellValue('Đã xóa'),
      IntCellValue(statistics.trashedTasks),
    ]);

    // Details Sheet
    final detailsSheet = excel['Chi tiết'];
    detailsSheet.appendRow([
      TextCellValue('Tiêu đề'),
      TextCellValue('Trạng thái'),
      TextCellValue('Cập nhật'),
    ]);

    for (final note in notes) {
      detailsSheet.appendRow([
        TextCellValue(note.title),
        TextCellValue(_getStatusText(note.taskStatus)),
        TextCellValue(DateFormat('dd/MM/yyyy').format(note.modifiedTime)),
      ]);
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/note_report.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  static String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Chưa hoàn thành';
      case TaskStatus.inProgress:
        return 'Đang làm';
      case TaskStatus.completed:
        return 'Hoàn thành';
    }
  }
}
