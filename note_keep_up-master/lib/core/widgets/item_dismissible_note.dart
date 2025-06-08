import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/domain/entities/note.dart';
import '../../features/presentation/blocs/blocs.dart';
import '../../features/presentation/pages/note/widget/item_note.dart';
import '../core.dart';

class ItemDismissibleNote extends StatelessWidget {
  final DrawerSectionView? drawerSection;
  final Note itemNote;
  final bool isShowDismisse;
  final Widget Function(Note)? moreOptionsBuilder;

  const ItemDismissibleNote({
    super.key,
    required this.itemNote,
    required this.isShowDismisse,
    this.drawerSection,
    this.moreOptionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return isShowDismisse
        ? Dismissible(
            key: ValueKey<String>(itemNote.id),
            child: ItemNote(
              note: itemNote,
              drawerSection: drawerSection,
              moreOptionsBuilder: moreOptionsBuilder,
            ),
            onDismissed: (direction) => _onDismissed(context, itemNote),
          )
        : ItemNote(
            note: itemNote,
            drawerSection: drawerSection,
            moreOptionsBuilder: moreOptionsBuilder,
          );
  }

  void _onDismissed(BuildContext context, Note itemNote) {
    context
        .read<NoteBloc>()
        .add(MoveNote(note: itemNote, newStatus: StatusNote.archived));
  }
}
