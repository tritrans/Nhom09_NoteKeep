import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/features/presentation/blocs/note/note_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../domain/entities/note.dart';
import './widgets.dart';
// import '../../../../../../domain/blocs/note_bloc.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar(
    this.getCurrentNote,
    this.undoController,
  ) : super(key: null);

  final UndoHistoryController undoController;
  final Note Function() getCurrentNote;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  bool isShowUndoRedo = false;

  @override
  void initState() {
    _loadListenerUndo();
    super.initState();
  }

  _loadListenerUndo() {
    widget.undoController.addListener(
      () => setState(
        () => isShowUndoRedo = true,
      ),
    );
  }

  @override
  void dispose() {
    widget.undoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Note latestNote = widget.getCurrentNote();
    return CommonBottomAppBar(
      isShowFAB: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ColorIconNote(
            press: () => _showModalBottomSheet(
                sheetPopoverType: SheetPopover.coloring, note: latestNote),
          ),
          isShowUndoRedo
              ? UndoRedoButtons(undoController: widget.undoController)
              : Text(
                  FormatDateTime.getFormatDateTime(latestNote.modifiedTime),
                ),
          MoreIconNote(
            pressMore: () => _showModalBottomSheet(
                sheetPopoverType: SheetPopover.more, note: latestNote),
            pressRecovery: () => _showModalBottomSheet(
                sheetPopoverType: SheetPopover.recovery, note: latestNote),
          )
        ],
      ),
    );
  }

  void _showModalBottomSheet({
    required SheetPopover sheetPopoverType,
    required Note note,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => CommonPopover(
        child: () {
          switch (sheetPopoverType) {
            case SheetPopover.coloring:
              return PopoverColoringNote();
            case SheetPopover.more:
              return PopoverMoreNote(
                note: note,
                currentSection: _getCurrentSection(note),
                // onArchive: () {
                //   print('DEBUG BOTTOM_BAR: onArchive callback called');
                //   context.read<NoteBloc>().add(
                //       MoveNote(note: note, newStatus: StatusNote.archived));
                // },
                // onTrash: () {
                //   print('DEBUG BOTTOM_BAR: onTrash callback called');
                //   context
                //       .read<NoteBloc>()
                //       .add(MoveNote(note: note, newStatus: StatusNote.trash));
                // },
              );
            case SheetPopover.recovery:
              return PopoverRecoveryNote(note: note);
          }
        }(),
      ),
    );
  }

  DrawerSectionView _getCurrentSection(Note note) {
    switch (note.stateNote) {
      case StatusNote.archived:
        return DrawerSectionView.archive;
      case StatusNote.trash:
        return DrawerSectionView.trash;
      default:
        return DrawerSectionView.home;
    }
  }
}
