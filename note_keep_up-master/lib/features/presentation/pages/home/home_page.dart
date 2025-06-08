import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/note/note_bloc.dart';
import '../../../domain/entities/note.dart';
import '../../blocs/blocs.dart';
import '../../../../core/core.dart';
import './widgets/widgets.dart';
import 'package:note_app/core/config/enum/filter_status.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trang chủ của ứng dụng, hiển thị danh sách các ghi chú và xử lý các chức năng liên quan đến điểm danh.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasPromptedToday = false;

  @override
  void initState() {
    super.initState();
    _checkAndPromptAttendance();
  }

  /// Kiểm tra và gợi ý điểm danh nếu người dùng đang ở công ty và chưa điểm danh hôm nay.
  ///
  /// Yêu cầu quyền truy cập vị trí để lấy SSID Wi-Fi.
  Future<void> _checkAndPromptAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceEnabled = prefs.getBool('attendance_enabled') ?? true;
    if (!attendanceEnabled) return;
    // Chỉ chạy trên Android/iOS
    if (!mounted) return;
    // Xin quyền truy cập vị trí (bắt buộc để lấy SSID Wi-Fi)
    await Permission.locationWhenInUse.request();
    final info = NetworkInfo();
    final ssidRaw = await info.getWifiName();
    final ssid = ssidRaw?.replaceAll('"', ''); // Loại bỏ dấu ngoặc kép nếu có
    final bssid = await info.getWifiBSSID();
    print('SSID hiện tại: ' + (ssid ?? 'null'));
    print('BSSID hiện tại: ' + (bssid ?? 'null'));

    final savedAttendanceSsid = prefs.getString('saved_attendance_ssid');
    final savedAttendanceBssid = prefs.getString('saved_attendance_bssid');

    final now = DateTime.now();
    final todayKey = 'attendance_prompted_${now.year}_${now.month}_${now.day}';

    _hasPromptedToday = prefs.getBool(todayKey) ?? false;

    if (ssid != null && bssid != null) {
      if (savedAttendanceSsid == null ||
          savedAttendanceBssid == null ||
          ssid != savedAttendanceSsid ||
          bssid != savedAttendanceBssid) {
        // If no Wi-Fi is saved or current Wi-Fi doesn't match saved, prompt to save
        if (!_hasPromptedToday) {
          setState(() {
            _hasPromptedToday = true;
          });
          await prefs.setBool(todayKey, true);
          // ignore: use_build_context_synchronously
          _showSaveWifiDialog(context, ssid, bssid, now);
        }
      } else if (ssid == savedAttendanceSsid &&
          bssid == savedAttendanceBssid &&
          !_hasPromptedToday) {
        // If current Wi-Fi matches saved Wi-Fi and not prompted today, show attendance dialog
        setState(() {
          _hasPromptedToday = true;
        });
        await prefs.setBool(todayKey, true);
        // ignore: use_build_context_synchronously
        _showAttendanceDialog(context, now);
      }
    }
  }

  /// Hiển thị hộp thoại xác nhận điểm danh.
  ///
  /// [context] BuildContext hiện tại.
  /// [now] Thời điểm hiện tại để tạo ghi chú điểm danh.
  void _showAttendanceDialog(BuildContext context, DateTime now) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Điểm danh công ty'),
        content: Text(
            'Bạn đã đến công ty lúc ${_formatTime(now)}. Tạo ghi chú hôm nay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _createAttendanceNote(now);
            },
            child: const Text('Tạo ghi chú'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận lưu Wi-Fi hiện tại để điểm danh hàng ngày.
  ///
  /// [context] BuildContext hiện tại.
  /// [ssid] SSID của Wi-Fi hiện tại.
  /// [bssid] BSSID của Wi-Fi hiện tại.
  /// [now] Thời điểm hiện tại để tạo ghi chú điểm danh.
  void _showSaveWifiDialog(
      BuildContext context, String ssid, String bssid, DateTime now) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lưu Wi-Fi điểm danh'),
        content: Text(
            'Bạn có muốn chọn Wi-Fi "$ssid" (${bssid}) này để điểm danh hàng ngày không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('saved_attendance_ssid', ssid);
              await prefs.setString('saved_attendance_bssid', bssid);
              // ignore: use_build_context_synchronously
              _showAttendanceDialog(context, now);
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  /// Tạo một ghi chú điểm danh tự động.
  ///
  /// [now] Thời điểm hiện tại để ghi lại thời gian điểm danh.
  void _createAttendanceNote(DateTime now) {
    String userId = '';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      userId = authState.user!.uid;
    }
    // Kiểm tra đã có note điểm danh hôm nay chưa
    final noteBloc = context.read<NoteBloc>();
    final notesState = noteBloc.state;
    bool hasTodayAttendance = false;
    if (notesState is NotesViewState) {
      hasTodayAttendance = notesState.otherNotes.any((n) {
            return n.title == ' Công ty - ${_formatDate(now)}';
          }) ||
          notesState.pinnedNotes.any((n) {
            return n.title == ' Công ty - ${_formatDate(now)}';
          });
    }
    if (hasTodayAttendance) {
      AppAlerts.displaySnackbarMsg(context, 'Bạn đã điểm danh hôm nay!');
      return;
    }
    final note = Note(
      userId: userId,
      id: UUIDGen.generate(), // Generate a unique ID for attendance notes
      title: 'Công ty - ${_formatDate(now)}', // Removed leading space
      content: 'Đã đến lúc ${_formatTime(now)}',
      createdAt: now,
      modifiedTime: now,
      colorIndex: 0,
      stateNote: StatusNote.undefined,
    );
    context.read<NoteBloc>().add(AddNote(note));
    context
        .read<NoteBloc>()
        .add(RefreshNotes(drawerSectionView: DrawerSectionView.home));
    AppAlerts.displaySnackbarMsg(context, 'Đã tạo ghi chú điểm danh!');
  }

  /// Định dạng thời gian thành chuỗi "HH:mm".
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Định dạng ngày thành chuỗi "dd/MM/yyyy".
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<NoteBloc>().appScaffoldState,
      floatingActionButton: _buildFloatingActionButton(context),
      extendBody: true,
      drawer: const AppDrawer(),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  /// Xây dựng phần thân chính của trang chủ, hiển thị danh sách ghi chú.
  ///
  /// Lắng nghe trạng thái của [NoteBloc] để cập nhật UI.
  Widget _buildBody(BuildContext context) {
    return BlocConsumer<NoteBloc, NoteState>(
      listener: (context, state) => _displayNotesMsg(context, state),
      builder: (context, state) {
        print('DEBUG HOME: _buildBody - state: ${state.runtimeType}');
        if (state is LoadingState) {
          return CommonLoadingNotes(state.drawerSectionView);
        } else if (state is EmptyNoteState) {
          return CommonEmptyNotes(state.drawerSectionView);
        } else if (state is ErrorState) {
          return CommonEmptyNotes(state.drawerSectionView);
        } else if (state is NotesViewState) {
          final filter = context.select((NoteBloc bloc) => bloc.filterStatus);
          List<Note> filteredOtherNotes = state.otherNotes;
          List<Note> filteredPinnedNotes = state.pinnedNotes;
          print(
              'DEBUG HOME: NotesViewState - otherNotes: \\${state.otherNotes.length}, pinnedNotes: \\${state.pinnedNotes.length}, filter: \\${filter}');
          if (filter != null && filter != FilterStatus.all) {
            filteredOtherNotes = state.otherNotes.where((note) {
              if (note.stateNote == StatusNote.trash) return false;
              // Loại trừ ghi chú điểm danh khi không phải lọc "Tất cả"
              if (note.title.trim().startsWith('Công ty -')) return false;
              switch (filter) {
                case FilterStatus.notStarted:
                  return note.taskStatus == TaskStatus.notStarted;
                case FilterStatus.inProgress:
                  return note.taskStatus == TaskStatus.inProgress;
                case FilterStatus.completed:
                  return note.taskStatus == TaskStatus.completed;
                default:
                  return true;
              }
            }).toList();
            filteredPinnedNotes = state.pinnedNotes.where((note) {
              if (note.stateNote == StatusNote.trash) return false;
              // Loại trừ ghi chú điểm danh khi không phải lọc "Tất cả"
              if (note.title.trim().startsWith('Công ty -')) return false;
              switch (filter) {
                case FilterStatus.notStarted:
                  return note.taskStatus == TaskStatus.notStarted;
                case FilterStatus.inProgress:
                  return note.taskStatus == TaskStatus.inProgress;
                case FilterStatus.completed:
                  return note.taskStatus == TaskStatus.completed;
                default:
                  return true;
              }
            }).toList();
          }
          print(
              'DEBUG HOME: Sau khi lọc - filteredOtherNotes: \\${filteredOtherNotes.length}, filteredPinnedNotes: \\${filteredPinnedNotes.length}');
          return CommonNotesView(
            drawerSection: DrawerSectionView.home,
            otherNotes: filteredOtherNotes,
            pinnedNotes: filteredPinnedNotes,
          );
        } else if (state is GetNoteByIdState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushNamed(
              'note',
              pathParameters: {
                'id': state.note.id.isEmpty ? 'new' : state.note.id
              },
              extra: state.note,
            );
          });
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Hiển thị thông báo Snackbar dựa trên trạng thái của [NoteBloc].
  void _displayNotesMsg(BuildContext context, NoteState state) {
    print('DEBUG HOME: _displayNotesMsg - state: \\${state.runtimeType}');
    if (state is SuccessState) {
      context
          .read<NoteBloc>()
          .add(RefreshNotes(drawerSectionView: DrawerSectionView.home));
      AppAlerts.displaySnackbarMsg(context, state.message);
    } else if (state is ToggleSuccessState) {
      context
          .read<NoteBloc>()
          .add(RefreshNotes(drawerSectionView: DrawerSectionView.home));
      AppAlerts.displaySnackarUndoMove(context, state.message);
    } else if (state is EmptyInputsState) {
      AppAlerts.displaySnackbarMsg(context, state.message);
    } else if (state is GoPopNoteState) {
      context
          .read<NoteBloc>()
          .add(RefreshNotes(drawerSectionView: DrawerSectionView.home));
    }
  }

  /// Xây dựng nút hành động nổi (Floating Action Button) để tạo ghi chú mới.
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      elevation: 6,
      backgroundColor: Colors.green.shade200,
      shape: const CircleBorder(),
      child: Icon(Icons.add, color: Colors.black, size: 32),
      onPressed: () => context.read<NoteBloc>().add(const GetNoteById('')),
    );
  }

  /// Xử lý trạng thái khi nhận được ghi chú theo ID, điều hướng đến trang ghi chú.
  void _getNoteByIdState(BuildContext context, Note note) {
    context.read<StatusIconsCubit>().toggleIconsStatus(note);
    context.read<NoteBloc>().add(ModifColorNote(note.colorIndex));
    context.pushNamed(
      AppRouterName.note.name,
      pathParameters: {'id': note.id.isEmpty ? 'new' : note.id},
      extra: note,
    );
  }
}
