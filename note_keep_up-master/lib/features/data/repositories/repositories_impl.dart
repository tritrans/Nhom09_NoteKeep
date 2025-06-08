import 'package:dartz/dartz.dart';

import '../../../core/util/util.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/local/note_local_data_source.dart';
import '../model/note_model.dart';

class NoteRepositoriesImpl implements NoteRepositories {
  final NoteLocalDataSourse noteLocalDataSourse;

  NoteRepositoriesImpl({
    required this.noteLocalDataSourse,
  });

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      final response = await noteLocalDataSourse.getAllNote();
      return Right(response);
    } on NoDataException {
      return Left(NoDataFailure());
    }
  }

  @override
  Future<Either<Failure, Note>> getNoteById(String noteId) async {
    try {
      final response = await noteLocalDataSourse.getNoteById(noteId);
      return Right(response);
    } on NoDataException {
      return Left(NoDataFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addNote(Note note) async {
    try {
      print('DEBUG REPO: Adding note - ${note.title}, ${note.content}');
      if (note.title.isEmpty && note.content.isEmpty) {
        print('DEBUG REPO: Note is empty, returning failure');
        return Left(EmpytInputFailure());
      } else {
        final NoteModel convertToNoteModel = NoteModel(
          userId: note.userId,
          id: note.id,
          title: note.title,
          content: note.content,
          colorIndex: note.colorIndex,
          createdAt: note.createdAt,
          modifiedTime: note.modifiedTime,
          stateNote: note.stateNote,
          taskStatus: note.taskStatus,
          isCompleted: note.isCompleted,
          deadline: note.deadline,
          reminder: note.reminder,
        );
        print('DEBUG REPO: Converting to NoteModel successful');
        await noteLocalDataSourse.addNote(convertToNoteModel);
        print('DEBUG REPO: Note added successfully');
        return const Right(unit);
      }
    } on NoDataException {
      print('DEBUG REPO: NoDataException occurred');
      return Left(NoDataFailure());
    } catch (e) {
      print('DEBUG REPO: Unexpected error - $e');
      return Left(NoDataFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNote(Note note) async {
    try {
      print(
          'DEBUG REPO UPDATE: Updating note - id: ${note.id}, title: ${note.title}, state: ${note.stateNote}');
      final NoteModel convertToNoteModel = NoteModel(
        userId: note.userId,
        id: note.id,
        title: note.title,
        content: note.content,
        colorIndex: note.colorIndex,
        createdAt: note.createdAt,
        modifiedTime: note.modifiedTime,
        stateNote: note.stateNote,
        taskStatus: note.taskStatus,
        isCompleted: note.isCompleted,
        deadline: note.deadline,
        reminder: note.reminder,
      );
      print('DEBUG REPO UPDATE: Converting to NoteModel successful');
      await noteLocalDataSourse.updateNote(convertToNoteModel);
      print('DEBUG REPO UPDATE: Note updated successfully');
      return const Right(unit);
    } on NoDataException {
      print('DEBUG REPO UPDATE: NoDataException occurred');
      return Left(NoDataFailure());
    } catch (e) {
      print('DEBUG REPO UPDATE: Unexpected error - $e');
      return Left(NoDataFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNote(String noteId) async {
    try {
      await noteLocalDataSourse.deleteNote(noteId);
      return const Right(unit);
    } on NoDataException {
      return Left(NoDataFailure());
    }
  }

  // Future<Either<Failure, T>> executeAndHandleError<T>(
  //   Future<T> Function() function,
  // ) async {
  //   try {
  //     final result = await function();
  //     return Right(result);
  //   } on NoDataException {
  //     return Left(NoDataFailure());
  //   }
  // }
}
