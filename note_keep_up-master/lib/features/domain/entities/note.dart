import 'package:equatable/equatable.dart';

import '../../../core/core.dart';
import 'package:note_app/features/domain/entities/reminder.dart';

enum TaskStatus { notStarted, inProgress, completed }

class Note extends Equatable {
  final String userId;
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedTime;
  final int colorIndex;
  final StatusNote stateNote;
  final TaskStatus taskStatus;
  final DateTime? deadline;
  final List<String>? tags;
  final bool isCompleted;
  final Reminder? reminder;
  final StatusNote? previousStateNote;

  const Note({
    required this.userId,
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedTime,
    required this.colorIndex,
    required this.stateNote,
    this.taskStatus = TaskStatus.notStarted,
    this.deadline,
    this.tags,
    this.isCompleted = false,
    this.reminder,
    this.previousStateNote,
  });

  // Define the copyWith method here
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedTime,
    int? colorIndex,
    StatusNote? stateNote,
    TaskStatus? taskStatus,
    DateTime? deadline,
    List<String>? tags,
    bool? isCompleted,
    Reminder? reminder,
    StatusNote? previousStateNote,
  }) {
    return Note(
      userId: userId,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      colorIndex: colorIndex ?? this.colorIndex,
      stateNote: stateNote ?? this.stateNote,
      taskStatus: taskStatus ?? this.taskStatus,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      reminder: reminder ?? this.reminder,
      previousStateNote: previousStateNote ?? this.previousStateNote,
    );
  }

  Note.empty({
    required this.userId,
    String? id,
    this.title = '',
    this.content = '',
    DateTime? createdAt,
    DateTime? modifiedTime,
    this.colorIndex = 0,
    this.stateNote = StatusNote.undefined,
    this.taskStatus = TaskStatus.notStarted,
    this.deadline,
    this.tags,
    this.isCompleted = false,
    this.reminder,
    this.previousStateNote,
  })  : id = id ?? UUIDGen.generate(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedTime = modifiedTime ?? DateTime.now();

  @override
  List<Object?> get props => [
        userId,
        id,
        title,
        content,
        createdAt,
        modifiedTime,
        colorIndex,
        stateNote,
        taskStatus,
        deadline,
        tags,
        isCompleted,
        reminder,
        previousStateNote,
      ];
}
