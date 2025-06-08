import 'package:equatable/equatable.dart';

class NoteStatistics extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int ongoingTasks;
  final int notStartedTasks;
  final int trashedTasks;
  final Map<String, int> notesByDate;

  const NoteStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.ongoingTasks,
    required this.notStartedTasks,
    required this.trashedTasks,
    required this.notesByDate,
  });

  @override
  List<Object?> get props => [
        totalTasks,
        completedTasks,
        ongoingTasks,
        notStartedTasks,
        trashedTasks,
        notesByDate,
      ];
}
