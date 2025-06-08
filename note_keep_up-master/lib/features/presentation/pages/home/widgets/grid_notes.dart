import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../domain/entities/note.dart';
import '../../../blocs/blocs.dart';
import '../../../../../../core/core.dart';

class GridNotes extends StatelessWidget {
  final List<Note> notes;
  final bool isShowDismisse;
  final DrawerSectionView? drawerSection;
  final Widget Function(Note)? moreOptionsBuilder;

  const GridNotes({
    Key? key,
    required this.notes,
    this.isShowDismisse = false,
    this.drawerSection,
    this.moreOptionsBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusGridCubit, StatusGridState>(
      builder: (context, state) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: _buildMasonryGrid(
            currentStatusCrossCount(
              (state as StatusGridViewState).currentStatus,
            ),
          ),
        );
      },
    );
  }

  int currentStatusCrossCount(GridStatus currentStatus) =>
      currentStatus == GridStatus.multiView ? 2 : 1;

  Widget _buildMasonryGrid(int crossAxisCount) {
    return SliverMasonryGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      childCount: notes.length,
      itemBuilder: (_, index) {
        final Note itemNote = notes[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ItemDismissibleNote(
            itemNote: itemNote,
            isShowDismisse: isShowDismisse,
            drawerSection: drawerSection,
            moreOptionsBuilder: moreOptionsBuilder,
          ),
        );
      },
    );
  }
}
