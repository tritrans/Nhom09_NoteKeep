import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/presentation/blocs/blocs.dart';
import '../../core.dart';

abstract class AppFunction {
  static Future onRefresh(
      BuildContext context, DrawerSectionView section) async {
    BlocProvider.of<NoteBloc>(context).add(
      LoadNotes(drawerSectionView: section),
    );
  }
}
