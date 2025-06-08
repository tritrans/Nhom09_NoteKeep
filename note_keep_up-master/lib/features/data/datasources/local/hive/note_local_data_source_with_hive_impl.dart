import 'package:dartz/dartz.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_app/core/core.dart';
import 'package:path_provider/path_provider.dart';
import 'reminder_hive.dart';
import 'note_hive.dart';
import '../note_local_data_source.dart';
import '../../../model/note_model.dart';
import 'state_note_hive.dart';
import 'package:note_app/features/domain/entities/note.dart';
import 'package:note_app/features/domain/entities/reminder.dart';
import 'package:note_app/features/data/datasources/auth_service.dart';

class NoteLocalDataSourceWithHiveImpl implements NoteLocalDataSourse {
  final String _boxNote = 'note_box';
  @override
  Future<bool> initDb() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NoteHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ReminderHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(StateNoteHiveAdapter());
      }

      await Hive.openBox<NoteHive>(_boxNote);
      return true;
    } catch (e) {
      print('Error initializing database: $e');
      throw ConnectionException();
    }
  }

  @override
  Future<List<NoteModel>> getAllNote() async {
    try {
      final currentUserId = AuthService().currentUser?.uid;
      final noteBox = Hive.box<NoteHive>(_boxNote);

      final List<NoteModel> resultNotes = noteBox.values
          .where((note) => note.userId == currentUserId) // LỌC THEO USERID
          .map(
            (note) => NoteModel(
              userId: note.userId,
              id: note.id,
              title: note.title,
              content: note.content,
              colorIndex: note.colorIndex,
              createdAt: note.createdAt,
              modifiedTime: note.modifiedTime,
              stateNote: note.stateNoteHive.stateNote,
              taskStatus: TaskStatus.values[note.taskStatus],
              isCompleted: note.isCompleted,
              deadline: note.deadline,
              reminder: note.reminder == null
                  ? null
                  : Reminder(
                      id: note.id,
                      noteId: note.id,
                      reminderTime: note.reminder!.reminderTime,
                      repeatType: RepeatType.values[note.reminder!.repeatType],
                      isActive: true,
                    ),
            ),
          )
          .toList();
      print('DEBUG DS: getAllNote - noteBox.values:');
      noteBox.values.forEach((n) => print(
          '  - id: \\${n.id}, title: \\${n.title}, stateNoteHive: \\${n.stateNoteHive}'));
      print('DEBUG DS: getAllNote - resultNotes:');
      resultNotes.forEach((n) => print(
          '  - id: \\${n.id}, title: \\${n.title}, stateNote: \\${n.stateNote}'));
      return resultNotes;
    } catch (_) {
      throw NoDataException();
    }
  }

  @override
  Future<NoteModel> getNoteById(String noteModelById) async {
    try {
      final noteBox = Hive.box<NoteHive>(_boxNote);

      final NoteHive resultNote = noteBox.values.firstWhere(
        (element) => element.id == noteModelById,
      );

      return NoteModel(
        userId: resultNote.userId,
        id: resultNote.id,
        title: resultNote.title,
        content: resultNote.content,
        colorIndex: resultNote.colorIndex,
        createdAt: resultNote.createdAt,
        modifiedTime: resultNote.modifiedTime,
        stateNote: resultNote.stateNoteHive.stateNote,
        taskStatus: TaskStatus.values[resultNote.taskStatus],
        isCompleted: resultNote.isCompleted,
        deadline: resultNote.deadline,
        reminder: resultNote.reminder == null
            ? null
            : Reminder(
                id: resultNote.id,
                noteId: resultNote.id,
                reminderTime: resultNote.reminder!.reminderTime,
                repeatType: RepeatType.values[resultNote.reminder!.repeatType],
                isActive: true,
              ),
      );
    } catch (_) {
      throw NoDataException();
    }
  }

  @override
  Future<Unit> addNote(NoteModel noteModel) async {
    print('DEBUG DS: addNote - noteModel.stateNote = \\${noteModel.stateNote}');
    print(
        'DEBUG DS: addNote nhận NoteModel.reminder = \\${noteModel.reminder}');
    try {
      print(
          'DEBUG DS: Adding note to Hive - \\${noteModel.title}, \\${noteModel.content}');
      final noteBox = Hive.box<NoteHive>(_boxNote);
      final noteKey = noteModel.id;
      final NoteHive noteHive = NoteHive(
        userId: noteModel.userId,
        id: noteModel.id,
        title: noteModel.title,
        content: noteModel.content,
        colorIndex: noteModel.colorIndex,
        createdAt: noteModel.createdAt,
        modifiedTime: noteModel.modifiedTime,
        stateNoteHive: noteModel.stateNote.stateNoteHive,
        taskStatus: noteModel.taskStatus.index,
        isCompleted: noteModel.isCompleted,
        deadline: noteModel.deadline,
        reminder: noteModel.reminder == null
            ? null
            : ReminderHive(
                reminderTime: noteModel.reminder!.reminderTime,
                repeatType: noteModel.reminder!.repeatType.index,
              ),
      );
      print('DEBUG DS: NoteHive.reminder = \\${noteHive.reminder}');
      print('DEBUG DS: NoteHive.stateNoteHive = \\${noteHive.stateNoteHive}');
      print('DEBUG DS: Converting to NoteHive successful');
      await noteBox.put(noteKey, noteHive);
      print('DEBUG DS: Note added to Hive successfully');
      // In ra toàn bộ danh sách note trong Hive
      print('DEBUG DS: Danh sách note trong Hive sau add:');
      noteBox.values.forEach((n) {
        print(
            '  - id: \\${n.id}, title: \\${n.title}, state: \\${n.stateNoteHive}');
      });
      return unit;
    } catch (e) {
      print('DEBUG DS: Error adding note to Hive - \\${e}');
      throw NoDataException();
    }
  }

  @override
  Future<Unit> updateNote(NoteModel noteModel) async {
    print(
        'DEBUG DS UPDATE: updateNote - noteModel.stateNote = \\${noteModel.stateNote}');
    try {
      print(
          'DEBUG DS UPDATE: Updating note in Hive - id: \\${noteModel.id}, title: \\${noteModel.title}, state: \\${noteModel.stateNote}');
      final noteBox = Hive.box<NoteHive>(_boxNote);
      final indexNoteId = noteModel.id;
      final NoteHive noteHive = NoteHive(
        userId: noteModel.userId,
        id: noteModel.id,
        title: noteModel.title,
        content: noteModel.content,
        colorIndex: noteModel.colorIndex,
        createdAt: noteModel.createdAt,
        modifiedTime: noteModel.modifiedTime,
        stateNoteHive: noteModel.stateNote.stateNoteHive,
        taskStatus: noteModel.taskStatus.index,
        isCompleted: noteModel.isCompleted,
        deadline: noteModel.deadline,
        reminder: noteModel.reminder == null
            ? null
            : ReminderHive(
                reminderTime: noteModel.reminder!.reminderTime,
                repeatType: noteModel.reminder!.repeatType.index,
              ),
      );
      print('DEBUG DS UPDATE: Converting to NoteHive successful');
      print(
          'DEBUG DS UPDATE: NoteHive.stateNoteHive = \\${noteHive.stateNoteHive}');
      await noteBox.put(indexNoteId, noteHive);
      print('DEBUG DS UPDATE: Note updated in Hive successfully');
      // In ra toàn bộ danh sách note trong Hive
      print('DEBUG DS: Danh sách note trong Hive sau update:');
      noteBox.values.forEach((n) {
        print(
            '  - id: \\${n.id}, title: \\${n.title}, state: \\${n.stateNoteHive}');
      });
      return unit;
    } catch (e) {
      print('DEBUG DS UPDATE: Error updating note in Hive - \\${e}');
      throw NoDataException();
    }
  }

  @override
  Future<Unit> deleteNote(String noteModelId) async {
    try {
      final noteBox = Hive.box<NoteHive>(_boxNote);
      await noteBox.delete(noteModelId);
      // In ra toàn bộ danh sách note trong Hive
      print('DEBUG DS: Danh sách note trong Hive sau delete:');
      noteBox.values.forEach((n) {
        print(
            '  - id: \\${n.id}, title: \\${n.title}, state: \\${n.stateNoteHive}');
      });
      return unit;
    } catch (_) {
      throw NoDataException();
    }
  }
}
