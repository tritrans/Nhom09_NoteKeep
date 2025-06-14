part of 'note_bloc.dart';

sealed class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

final class EmptyInputs extends NoteEvent {}

final class LoadNotes extends NoteEvent {
  final DrawerSectionView drawerSectionView;

  const LoadNotes({required this.drawerSectionView});

  @override
  List<Object?> get props => [drawerSectionView];
}

final class RefreshNotes extends NoteEvent {
  final DrawerSectionView drawerSectionView;

  const RefreshNotes({required this.drawerSectionView});

  @override
  List<Object?> get props => [drawerSectionView];
}

final class AddNote extends NoteEvent {
  final Note note;

  const AddNote(this.note);

  @override
  List<Object?> get props => [note];
}

final class GetNoteById extends NoteEvent {
  final String noteId;

  const GetNoteById(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

final class UpdateNote extends NoteEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class PopEmptyNote extends NoteEvent {
  const PopEmptyNote();
}

final class DeleteNote extends NoteEvent {
  final String noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

final class ModifColorNote extends NoteEvent {
  final int colorIndex;

  const ModifColorNote(this.colorIndex);

  @override
  List<Object?> get props => [colorIndex];
}

final class MoveNote extends NoteEvent {
  final Note? note;
  final StatusNote newStatus;

  const MoveNote({
    this.note,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [note, newStatus];
}

final class UndoMoveNote extends NoteEvent {}

final class PopNoteAction extends NoteEvent {
  final Note currentNote;
  final Note originNote;

  const PopNoteAction(this.currentNote, this.originNote);

  @override
  List<Object?> get props => [currentNote, originNote];
}

class LoadStatistics extends NoteEvent {
  const LoadStatistics();

  @override
  List<Object?> get props => [];
}

final class FilterNotesByStatus extends NoteEvent {
  final FilterStatus status;
  const FilterNotesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

// class AvailableNote extends NoteEvent {
//   final Note note;

//   const AvailableNote(
//     this.note,
//   );

//   @override
//   List<Object> get props => [note];
// }

// class ReadOnlyNote extends NoteEvent {
//   final Note note;

//   const ReadOnlyNote(
//     this.note,
//   );

//   @override
//   List<Object> get props => [note];
// }
