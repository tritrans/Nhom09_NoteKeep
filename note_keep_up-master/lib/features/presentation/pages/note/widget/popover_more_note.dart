import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/core.dart';
import '../../../../domain/entities/note.dart';
import '../../../blocs/blocs.dart';

class PopoverMoreNote extends StatelessWidget {
  final Note note;
  final DrawerSectionView? currentSection;

  const PopoverMoreNote({
    super.key,
    required this.note,
    this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArchived = currentSection == DrawerSectionView.archive;
    final bool isHome =
        currentSection == null || currentSection == DrawerSectionView.home;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isArchived || isHome) ...[
            ListTile(
              leading: AppIcons.trashNote,
              title: const Text('Move to Trash'),
              onTap: () => _onTrashNote(context),
            ),
          ],
          ListTile(
            leading: AppIcons.sendNote,
            title: const Text('Share'),
            onTap: () => _onShareNote(context),
          ),
          if (isArchived) ...[
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('Unarchive'),
              onTap: () => _onUnarchiveNote(context),
            ),
          ],
          if (!isArchived) ...[
            ListTile(
              leading: AppIcons.archiveNote,
              title: const Text('Archive'),
              onTap: () => _onArchiveNote(context),
            ),
          ],
        ],
      ),
    );
  }

  void _onArchiveNote(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    final updatedNote = note.copyWith(
      stateNote: StatusNote.archived,
      modifiedTime: DateTime.now(),
      previousStateNote: note.stateNote == StatusNote.pinned
          ? StatusNote.pinned
          : note.previousStateNote,
    );
    context.pop();
    noteBloc.add(MoveNote(note: updatedNote, newStatus: StatusNote.archived));
    AppAlerts.displaySnackbarMsg(context, 'Ghi chú đã được thêm vào Archive');
  }

  void _onUnarchiveNote(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    final StatusNote restoredState = note.previousStateNote == StatusNote.pinned
        ? StatusNote.pinned
        : StatusNote.undefined;
    final updatedNote = note.copyWith(
      stateNote: restoredState,
      modifiedTime: DateTime.now(),
      previousStateNote: null,
    );

    // Close the popover first
    context.pop();

    // Add the move note event
    noteBloc.add(MoveNote(note: updatedNote, newStatus: restoredState));

    // Show feedback
    AppAlerts.displaySnackbarMsg(
        context, 'Ghi chú đã được khôi phục từ Archive');
  }

  void _onTrashNote(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    final updatedNote = note.copyWith(
      stateNote: StatusNote.trash,
      modifiedTime: DateTime.now(),
      previousStateNote: note.stateNote == StatusNote.pinned
          ? StatusNote.pinned
          : note.previousStateNote,
    );
    context.pop();
    noteBloc.add(MoveNote(note: updatedNote, newStatus: StatusNote.trash));
    AppAlerts.displaySnackbarMsg(
        context, 'Ghi chú đã được chuyển vào Thùng rác');
  }

  void _onShareNote(BuildContext context) {
    Share.share(
      '${note.title}\n\n${note.content}',
      subject: note.title,
    );
    context.pop();
  }
}
