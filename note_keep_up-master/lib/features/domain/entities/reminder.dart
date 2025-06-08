import 'package:equatable/equatable.dart';

enum RepeatType { none, daily, weekly, monthly }

class Reminder extends Equatable {
  final String id;
  final String noteId;
  final DateTime reminderTime;
  final RepeatType repeatType;
  final bool isActive;

  const Reminder({
    required this.id,
    required this.noteId,
    required this.reminderTime,
    this.repeatType = RepeatType.none,
    this.isActive = true,
  });

  Reminder copyWith({
    String? id,
    String? noteId,
    DateTime? reminderTime,
    RepeatType? repeatType,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatType: repeatType ?? this.repeatType,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, noteId, reminderTime, repeatType, isActive];
}
