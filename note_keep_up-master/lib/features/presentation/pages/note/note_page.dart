import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/core/util/alerts/app_alerts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/config/enum/drawer_section_view.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../app/di/get_it.dart'; // Import get_it
import '../../../../core/util/function/drawe_select.dart';

import '../../../../core/core.dart' as core;
import '../../../domain/entities/note.dart';
import '../../../domain/entities/reminder.dart';
import '../../blocs/blocs.dart';
import '../../widgets/reminder/reminder_dialog.dart';
import 'widget/widgets.dart';

/// Trang ghi chú, cho phép người dùng tạo, chỉnh sửa và quản lý các ghi chú.
class NotePage extends StatefulWidget {
  const NotePage({
    super.key,
    required this.note,
  });

  /// Đối tượng ghi chú được truyền vào trang.
  final Note note;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _undoController = UndoHistoryController();
  double _progress = 0.0;
  DateTime? _deadline;
  Reminder? _reminder;
  TaskStatus _taskStatus = TaskStatus.notStarted;
  bool _isCompleted = false;

  /// Trả về màu sắc của ghi chú dựa trên [NoteBloc].
  Color get noteColor {
    final noteBloc = context.read<NoteBloc>();
    return core.ColorNote.getColor(context, noteBloc.currentColor);
  }

  /// Trả về một bản sao của ghi chú ban đầu (trước khi chỉnh sửa).
  Note get originNote {
    return Note(
      userId: widget.note.userId,
      id: widget.note.id,
      title: widget.note.title,
      content: widget.note.content,
      createdAt: widget.note.createdAt,
      modifiedTime: widget.note.modifiedTime,
      colorIndex: widget.note.colorIndex,
      stateNote: widget.note.stateNote,
      taskStatus: widget.note.taskStatus,
      deadline: widget.note.deadline,
      isCompleted: widget.note.isCompleted,
      reminder: _reminder,
    );
  }

  /// Trả về đối tượng ghi chú hiện tại với các thay đổi từ UI.
  Note get currentNote {
    final noteBloc = context.read<NoteBloc>();
    final noteStatusBloc = context.read<StatusIconsCubit>();

    final currentStatusNote = (noteStatusBloc.state is ToggleIconsStatusState)
        ? (noteStatusBloc.state as ToggleIconsStatusState).currentNoteStatus
        : widget.note
            .stateNote; // Use the note's original state or a sensible default
    print('DEBUG UI: currentNote.reminder = $_reminder');
    return Note(
      userId: widget.note.userId,
      id: widget.note.id,
      title: _titleController.text,
      content: _contentController.text,
      createdAt: widget.note.createdAt,
      modifiedTime: DateTime.now(),
      colorIndex: noteBloc.currentColor,
      stateNote: currentStatusNote,
      taskStatus: _taskStatus,
      deadline: _deadline,
      isCompleted: _taskStatus == TaskStatus.completed,
      reminder: _reminder,
    );
  }

  @override
  void initState() {
    _loadNoteFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusIconsCubit>().toggleIconsStatus(widget.note);
      // Đặt lại notification nếu note có reminder
      if (widget.note.reminder != null) {
        gI.get<NotificationService>().scheduleReminderNotification(
              id: widget.note.id,
              title: 'Nhắc nhở:  [1m${widget.note.title} [0m',
              body: 'Ghi chú "${widget.note.title}" đến giờ nhắc!',
              scheduledDate: widget.note.reminder!.reminderTime,
              repeatType: widget.note.reminder!.repeatType,
            );
      }
    });
    super.initState();
  }

  /// Tải dữ liệu từ đối tượng ghi chú vào các trường nhập liệu.
  void _loadNoteFields() {
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _taskStatus = widget.note.taskStatus;
    _isCompleted = widget.note.isCompleted;
    _deadline = widget.note.deadline;
    _reminder = widget.note.reminder;
    print(
        'DEBUG UI: NotePage nhận note với reminder = ${widget.note.reminder}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu là note điểm danh, chỉ hiện thông báo và không cho xem/sửa
    if (widget.note.title.startsWith('Công ty -')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context
                  .read<NoteBloc>()
                  .add(RefreshNotes(drawerSectionView: DrawerSectionView.home));
              context.pop();
            },
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Đây là ghi chú tự động và không thể xem hoặc sửa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    // Nếu không phải note điểm danh, giữ nguyên giao diện cũ
    return PopScope(
      canPop: true,
      onPopInvoked: (_) => _onBack(),
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) => _displaylistener(context, state),
        builder: (context, state) {
          return Scaffold(
            backgroundColor: noteColor,
            bottomNavigationBar:
                CustomBottomBar(() => currentNote, _undoController),
            appBar: AppBarNote(press: _onBack),
            body: _buildBody(),
            floatingActionButton: _buildFloatingActionButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  /// Xây dựng phần thân chính của trang ghi chú.
  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            TextFieldsForm(
              controllerTitle: _titleController,
              controllerContent: _contentController,
              undoController: _undoController,
              autofocus: false,
            ),
            const SizedBox(height: 16),
            _buildProgressSection(),
            if (_deadline != null) _buildDeadlineSection(),
            if (_reminder != null) _buildReminderSection(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng phần chọn trạng thái công việc.
  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusButton(
                context,
                TaskStatus.notStarted,
                'Chưa hoàn thành',
                Colors.grey,
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                context,
                TaskStatus.inProgress,
                'Đang làm',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                context,
                TaskStatus.completed,
                'Hoàn thành',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng một nút trạng thái công việc.
  ///
  /// [context] BuildContext hiện tại.
  /// [status] Trạng thái công việc của nút.
  /// [label] Nhãn hiển thị trên nút.
  /// [color] Màu sắc của nút.
  Widget _buildStatusButton(
    BuildContext context,
    TaskStatus status,
    String label,
    Color color,
  ) {
    final isSelected = _taskStatus == status;
    return Expanded(
      child: InkWell(
        onTap: () => _onStatusChanged(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStatusIcon(status),
                color: color,
                size: 16,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Trả về biểu tượng tương ứng với trạng thái công việc.
  IconData _getStatusIcon(TaskStatus status) {
    if (status == TaskStatus.notStarted) {
      return Icons.cancel_outlined;
    } else if (status == TaskStatus.inProgress) {
      return Icons.hourglass_empty;
    } else if (status == TaskStatus.completed) {
      return Icons.check_circle_outline;
    } else {
      return Icons.error; // Default case
    }
  }

  /// Xây dựng phần hiển thị deadline của ghi chú.
  Widget _buildDeadlineSection() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text('Deadline: ${_deadline!.toString().split(' ')[0]}'),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _deadline = null;
          });
        },
      ),
    );
  }

  /// Xây dựng phần hiển thị nhắc nhở của ghi chú.
  Widget _buildReminderSection() {
    if (_reminder == null) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Icons.alarm),
      title:
          Text('Reminder: ${_reminder!.reminderTime.toString().split(' ')[0]}'),
      subtitle: Text('Repeat: ${_reminder!.repeatType.name}'),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _reminder = null;
          });
        },
      ),
    );
  }

  /// Xây dựng các nút hành động nổi để thêm deadline và nhắc nhở.
  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'deadline',
            onPressed: _selectDeadline,
            child: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'reminder',
            onPressed: _showReminderDialog,
            child: const Icon(Icons.alarm_add),
          ),
        ],
      ),
    );
  }

  /// Hiển thị bộ chọn ngày để chọn deadline.
  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
      // Đặt giờ mặc định cho notification (ví dụ 8:00 sáng)
      DateTime notifyTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
      ).subtract(const Duration(days: 1)).add(const Duration(hours: 8));

      // If the calculated notifyTime is in the past, schedule it for 9 AM on the deadline day
      if (notifyTime.isBefore(DateTime.now())) {
        notifyTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          9, // 9 AM on the deadline day
        );
        // If even 9 AM on the deadline day is in the past, schedule it for current time + 1 minute
        if (notifyTime.isBefore(DateTime.now())) {
          notifyTime = DateTime.now().add(const Duration(minutes: 1));
        }
      }

      await gI.get<NotificationService>().scheduleNotification(
            id: widget.note.id,
            title: 'Sắp đến hạn: ${_titleController.text}',
            body:
                'Ghi chú "${_titleController.text}" sẽ hết hạn vào ${picked.toString().split(' ')[0]}',
            scheduledDate: notifyTime,
          );
      print('DEBUG: Notification scheduled for deadline at $notifyTime!');
    }
  }

  /// Hiển thị hộp thoại để thiết lập nhắc nhở.
  Future<void> _showReminderDialog() async {
    showDialog(
      context: context,
      builder: (context) => ReminderDialog(
        reminder: _reminder,
        onSave: (dateTime, repeatType) async {
          setState(() {
            _reminder = Reminder(
              id: widget.note.id,
              noteId: widget.note.id,
              reminderTime: dateTime,
              repeatType: repeatType,
            );
          });
          // Schedule notification
          await gI.get<NotificationService>().scheduleReminderNotification(
                id: widget.note.id,
                title: 'Nhắc nhở: ${_titleController.text}',
                body: 'Ghi chú "${_titleController.text}" đến giờ nhắc!',
                scheduledDate: dateTime,
                repeatType: repeatType,
              );
        },
      ),
    );
  }

  /// Xử lý hành động khi người dùng nhấn nút quay lại.
  ///
  /// Kiểm tra xem ghi chú có trống hay không để quyết định hành động (pop hoặc lưu).
  Future<bool> _onBack() async {
    print(
        'DEBUG UI: _onBack với currentNote.reminder = ${currentNote.reminder}');
    // Nếu là note mới và không nhập gì, gửi event PopEmptyNote cho Bloc
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      context.read<NoteBloc>().add(const PopEmptyNote());
      return false; // Để Bloc xử lý pop qua state
    }
    // Nếu có nội dung, gửi event PopNoteAction như cũ
    context.read<NoteBloc>().add(PopNoteAction(currentNote, originNote));
    return false; // Để Bloc xử lý pop qua state
  }

  /// Lắng nghe các trạng thái của [NoteBloc] và thực hiện hành động tương ứng.
  void _displaylistener(BuildContext context, NoteState state) {
    if (state is GoPopNoteState) {
      final note = state.note;
      // Đóng mọi popover/bottom sheet nếu có
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      // Đảm bảo chuyển route sau khi popover đã đóng
      Future.delayed(const Duration(milliseconds: 100), () {
        if (note.stateNote == core.StatusNote.archived) {
          context.go('/archive');
        } else if (note.stateNote == core.StatusNote.trash) {
          context.go('/trash');
        } else {
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
        }
      });
    }
  }

  /// Xử lý khi trạng thái công việc của ghi chú thay đổi.
  void _onStatusChanged(TaskStatus newStatus) async {
    print(
        'DEBUG UI: _onStatusChanged với currentNote.reminder = ${currentNote.reminder}');
    print('DEBUG: _onStatusChanged called with $newStatus');
    if (_taskStatus == newStatus) return; // Prevent unnecessary updates

    setState(() {
      _taskStatus = newStatus;
      _isCompleted = newStatus == TaskStatus.completed;
    });

    // Lấy trạng thái ghi chú hiện tại (StatusNote)
    final currentStatusNote = currentNote.stateNote;

    // Tạo note mới với trạng thái công việc mới, giữ nguyên trạng thái ghi chú
    final updatedNote = currentNote.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      modifiedTime: DateTime.now(),
      colorIndex: context.read<NoteBloc>().currentColor,
      stateNote: currentStatusNote, // giữ nguyên trạng thái ghi chú
      taskStatus: newStatus,
      deadline: _deadline,
      isCompleted: newStatus == TaskStatus.completed,
    );

    context.read<NoteBloc>().add(UpdateNote(updatedNote));
    if (_deadline != null) {
      // Đặt giờ mặc định cho notification (ví dụ 8:00 sáng)
      DateTime notifyTime = DateTime(
        _deadline!.year,
        _deadline!.month,
        _deadline!.day,
      ).subtract(const Duration(days: 1)).add(const Duration(hours: 8));

      // If the calculated notifyTime is in the past, schedule it for 9 AM on the deadline day
      if (notifyTime.isBefore(DateTime.now())) {
        notifyTime = DateTime(
          _deadline!.year,
          _deadline!.month,
          _deadline!.day,
          9, // 9 AM on the deadline day
        );
        // If even 9 AM on the deadline day is in the past, schedule it for current time + 1 minute
        if (notifyTime.isBefore(DateTime.now())) {
          notifyTime = DateTime.now().add(const Duration(minutes: 1));
        }
      }

      print(
          'DEBUG: Scheduling notification for note "${updatedNote.title}" at $notifyTime');
      await gI.get<NotificationService>().scheduleNotification(
            id: updatedNote.id,
            title: 'Sắp đến hạn: ${updatedNote.title}',
            body:
                'Ghi chú "${updatedNote.title}" sẽ hết hạn vào ${_deadline!.toString().split(' ')[0]}',
            scheduledDate: notifyTime,
          );
      print('DEBUG: Notification scheduled!');
    } else {
      print('DEBUG: No deadline set, notification not scheduled.');
    }
  }
}
