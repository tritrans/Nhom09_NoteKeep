import 'package:flutter/material.dart';
import '../core.dart';
import '../../features/domain/entities/note.dart';
import '../../features/presentation/pages/note/widget/popover_more_note.dart';
import '../../features/presentation/pages/home/widgets/grid_notes.dart';

class CommonNotesView extends StatelessWidget {
  final DrawerSectionView drawerSection;
  final List<Note> otherNotes;
  final List<Note> pinnedNotes;
  final Widget Function(Note)? moreOptionsBuilder;

  const CommonNotesView({
    super.key,
    required this.drawerSection,
    required this.otherNotes,
    required this.pinnedNotes,
    this.moreOptionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final hasPinned = pinnedNotes.isNotEmpty;
    final hasOther = otherNotes.isNotEmpty;
    final hasNotes = hasPinned || hasOther;

    return RefreshIndicator(
      onRefresh: () => AppFunction.onRefresh(context, drawerSection),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (drawerSection == DrawerSectionView.home) ...[
                SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: CommonSearchBar(),
                ),
              ],
              if (hasPinned) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
                  child: Text(
                    'Pinned',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomScrollView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    GridNotes(
                      notes: pinnedNotes,
                      isShowDismisse: false,
                      drawerSection: drawerSection,
                      moreOptionsBuilder: (note) => PopoverMoreNote(
                          note: note, currentSection: drawerSection),
                    ),
                  ],
                ),
              ],
              if (hasOther) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomScrollView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    GridNotes(
                      notes: otherNotes,
                      isShowDismisse: drawerSection == DrawerSectionView.home,
                      drawerSection: drawerSection,
                      moreOptionsBuilder: (note) => PopoverMoreNote(
                          note: note, currentSection: drawerSection),
                    ),
                  ],
                ),
              ],
              if (!hasNotes)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No notes found.'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
