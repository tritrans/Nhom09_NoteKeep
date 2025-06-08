// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/config/enum/filter_status.dart';
import 'package:note_app/features/presentation/blocs/note/note_bloc.dart';

import '../../../../../../core/core.dart';

class SliverNotes extends StatelessWidget {
  final Widget child;

  const SliverNotes({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: [
            _appBar(context),
            RefreshIndicator(
              displacement: 80,
              onRefresh: () =>
                  AppFunction.onRefresh(context, DrawerSectionView.home),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: child,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      toolbarHeight: 50,
      automaticallyImplyLeading: false,
      forceMaterialTransparency: true,
      title: CommonSearchBar(),
      systemOverlayStyle: AppDevice.setStatusBartSilverAppBar(),
    );
  }
}
