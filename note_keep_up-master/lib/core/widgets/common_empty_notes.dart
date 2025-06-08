import 'package:flutter/material.dart';
import 'package:note_app/core/core.dart';

class CommonEmptyNotes extends StatelessWidget {
  const CommonEmptyNotes(this.drawerViewNote) : super(key: null);

  final DrawerSectionView drawerViewNote;

  @override
  Widget build(BuildContext context) {
    return _switchEmptySection(context, drawerViewNote);
  }

  _switchEmptySection(BuildContext context, DrawerSectionView drawerViewNote) {
    switch (drawerViewNote) {
      case DrawerSectionView.home:
        return CommonFixScrolling(
          onRefresh: () => AppFunction.onRefresh(context, drawerViewNote),
          child: _emptySection(
            AppIcons.emptyNote,
            'Note you add appear here',
          ),
        );
      case DrawerSectionView.archive:
        return _emptySection(
          AppIcons.emptyArchivesNote,
          'Your archived notes appear here',
        );
      case DrawerSectionView.trash:
        return _emptySection(
          AppIcons.emptyTrashNote,
          'No Notes in Recycle Bin',
        );
    }
  }

  _emptySection(Icon appIcons, String errorMsg) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32.0),
                child: Icon(
                  appIcons.icon,
                  size: 72,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                errorMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
