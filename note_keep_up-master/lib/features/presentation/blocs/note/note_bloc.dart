import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/core.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/statistics.dart';
import '../../../domain/usecases/add_note.dart';
import '../../../domain/usecases/detele_note.dart';
import '../../../domain/usecases/get_note_by_id.dart';
import '../../../domain/usecases/get_notes.dart';
import '../../../domain/usecases/update_note.dart';
import '../../../data/datasources/local/hive/note_local_data_source_with_hive_impl.dart';
import 'package:note_app/core/config/enum/filter_status.dart';
import 'package:note_app/features/data/datasources/auth_service.dart';
part 'note_event.dart';
part 'note_state.dart';

/// Bloc quản lý trạng thái và logic nghiệp vụ liên quan đến các ghi chú.
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotesUsecase getNotes;
  final GetNoteByIdUsecase getNoteById;
  final AddNoteUsecase addNote;
  final UpdateNoteUsecase updateNote;
  final DeleteNoteUsecase deleteNote;
  final NoteLocalDataSourceWithHiveImpl _noteLocalDataSourceWithHiveImpl;

  FilterStatus? filterStatus;

  /// Khởi tạo [NoteBloc] với các usecase và datasource cần thiết.
  NoteBloc({
    required this.getNotes,
    required this.getNoteById,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required NoteLocalDataSourceWithHiveImpl noteLocalDataSourceWithHiveImpl,
  })  : _noteLocalDataSourceWithHiveImpl = noteLocalDataSourceWithHiveImpl,
        super(LoadingState(DrawerSelect.drawerSection)) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<GetNoteById>(_onGetById);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<RefreshNotes>(_onRefreshNotes);
    on<ModifColorNote>(_onModifColorNote);
    on<EmptyInputs>(_onEmptyInputs);
    on<LoadStatistics>(_onLoadStatistics);
    //Action Event
    on<MoveNote>(_onMoveNote);
    on<UndoMoveNote>(_onUndoMoveNote);
    on<PopNoteAction>(_onPopNoteAction);
    //====
    on<FilterNotesByStatus>(_onFilterNotesByStatus);
    // Thêm dòng này để xử lý PopEmptyNote
    on<PopEmptyNote>((event, emit) {
      emit(GoPopNoteState(oldNote!));
    });
  }
  Note? oldNote;
  bool _isNewNote = false;

  int _colorIndex = 0;
  int get currentColor => _colorIndex;

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  GlobalKey<ScaffoldState> get appScaffoldState => _key;

  /// Xử lý sự kiện [LoadNotes] để tải tất cả ghi chú.
  _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(LoadingState(event.drawerSectionView));
    try {
      final notes = await getNotes();
      emit(_mapLoadNotesState(notes, event.drawerSectionView));
    } catch (e) {
      emit(ErrorState(e.toString(), event.drawerSectionView));
    }
  }

  /// Xử lý sự kiện [RefreshNotes] để làm mới danh sách ghi chú.
  _onRefreshNotes(RefreshNotes event, Emitter<NoteState> emit) async {
    final failureOrLoaded = await getNotes();
    emit(LoadingState(event.drawerSectionView));
    emit(_mapLoadNotesState(failureOrLoaded, event.drawerSectionView));
  }

  /// Xử lý sự kiện [AddNote] để thêm một ghi chú mới.
  _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    print('DEBUG BLOC: AddNote với reminder = ${event.note.reminder}');
    final Either<Failure, Unit> failureOrSuccess = await addNote(event.note);
    emit(
      failureOrSuccess.fold(
        (failure) => (ErrorState(
          _mapFailureMsg(failure),
          DrawerSelect.drawerSection,
        )),
        (_) {
          add(const LoadStatistics()); // Refresh statistics after adding a note
          return const SuccessState(ADD_SUCCESS_MSG);
        },
      ),
    );
  }

  /// Xử lý sự kiện [EmptyInputs] khi các trường nhập liệu trống.
  _onEmptyInputs(EmptyInputs event, Emitter<NoteState> emit) {
    emit(const EmptyInputsState(EMPTY_TEXT_MSG));
  }

  /// Xử lý sự kiện [GetNoteById] để lấy một ghi chú theo ID.
  _onGetById(GetNoteById event, Emitter<NoteState> emit) async {
    final failureOrSuccess = await getNoteById(event.noteId);
    final currentUserId = AuthService().currentUser?.uid ?? '';
    emit(
      failureOrSuccess.fold(
        (_) {
          _isNewNote = true;
          return GetNoteByIdState(Note.empty(userId: currentUserId));
        },
        (note) {
          _isNewNote = false;
          return GetNoteByIdState(note);
        },
      ),
    );
  }

  /// Xử lý sự kiện [UpdateNote] để cập nhật một ghi chú hiện có.
  _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    print('DEBUG BLOC: UpdateNote với reminder = ${event.note.reminder}');
    print('Updating note with ID: ${event.note.id}');
    print('New status: ${event.note.taskStatus}');
    print('New isCompleted: ${event.note.isCompleted}');

    final Either<Failure, Unit> failureOrSuccess = await updateNote(event.note);

    emit(
      failureOrSuccess.fold(
        (failure) {
          print('Update failed: ${_mapFailureMsg(failure)}');
          return ErrorState(
            _mapFailureMsg(failure),
            DrawerSelect.drawerSection,
          );
        },
        (_) {
          print('Update successful');
          add(const LoadStatistics()); // Refresh statistics after updating a note
          return const SuccessState(UPDATE_SUCCESS_MSG);
        },
      ),
    );
  }

  /// Xử lý sự kiện [DeleteNote] để xóa một ghi chú.
  _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    final failureOrSuccess = await deleteNote(event.noteId);
    emit(
      failureOrSuccess.fold(
        (failure) => (ErrorState(
          _mapFailureMsg(failure),
          DrawerSelect.drawerSection,
        )),
        (_) => (const SuccessState(DELETE_SUCCESS_MSG)),
      ),
    );
    emit(GoPopNoteState(oldNote!));
  }

  /// Xử lý sự kiện [ModifColorNote] để thay đổi màu sắc của ghi chú.
  _onModifColorNote(ModifColorNote event, Emitter<NoteState> emit) {
    _colorIndex = event.colorIndex;
    emit(ModifedColorNoteState(_colorIndex));
  }

  /// Xử lý sự kiện [PopNoteAction] khi người dùng thoát khỏi trang ghi chú.
  _onPopNoteAction(PopNoteAction event, Emitter<NoteState> emit) async {
    print(
        'DEBUG BLOC: PopNoteAction currentNote.stateNote = \\${event.currentNote.stateNote}, originNote.stateNote = \\${event.originNote.stateNote}');
    final Note currentNote = event.currentNote;
    final Note originNote = event.originNote;

    print('DEBUG: Current note - ${currentNote.title}, ${currentNote.content}');
    print('DEBUG: Origin note - ${originNote.title}, ${originNote.content}');
    print('DEBUG: Is new note - $_isNewNote');

    // Check if the note is dirty (requires update)
    final bool isDirty = currentNote != originNote;
    print('DEBUG: Is dirty - $isDirty');

    // Set the modified time
    final Note updatedNote = currentNote.copyWith(
      modifiedTime: DateTime.now(),
      stateNote: currentNote.stateNote,
    );
    print('DEBUG BLOC: updatedNote.stateNote = \\${updatedNote.stateNote}');

    // Check if the note is empty
    final bool isNoteEmpty =
        currentNote.title.trim().isEmpty && currentNote.content.trim().isEmpty;
    print('DEBUG: Is empty - $isNoteEmpty');

    if (_isNewNote) {
      if (isNoteEmpty) {
        print('DEBUG: New note is empty, showing confirmation dialog...');
        emit(ShowDiscardConfirmationState());
      } else {
        print('DEBUG: Adding new note...');
        add(AddNote(updatedNote));
        emit(GoPopNoteState(updatedNote));
      }
    } else if (isDirty) {
      print('DEBUG: Updating existing note...');
      add(UpdateNote(updatedNote));
      emit(GoPopNoteState(updatedNote));
    } else {
      print('DEBUG: No changes, popping...');
      emit(GoPopNoteState(updatedNote));
    }
  }

  /// Xử lý sự kiện [MoveNote] để di chuyển ghi chú sang trạng thái khác (ví dụ: lưu trữ, thùng rác).
  _onMoveNote(MoveNote event, Emitter<NoteState> emit) async {
    final bool existsNote = event.note != null;
    final StatusNote newStatus = event.newStatus;
    print(
        'DEBUG MOVE: event.note.stateNote = \\${event.note?.stateNote}, newStatus = \\${newStatus}');

    print(
        'DEBUG MOVE: Moving note - exists: $existsNote, new status: $newStatus');
    if (event.note != null) {
      print(
          'DEBUG MOVE: Note details - id: ${event.note!.id}, title: ${event.note!.title}, current state: ${event.note!.stateNote}');
    }

    if (!existsNote) {
      print('DEBUG MOVE: Note does not exist, emitting empty state');
      emit(const EmptyInputsState(EMPTY_TEXT_MSG));
      emit(GoPopNoteState(event.note!));
      return;
    }

    oldNote = event.note!;

    Future<NoteState> updateNoteAndEmit({
      required StatusNote statusNote,
      required NoteState successState,
    }) async {
      final old = event.note!;
      print(
          'DEBUG MOVE: updateNoteAndEmit - old.stateNote = \\${old.stateNote}, statusNote = \\${statusNote}');

      final updatedNote = old.copyWith(
        id: old.id,
        title: old.title,
        content: old.content,
        createdAt: old.createdAt,
        modifiedTime: DateTime.now(),
        colorIndex: old.colorIndex,
        stateNote: statusNote,
        taskStatus: old.taskStatus,
        deadline: old.deadline,
        tags: old.tags,
        isCompleted: old.isCompleted,
        reminder: old.reminder,
        previousStateNote: old.previousStateNote,
      );
      print('DEBUG MOVE: updatedNote.stateNote = \\${updatedNote.stateNote}');
      final failureOrSuccess = await updateNote(updatedNote);
      return failureOrSuccess.fold(
        (failure) {
          print('DEBUG MOVE: Update failed - \\${_mapFailureMsg(failure)}');
          return ErrorState(
            _mapFailureMsg(failure),
            _getDrawerSectionForStatus(statusNote),
          );
        },
        (_) {
          print('DEBUG MOVE: Update successful');
          return successState;
        },
      );
    }

    NoteState? newState;

    switch (newStatus) {
      case StatusNote.archived:
        print('DEBUG MOVE: Processing archive action');
        newState = await updateNoteAndEmit(
          statusNote: newStatus,
          successState: ToggleSuccessState(
            event.note!.stateNote == StatusNote.pinned
                ? NOTE_ARCHIVE_WITH_UNPINNED_MSG
                : NOTE_ARCHIVE_MSG,
          ),
        );
        break;
      case StatusNote.undefined:
        print('DEBUG MOVE: Processing unarchive action');
        newState = await updateNoteAndEmit(
          statusNote: newStatus,
          successState: const ToggleSuccessState(NOTE_UNARCHIVED_MSG),
        );
        break;
      case StatusNote.trash:
        print('DEBUG MOVE: Processing move to trash action');
        newState = await updateNoteAndEmit(
          statusNote: newStatus,
          successState: const ToggleSuccessState(MOVE_NOTE_TRASH_MSG),
        );
        break;
      case StatusNote.pinned:
        print('DEBUG MOVE: Processing pin action');
        break;
    }

    if (newState != null) {
      print('DEBUG MOVE: Emitting new state');
      emit(newState);
    }
  }

  /// Trả về [DrawerSectionView] tương ứng với [StatusNote].
  DrawerSectionView _getDrawerSectionForStatus(StatusNote status) {
    switch (status) {
      case StatusNote.archived:
        return DrawerSectionView.archive;
      case StatusNote.trash:
        return DrawerSectionView.trash;
      case StatusNote.undefined:
      case StatusNote.pinned:
        return DrawerSectionView.home;
    }
  }

  /// Xử lý sự kiện [UndoMoveNote] để hoàn tác thao tác di chuyển ghi chú.
  _onUndoMoveNote(UndoMoveNote event, Emitter<NoteState> emit) async {
    await updateNote(oldNote!);
    emit(GoPopNoteState(oldNote!));
  }

  /// Xử lý sự kiện [LoadStatistics] để tải và tính toán dữ liệu thống kê.
  _onLoadStatistics(LoadStatistics event, Emitter<NoteState> emit) async {
    emit(LoadingState(DrawerSelect.drawerSection));
    final failureOrLoaded = await getNotes();

    emit(failureOrLoaded.fold(
      (failure) => ErrorState(
        _mapFailureMsg(failure),
        DrawerSelect.drawerSection,
      ),
      (notes) {
        if (notes.isEmpty) {
          return EmptyNoteState(DrawerSelect.drawerSection);
        }

        final completedTasks = notes
            .where((note) => note.taskStatus == TaskStatus.completed)
            .length;
        final ongoingTasks = notes
            .where((note) => note.taskStatus == TaskStatus.inProgress)
            .length;
        final notStartedTasks = notes
            .where((note) => note.taskStatus == TaskStatus.notStarted)
            .length;
        final trashedTasks =
            notes.where((note) => note.stateNote == StatusNote.trash).length;
        final totalTasks = notes.length;

        final notesByDate = <String, int>{};
        for (var note in notes) {
          final date = DateFormat('yyyy-MM-dd').format(note.modifiedTime);
          notesByDate[date] = (notesByDate[date] ?? 0) + 1;
        }

        final statistics = NoteStatistics(
          totalTasks: totalTasks,
          completedTasks: completedTasks,
          ongoingTasks: ongoingTasks,
          notStartedTasks: notStartedTasks,
          trashedTasks: trashedTasks,
          notesByDate: notesByDate,
        );

        return StatisticsLoadedState(statistics, notes);
      },
    ));
  }

  /// Xử lý sự kiện [FilterNotesByStatus] để lọc ghi chú theo trạng thái.
  _onFilterNotesByStatus(FilterNotesByStatus event, Emitter<NoteState> emit) {
    filterStatus = event.status;
    add(LoadNotes(drawerSectionView: DrawerSectionView.home));
  }

  /// Ánh xạ kết quả tải ghi chú từ usecase sang trạng thái [NoteState] phù hợp.
  ///
  /// [failureOrLoaded] Kết quả từ usecase [getNotes].
  /// [drawerSectionView] Chế độ xem hiện tại của ngăn kéo.
  /// Trả về một [NoteState] mới.
  NoteState _mapLoadNotesState(
    Either<Failure, List<Note>> failureOrLoaded,
    DrawerSectionView drawerSectionView,
  ) {
    return failureOrLoaded.fold(
      (failure) => ErrorState(
        _mapFailureMsg(failure),
        drawerSectionView,
      ),
      (notes) {
        print('DEBUG LOAD: Tổng số note (trước lọc) = ${notes.length}');
        notes.forEach((n) => print(
            '  - id: ${n.id}, title: ${n.title}, stateNote: ${n.stateNote}, taskStatus: ${n.taskStatus}'));
        if (notes.isEmpty) {
          print('DEBUG LOAD: Notes list is empty, returning EmptyNoteState.');
          return EmptyNoteState(drawerSectionView);
        }

        List<Note> pinnedNotes = [];
        List<Note> otherNotes = [];

        switch (drawerSectionView) {
          case DrawerSectionView.home:
            pinnedNotes = notes
                .where((note) => note.stateNote == StatusNote.pinned)
                .toList();
            otherNotes = notes
                .where((note) => note.stateNote == StatusNote.undefined)
                .toList();
            break;
          case DrawerSectionView.archive:
            otherNotes = notes
                .where((note) => note.stateNote == StatusNote.archived)
                .toList();
            break;
          case DrawerSectionView.trash:
            otherNotes = notes
                .where((note) => note.stateNote == StatusNote.trash)
                .toList();
            break;
        }
        print(
            'DEBUG LOAD: Sau lọc - pinnedNotes: ${pinnedNotes.length}, otherNotes: ${otherNotes.length}');
        pinnedNotes.forEach((n) => print(
            '  - PINNED - id: ${n.id}, title: ${n.title}, stateNote: ${n.stateNote}, taskStatus: ${n.taskStatus}'));
        otherNotes.forEach((n) => print(
            '  - OTHER - id: ${n.id}, title: ${n.title}, stateNote: ${n.stateNote}, taskStatus: ${n.taskStatus}'));

        // Sắp xếp: nếu bật switch thì note mới vào cuối
        _sortOtherNotesBySetting(otherNotes);

        return NotesViewState(otherNotes, pinnedNotes);
      },
    );
  }

  /// Sắp xếp danh sách ghi chú khác (không ghim) dựa trên cài đặt người dùng.
  ///
  /// [otherNotes] Danh sách ghi chú cần sắp xếp.
  Future<void> _sortOtherNotesBySetting(List<Note> otherNotes) async {
    final prefs = await SharedPreferences.getInstance();
    final bool addToEnd = prefs.getBool('them_muc_moi') ?? false;
    if (addToEnd && otherNotes.isNotEmpty) {
      otherNotes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else if (otherNotes.isNotEmpty) {
      otherNotes.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    }
  }

  /// Ánh xạ [Failure] sang thông báo lỗi phù hợp.
  String _mapFailureMsg(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return DATABASE_FAILURE_MSG;
      case NoDataFailure:
        return NO_DATA_FAILURE_MSG;
      default:
        return 'Unexpected Error , Please try again later . ';
    }
  }
}
