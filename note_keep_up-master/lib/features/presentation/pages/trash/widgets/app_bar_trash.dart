import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../domain/entities/note.dart';
import '../../../blocs/blocs.dart';

class AppBarTrash extends StatelessWidget implements PreferredSizeWidget {
  const AppBarTrash({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Thùng rác'),
      actions: [
        BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NotesViewState) {
              final trashedNotes = state.otherNotes
                  .where((note) => note.stateNote == StatusNote.trash)
                  .toList();

              if (trashedNotes.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: 'Khôi phục tất cả',
                  onPressed: () => _onRestoreAll(context, trashedNotes),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _onRestoreAll(BuildContext context, List<Note> notes) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content:
            const Text('Bạn có muốn khôi phục tất cả ghi chú trong thùng rác?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog

              final noteBloc = context.read<NoteBloc>();
              // Restore each note
              for (final note in notes) {
                final updatedNote = note.copyWith(
                  stateNote: StatusNote.undefined,
                  modifiedTime: DateTime.now(),
                );
                noteBloc.add(MoveNote(
                    note: updatedNote, newStatus: StatusNote.undefined));
              }

              // Show feedback
              AppAlerts.displaySnackbarMsg(
                context,
                'Đã khôi phục ${notes.length} ghi chú',
              );
            },
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
