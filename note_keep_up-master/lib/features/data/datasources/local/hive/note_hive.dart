import 'package:hive/hive.dart';

import 'state_note_hive.dart';
import 'reminder_hive.dart';

part 'note_hive.g.dart';

@HiveType(typeId: 0)
class NoteHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  int colorIndex;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime modifiedTime;

  @HiveField(6)
  StateNoteHive stateNoteHive;

  @HiveField(7)
  int taskStatus;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime? deadline;

  @HiveField(10)
  ReminderHive? reminder;
  @HiveField(11)
  String userId;

  NoteHive({
    required this.userId,
    required this.id,
    required this.title,
    required this.content,
    required this.colorIndex,
    required this.createdAt,
    required this.modifiedTime,
    required this.stateNoteHive,
    required this.taskStatus,
    required this.isCompleted,
    this.deadline,
    this.reminder,
  });
}
