import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../blocs/blocs.dart';
import './widgets.dart';

class AppBarNote extends StatelessWidget implements PreferredSizeWidget {
  const AppBarNote({
    Key? key,
    required this.press,
  }) : super(key: key);

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusIconsCubit, StatusIconsState>(
      buildWhen: (previous, current) => current is ReadOnlyState,
      builder: (context, state) {
        final currentStatus = state is ReadOnlyState;

        return AppBar(
          leading: IconButton(
            icon: AppIcons.arrowBack,
            onPressed: press,
          ),
          actions: [
            if (!currentStatus) const IconPinnedStatus(),
            if (!currentStatus) const IconArchiveStatus(),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
