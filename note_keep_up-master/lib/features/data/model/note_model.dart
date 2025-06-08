import 'package:note_app/core/config/enum/status_note.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/reminder.dart';

class NoteModel extends Note {
  NoteModel({
    required String userId,
    required String id,
    required String title,
    required String content,
    required int colorIndex,
    required DateTime createdAt,
    required DateTime modifiedTime,
    required StatusNote stateNote,
    TaskStatus? taskStatus,
    DateTime? deadline,
    bool? isCompleted,
    Reminder? reminder,
  }) : super(
          userId: userId,
          id: id,
          title: title,
          content: content,
          colorIndex: colorIndex,
          createdAt: createdAt,
          modifiedTime: modifiedTime,
          stateNote: stateNote,
          taskStatus: taskStatus ?? TaskStatus.notStarted,
          deadline: deadline,
          isCompleted: isCompleted ?? false,
          reminder: reminder,
        ) {
    print('DEBUG MODEL: NoteModel tạo với reminder = $reminder');
  }
}
