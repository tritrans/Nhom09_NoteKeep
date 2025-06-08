import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../domain/entities/note.dart';
import '../../blocs/blocs.dart';
import '../../widgets/note/note_card.dart';
import '../../pages/note/widget/popover_recovery_note.dart';
import 'widgets/app_bar_trash.dart';

class TrashPage extends StatelessWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarTrash(),
      drawer: const AppDrawer(),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) => _displayNotesMsg(context, state),
        builder: (context, state) {
          print('DEBUG TRASH: State = \\${state.runtimeType}');
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotesViewState) {
            final trashedNotes = state.otherNotes
                .where((note) => note.stateNote == StatusNote.trash)
                .toList();
            print(
                'DEBUG TRASH: NotesViewState - otherNotes: \\${state.otherNotes.length}, trashedNotes: \\${trashedNotes.length}');

            if (trashedNotes.isEmpty) {
              return const Center(
                child: Text('No trashed notes'),
              );
            }

            return ListView.builder(
              itemCount: trashedNotes.length,
              itemBuilder: (context, index) {
                final note = trashedNotes[index];
                return NoteCard(
                  note: note,
                  onTap: () => context.pushNamed(
                    'note',
                    pathParameters: {'id': note.id},
                    extra: note,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => PopoverRecoveryNote(note: note),
                      );
                    },
                  ),
                );
              },
            );
          }

          if (state is ErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _displayNotesMsg(BuildContext context, NoteState state) {
    print('DEBUG TRASH: _displayNotesMsg - state: \\${state.runtimeType}');
    if (state is SuccessState || state is ToggleSuccessState) {
      context.read<NoteBloc>().add(
            LoadNotes(drawerSectionView: DrawerSectionView.trash),
          );
      if (state is SuccessState) {
        AppAlerts.displaySnackbarMsg(context, state.message);
      } else if (state is ToggleSuccessState) {
        AppAlerts.displaySnackarUndoMove(context, state.message);
      }
    } else if (state is GoPopNoteState) {
      context.read<NoteBloc>().add(
            LoadNotes(drawerSectionView: DrawerSectionView.trash),
          );
    }
  }
}
