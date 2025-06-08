import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import '../../../../core/core.dart';
import '../../../../core/services/export_service.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/statistics.dart';
import '../../blocs/blocs.dart';
import '../../widgets/statistics/statistics_chart.dart';
import 'package:note_app/core/config/drawer/app_drawer.dart';

/// Trang thống kê, hiển thị các biểu đồ và lịch sử điểm danh.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedType = 'Ngày tạo';
  final List<String> _types = ['Ngày tạo', 'Deadline'];
  String _selectedPeriod = 'This week';
  final List<String> _periods = [
    'This week',
    'This month',
    '3 months',
    '6 months'
  ];
  ExportFormat _selectedFormat = ExportFormat.pdf;
  int _selectedChartTab = 0; // 0: Line, 1: Pie, 2: Bar

  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(const LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<NoteBloc>().add(
                  const LoadNotes(drawerSectionView: DrawerSectionView.home),
                );
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
          PopupMenuButton<ExportFormat>(
            icon: const Icon(Icons.file_download),
            onSelected: (format) {
              setState(() {
                _selectedFormat = format;
              });
              _exportReport();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ExportFormat.pdf,
                child: Text('Export as PDF'),
              ),
              const PopupMenuItem(
                value: ExportFormat.excel,
                child: Text('Export as Excel'),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state is LoadingState) {
                return _buildShimmerLoading();
              }
              if (state is StatisticsLoadedState) {
                final notes = state.notes;
                print('DEBUG STATS: Tổng số notes từ state: ${notes.length}');
                notes.forEach((n) => print(
                    '  - Note ID: ${n.id}, Title: ${n.title}, CreatedAt: ${n.createdAt}, Content: ${n.content}'));

                final filteredNotes = _filterNotesByPeriod(notes);
                print(
                    'DEBUG STATS: Số notes sau khi lọc theo thời gian: ${filteredNotes.length}');
                filteredNotes.forEach((n) =>
                    print('  - Filtered Note ID: ${n.id}, Title: ${n.title}'));

                // Lọc các note điểm danh trong khoảng thời gian đã chọn
                final attendanceNotes = filteredNotes
                    .where((n) => n.title.trim().startsWith(
                        'Công ty -')) // Use trim() to handle leading/trailing spaces
                    .toList();
                print(
                    'DEBUG STATS: Số notes điểm danh sau khi lọc: ${attendanceNotes.length}');
                attendanceNotes.forEach((n) => print(
                    '  - Attendance Note ID: ${n.id}, Title: ${n.title}, Content: ${n.content}'));

                // Thống kê số ngày đi làm
                final daysPresent = attendanceNotes.length;
                // Thống kê số ngày đến trễ (sau 8:00)
                final daysLate = attendanceNotes.where((n) {
                  final match = RegExp(r'Đã đến lúc (\d{2}):(\d{2})')
                      .firstMatch(n.content);
                  if (match != null) {
                    final hour = int.tryParse(match.group(1) ?? '0') ?? 0;
                    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
                    return hour > 8 || (hour == 8 && minute > 0);
                  }
                  return false;
                }).length;
                // Lịch sử điểm danh (gần nhất lên đầu)
                final sortedAttendance = List<Note>.from(attendanceNotes)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCards(filteredNotes),
                      const SizedBox(height: 28),
                      // Thêm phần thống kê điểm danh
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lịch sử điểm danh',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Số ngày đi làm: ',
                                      style: TextStyle(fontSize: 15)),
                                  Text('$daysPresent',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(width: 24),
                                  Text('Số ngày đến trễ: ',
                                      style: TextStyle(fontSize: 15)),
                                  Text('$daysLate',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: sortedAttendance.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, idx) {
                                  final note = sortedAttendance[idx];
                                  final dateStr = DateFormat('dd/MM/yyyy')
                                      .format(note.createdAt);
                                  final match =
                                      RegExp(r'Đã đến lúc (\d{2}):(\d{2})')
                                          .firstMatch(note.content);
                                  final timeStr = match != null
                                      ? '${match.group(1)}:${match.group(2)}'
                                      : '--:--';
                                  return ListTile(
                                    leading: const Icon(Icons.fingerprint,
                                        color: Colors.blueAccent),
                                    title: Text('Ngày $dateStr'),
                                    subtitle: Text('Đến lúc: $timeStr'),
                                    trailing: (timeStr.compareTo('08:00') > 0)
                                        ? const Text('Trễ',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))
                                        : const Text('Đúng giờ',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildChartTabs(),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _buildCharts(filteredNotes),
                      ),
                    ],
                  ),
                );
              }
              if (state is ErrorState) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ),
    );
  }

  /// Hiển thị bottom sheet chứa các tùy chọn lọc thống kê.
  ///
  /// [context] BuildContext hiện tại.
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_rounded, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Bộ lọc thống kê',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Thống kê theo',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _types
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Khoảng thời gian',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _periods
                  .map((period) => DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                context.read<NoteBloc>().add(const LoadStatistics());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng các thẻ tổng quan thống kê.
  ///
  /// [notes] Danh sách ghi chú để tính toán thống kê.
  Widget _buildOverviewCards(List<Note> notes) {
    final totalTasks = notes.length;
    final completedTasks =
        notes.where((n) => n.taskStatus == TaskStatus.completed).length;
    final ongoingTasks =
        notes.where((n) => n.taskStatus == TaskStatus.inProgress).length;
    final notStartedTasks =
        notes.where((n) => n.taskStatus == TaskStatus.notStarted).length;
    final List<_StatCardData> stats = [
      _StatCardData('Tổng số công việc', totalTasks, Icons.task_alt,
          [Color.fromARGB(255, 113, 116, 119), Color(0xFFE0C3FC)]),
      _StatCardData('Đã hoàn thành', completedTasks, Icons.check_circle,
          [Color(0xFF43E97B), Color(0xFF38F9D7)]),
      _StatCardData('Đang thực hiện', ongoingTasks, Icons.hourglass_empty,
          [Color(0xFFFFDEE9), Color(0xFFB5FFFC)]),
      _StatCardData('Chưa bắt đầu', notStartedTasks, Icons.cancel_outlined,
          [Color(0xFFFDCB82), Color(0xFFA1C4FD)]),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: stats.map((stat) => _buildModernStatCard(stat)).toList(),
    );
  }

  /// Xây dựng một thẻ thống kê hiện đại.
  ///
  /// [stat] Dữ liệu cho thẻ thống kê.
  Widget _buildModernStatCard(_StatCardData stat) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: stat.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: stat.gradientColors.last.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon, size: 28, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              stat.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: AnimatedFlipCounter(
                  duration: const Duration(milliseconds: 800),
                  value: stat.value,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng các tab chuyển đổi giữa các loại biểu đồ.
  Widget _buildChartTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChartTab('Line', Icons.show_chart, 0),
        const SizedBox(width: 16),
        _buildChartTab('Pie', Icons.pie_chart, 1),
        const SizedBox(width: 16),
        _buildChartTab('Bar', Icons.bar_chart, 2),
      ],
    );
  }

  /// Xây dựng một tab biểu đồ.
  ///
  /// [label] Nhãn hiển thị trên tab.
  /// [icon] Biểu tượng của tab.
  /// [index] Chỉ số của tab.
  Widget _buildChartTab(String label, IconData icon, int index) {
    final isSelected = _selectedChartTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng biểu đồ dựa trên tab được chọn.
  ///
  /// [notes] Danh sách ghi chú để vẽ biểu đồ.
  Widget _buildCharts(List<Note> notes) {
    switch (_selectedChartTab) {
      case 1:
        return _buildPieChart(notes);
      case 2:
        return _buildBarChart(notes);
      default:
        return _buildLineChart(notes);
    }
  }

  /// Xây dựng biểu đồ đường (Line Chart).
  ///
  /// [notes] Danh sách ghi chú để vẽ biểu đồ.
  Widget _buildLineChart(List<Note> notes) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateDataPoints(notes),
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                      show: true, color: Colors.blueAccent.withOpacity(0.2)),
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng biểu đồ tròn (Pie Chart).
  ///
  /// [notes] Danh sách ghi chú để vẽ biểu đồ.
  Widget _buildPieChart(List<Note> notes) {
    final completed =
        notes.where((n) => n.taskStatus == TaskStatus.completed).length;
    final ongoing =
        notes.where((n) => n.taskStatus == TaskStatus.inProgress).length;
    final notStarted =
        notes.where((n) => n.taskStatus == TaskStatus.notStarted).length;
    final total = notes.length;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.greenAccent,
                  value: completed.toDouble(),
                  title: '${((completed / total) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.orangeAccent,
                  value: ongoing.toDouble(),
                  title: '${((ongoing / total) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.blueAccent,
                  value: notStarted.toDouble(),
                  title: '${((notStarted / total) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
              sectionsSpace: 4,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng biểu đồ cột (Bar Chart).
  ///
  /// [notes] Danh sách ghi chú để vẽ biểu đồ.
  Widget _buildBarChart(List<Note> notes) {
    final now = DateTime.now();
    final Map<String, int> counts = {};
    for (final note in notes) {
      final date = _selectedType == 'Deadline' ? note.deadline : note.createdAt;
      if (date != null) {
        final dateStr = DateFormat('MM/dd').format(date);
        counts[dateStr] = (counts[dateStr] ?? 0) + 1;
      }
    }
    final List<BarChartGroupData> barGroups = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('MM/dd').format(date);
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: counts[dateStr]?.toDouble() ?? 0,
              color: Colors.purpleAccent,
              width: 18,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx > 6) return const SizedBox();
                      final date = now.subtract(Duration(days: 6 - idx));
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng hiệu ứng loading shimmer.
  Widget _buildShimmerLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.blueAccent,
        strokeWidth: 5,
      ),
    );
  }

  /// Xây dựng trạng thái rỗng khi không có dữ liệu thống kê.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          const Text(
            'Không có dữ liệu thống kê',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy tạo ghi chú để xem thống kê sinh động hơn!',
            style: TextStyle(fontSize: 15, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  /// Lọc danh sách ghi chú theo khoảng thời gian và loại đã chọn.
  ///
  /// [notes] Danh sách ghi chú gốc.
  /// Trả về danh sách ghi chú đã được lọc.
  List<Note> _filterNotesByPeriod(List<Note> notes) {
    final now = DateTime.now();
    DateTime fromDate;
    switch (_selectedPeriod) {
      case 'This week':
        fromDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This month':
        fromDate = DateTime(now.year, now.month, 1);
        break;
      case '3 months':
        fromDate = DateTime(now.year, now.month - 2, 1);
        break;
      case '6 months':
        fromDate = DateTime(now.year, now.month - 5, 1);
        break;
      default:
        fromDate = DateTime(now.year, now.month, 1);
    }

    print(
        'DEBUG STATS: Lọc notes theo khoảng thời gian: $_selectedPeriod, loại: $_selectedType');
    print('DEBUG STATS: FromDate: $fromDate');

    if (_selectedType == 'Deadline') {
      final result = notes
          .where((note) =>
              note.deadline != null &&
              note.deadline!
                  .isAfter(fromDate.subtract(const Duration(days: 1))))
          .toList();
      print('DEBUG STATS: Kết quả lọc theo Deadline: ${result.length}');
      return result;
    } else {
      final result = notes
          .where((note) => note.createdAt
              .isAfter(fromDate.subtract(const Duration(days: 1))))
          .toList();
      print('DEBUG STATS: Kết quả lọc theo Ngày tạo: ${result.length}');
      return result;
    }
  }

  /// Tạo các điểm dữ liệu cho biểu đồ đường.
  ///
  /// [notes] Danh sách ghi chú để tạo điểm dữ liệu.
  /// Trả về danh sách các [FlSpot] cho biểu đồ.
  List<FlSpot> _generateDataPoints(List<Note> notes) {
    final now = DateTime.now();
    final Map<String, int> counts = {};

    for (final note in notes) {
      final date = _selectedType == 'Deadline' ? note.deadline : note.createdAt;
      if (date != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        counts[dateStr] = (counts[dateStr] ?? 0) + 1;
      }
    }

    final List<FlSpot> spots = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      spots.add(FlSpot(
        (6 - i).toDouble(),
        counts[dateStr]?.toDouble() ?? 0,
      ));
    }
    return spots;
  }

  /// Xuất báo cáo thống kê dưới dạng PDF hoặc Excel.
  Future<void> _exportReport() async {
    try {
      final state = context.read<NoteBloc>().state;
      if (state is StatisticsLoadedState) {
        final notes = state.notes;
        final filteredNotes = _filterNotesByPeriod(notes);

        final file = await ExportService.exportReport(
          notes: filteredNotes,
          statistics: state.statistics,
          period: _selectedPeriod,
          format: _selectedFormat,
        );

        if (file != null && mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Export thành công'),
              content: Text('File đã lưu tại:\n${file.path}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Share.shareXFiles([XFile(file.path)],
                        text: 'Báo cáo ghi chú');
                  },
                  child: const Text('Chia sẻ'),
                ),
                TextButton(
                  onPressed: () {
                    OpenFile.open(file.path);
                  },
                  child: const Text('Mở file'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Thoát'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Lớp dữ liệu cho thẻ thống kê.
class _StatCardData {
  final String title;
  final int value;
  final IconData icon;
  final List<Color> gradientColors;
  _StatCardData(this.title, this.value, this.icon, this.gradientColors);
}
