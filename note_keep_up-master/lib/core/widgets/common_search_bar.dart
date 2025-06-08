import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/presentation/blocs/blocs.dart';
import '../core.dart';
import 'package:note_app/core/config/enum/filter_status.dart';

class CommonSearchBar extends StatefulWidget {
  const CommonSearchBar({super.key});

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  final String hintText = 'Search your notes';
  final GlobalKey _filterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            // ...existing code...
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bên trái: menu + hintText
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: AppIcons.menu,
                        onPressed: () => _openDrawer(context),
                      ),
                      // SỬA: Bọc Text bằng Flexible để tránh tràn
                      Flexible(
                        child: Text(
                          hintText,
                          style: context.textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bên phải: các icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconStatusGridNote(),
                    Builder(
                      builder: (context) => IconButton(
                        key: _filterKey,
                        icon: const Icon(Icons.filter_list, size: 24),
                        onPressed: () {
                          final RenderBox renderBox = _filterKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final Offset offset =
                              renderBox.localToGlobal(Offset.zero);
                          final Size size = renderBox.size;
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + size.height,
                              offset.dx + size.width,
                              offset.dy,
                            ),
                            items: [
                              PopupMenuItem(
                                value: FilterStatus.all,
                                child: const Text('Tất cả'),
                              ),
                              PopupMenuItem(
                                value: FilterStatus.notStarted,
                                child: const Text('Chưa làm'),
                              ),
                              PopupMenuItem(
                                value: FilterStatus.inProgress,
                                child: const Text('Đang làm'),
                              ),
                              PopupMenuItem(
                                value: FilterStatus.completed,
                                child: const Text('Hoàn thành'),
                              ),
                            ],
                          ).then((status) {
                            if (status != null) {
                              context.read<NoteBloc>().add(
                                  FilterNotesByStatus(status as FilterStatus));
                            }
                          });
                        },
                      ),
                    ),
                    IconProfile(),
                  ],
                ),
              ],
            ),

            onTap: () => _showSearch(context),
          ),
        ),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    context.read<NoteBloc>().appScaffoldState.currentState!.openDrawer();
  }

  Future _showSearch(BuildContext context) =>
      showSearch(context: context, delegate: NotesSearching());
}
