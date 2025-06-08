import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../domain/entities/note.dart';
import '../../../blocs/blocs.dart';

class PopoverRecoveryNote extends StatelessWidget {
  final Note note;

  const PopoverRecoveryNote({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Khôi phục'),
            onTap: () => _onRestoreNote(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Xóa vĩnh viễn'),
            onTap: () => _onDeleteForever(context),
          ),
        ],
      ),
    );
  }

  void _onRestoreNote(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    final StatusNote restoredState = note.previousStateNote == StatusNote.pinned
        ? StatusNote.pinned
        : StatusNote.undefined;
    final updatedNote = note.copyWith(
      stateNote: restoredState,
      modifiedTime: DateTime.now(),
      previousStateNote: null,
    );

    // Close the popover
    context.pop();

    // Add the move note event to restore
    noteBloc.add(MoveNote(note: updatedNote, newStatus: restoredState));

    // Show feedback
    AppAlerts.displaySnackbarMsg(context, 'Ghi chú đã được khôi phục');
  }

  void _onDeleteForever(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa vĩnh viễn ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(), // Close dialog
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Close popover

              // Delete the note
              context.read<NoteBloc>().add(DeleteNote(note.id));

              // Show feedback
              AppAlerts.displaySnackbarMsg(
                  context, 'Ghi chú đã được xóa vĩnh viễn');
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
