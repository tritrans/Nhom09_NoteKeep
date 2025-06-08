import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../domain/entities/note.dart';
import '../../blocs/blocs.dart';
import './widgets/widgets.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarAchive(),
      drawer: const AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<NoteBloc, NoteState>(
      listener: (context, state) => _displayNotesMsg(context, state),
      builder: (context, state) {
        print('DEBUG ARCHIVE: State = \\${state.runtimeType}');
        if (state is LoadingState) {
          return CommonLoadingNotes(state.drawerSectionView);
        } else if (state is EmptyNoteState) {
          return CommonEmptyNotes(state.drawerSectionView);
        } else if (state is ErrorState) {
          return CommonEmptyNotes(state.drawerSectionView);
        } else if (state is NotesViewState) {
          print(
              'DEBUG ARCHIVE: NotesViewState - otherNotes: \\${state.otherNotes.length}');
          return CommonNotesView(
            drawerSection: DrawerSectionView.archive,
            otherNotes: state.otherNotes,
            pinnedNotes: const [],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _displayNotesMsg(BuildContext context, NoteState state) {
    print('DEBUG ARCHIVE: _displayNotesMsg - state: \\${state.runtimeType}');
    if (state is SuccessState) {
      context.read<NoteBloc>().add(
          const RefreshNotes(drawerSectionView: DrawerSectionView.archive));
      AppAlerts.displaySnackbarMsg(context, state.message);
    } else if (state is ToggleSuccessState) {
      context.read<NoteBloc>().add(
          const RefreshNotes(drawerSectionView: DrawerSectionView.archive));
      AppAlerts.displaySnackarUndoMove(context, state.message);
    } else if (state is GoPopNoteState) {
      context.read<NoteBloc>().add(
          const RefreshNotes(drawerSectionView: DrawerSectionView.archive));
    } else if (state is GetNoteByIdState) {
      _getNoteByIdState(context, state.note);
    }
  }

  void _getNoteByIdState(BuildContext context, Note note) {
    context.read<StatusIconsCubit>().toggleIconsStatus(note);
    context.read<NoteBloc>().add(ModifColorNote(note.colorIndex));
    context.pushNamed(
      AppRouterName.note.name,
      pathParameters: {'id': note.id},
      extra: note,
    );
  }
}
