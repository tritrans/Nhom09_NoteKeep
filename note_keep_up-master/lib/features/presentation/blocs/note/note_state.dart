part of 'note_bloc.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class LoadingState extends NoteState {
  final DrawerSectionView drawerSectionView;

  const LoadingState(this.drawerSectionView);

  @override
  List<Object?> get props => [drawerSectionView];
}

class LoadedNotesState extends NoteState {
  final List<Note> notes;
  final DrawerSectionView drawerSectionView;

  const LoadedNotesState({
    required this.notes,
    required this.drawerSectionView,
  });

  @override
  List<Object?> get props => [notes, drawerSectionView];
}

class ErrorState extends NoteState {
  final String message;
  final DrawerSectionView drawerSectionView;

  const ErrorState(this.message, this.drawerSectionView);

  @override
  List<Object?> get props => [message, drawerSectionView];
}

class EmptyInputsState extends NoteState {
  final String message;

  const EmptyInputsState(this.message);

  @override
  List<Object?> get props => [message];
}

class ToggleSuccessState extends NoteState {
  final String message;

  const ToggleSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class GoPopNoteState extends NoteState {
  final Note note; // Thêm dòng này

  const GoPopNoteState(this.note); // Thêm constructor

  @override
  List<Object?> get props => [note];
}

class ModifedColorNoteState extends NoteState {
  final int colorIndex;

  const ModifedColorNoteState(this.colorIndex);

  @override
  List<Object?> get props => [colorIndex];
}

class AvailableNoteState extends NoteState {
  final Note note;

  const AvailableNoteState(this.note);

  @override
  List<Object?> get props => [note];
}

class ReadOnlyNoteState extends NoteState {
  final bool readOnly;

  const ReadOnlyNoteState(this.readOnly);

  @override
  List<Object?> get props => [readOnly];
}

final class NotesViewState extends NoteState {
  final List<Note> otherNotes;
  final List<Note> pinnedNotes;

  const NotesViewState(
    this.otherNotes,
    this.pinnedNotes,
  );
  @override
  List<Object> get props => [pinnedNotes, otherNotes];
}

final class GetNoteByIdState extends NoteState {
  final Note note;

  const GetNoteByIdState(this.note);

  @override
  List<Object> get props => [note];
}

//===>  MessageState

final class MessageState extends NoteState {
  final String message;

  const MessageState(this.message);
  @override
  List<Object> get props => [message];
}

final class SuccessState extends MessageState {
  const SuccessState(super.message);
}

final class EmptyNoteState extends NoteState {
  final DrawerSectionView drawerSectionView;

  const EmptyNoteState(
    this.drawerSectionView,
  );

  @override
  List<Object> get props => [drawerSectionView];
}

class StatisticsLoadedState extends NoteState {
  final NoteStatistics statistics;
  final List<Note> notes;
  const StatisticsLoadedState(this.statistics, this.notes);

  @override
  List<Object> get props => [statistics, notes];
}

final class ShowDiscardConfirmationState extends NoteState {}
