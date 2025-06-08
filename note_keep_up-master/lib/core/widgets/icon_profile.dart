import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/presentation/blocs/blocs.dart';
import '../core.dart';

class IconProfile extends StatelessWidget {
  const IconProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileChanged) {
          final String currentProfileImg = state.profileImg;
          return IconButton(
            padding: const EdgeInsets.all(2),
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(currentProfileImg),
            ),
            onPressed: () => _onShowDialog(context),
          );
        } else if (state is ProfileError) {
          return IconButton(
            padding: const EdgeInsets.all(2),
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.error, color: Colors.white, size: 18),
            ),
            onPressed: null,
          );
        } else {
          // Loading hoặc trạng thái khác
          return IconButton(
            padding: const EdgeInsets.all(2),
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onPressed: null,
          );
        }
      },
    );
  }

  _onShowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        AlertDialog alertProfiles = const AlertDialog(
          contentPadding: EdgeInsets.all(5),
          scrollable: true,
          content: LinearProfiles(),
        );

        return alertProfiles;
      },
    );
  }
}
