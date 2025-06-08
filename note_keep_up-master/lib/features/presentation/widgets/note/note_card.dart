import 'package:flutter/material.dart';
import '../../../../core/core.dart' as core;
import '../../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: core.ColorNote.getColor(context, note.colorIndex),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.stateNote == core.StatusNote.pinned)
                    const Icon(Icons.push_pin, size: 16),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTaskStatusText(note.taskStatus),
                    style: TextStyle(
                      color: _getTaskStatusColor(note.taskStatus),
                      fontSize: 12,
                    ),
                  ),
                  if (note.deadline != null)
                    Text(
                      'Deadline: ${note.deadline!.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Chưa bắt đầu';
      case TaskStatus.inProgress:
        return 'Đang thực hiện';
      case TaskStatus.completed:
        return 'Đã hoàn thành';
      default:
        return 'Chưa bắt đầu';
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
