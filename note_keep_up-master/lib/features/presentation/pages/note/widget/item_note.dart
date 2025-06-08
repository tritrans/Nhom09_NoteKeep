import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../domain/entities/note.dart';
import '../../../blocs/blocs.dart';
import '../../../../../core/widgets/item_note_card.dart';
import './popover_more_note.dart';

class ItemNote extends StatelessWidget {
  final Note note;
  final DrawerSectionView? drawerSection;
  final Widget Function(Note)? moreOptionsBuilder;

  const ItemNote({
    super.key,
    required this.note,
    this.drawerSection,
    this.moreOptionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArchived = note.stateNote == StatusNote.archived;
    final bool isTrash = drawerSection == DrawerSectionView.trash;

    return Card(
      color: ColorNote.getColor(context, note.colorIndex),
      margin: EdgeInsets.zero,
      elevation: .3,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            ItemNoteCard(note: note),
            if (isArchived && !isTrash)
              Positioned(
                top: 8,
                right: 40,
                child: Icon(
                  Icons.archive_outlined,
                  size: 20,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  isTrash ? Icons.restore : Icons.more_vert,
                  semanticLabel:
                      isTrash ? 'Khôi phục ghi chú' : 'Thêm tùy chọn',
                ),
                tooltip: isTrash ? 'Khôi phục ghi chú' : 'Thêm tùy chọn',
                onPressed: () => _showMoreOptions(context),
              ),
            ),
          ],
        ),
        onTap: () => _onTapItem(context),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          moreOptionsBuilder?.call(note) ??
          PopoverMoreNote(
            note: note,
            currentSection: drawerSection,
          ),
    );
  }

  void _onTapItem(BuildContext context) {
    if (note.title.startsWith(' Công ty -')) {
      AppAlerts.displaySnackbarMsg(context,
          'Đây là note tự động, không được chỉnh sửa hay xem chi tiết.');
      return;
    }
    context.read<StatusIconsCubit>().toggleIconsStatus(note);
    context.read<NoteBloc>().add(ModifColorNote(note.colorIndex));
    context.pushNamed(
      AppRouterName.note.name,
      pathParameters: {'id': note.id},
      extra: note,
    );
  }
}
