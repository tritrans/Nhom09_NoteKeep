import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/core/config/enum/drawer_views.dart';
import 'package:note_app/core/util/function/drawe_select.dart';
import 'package:note_app/core/widgets/linear_profiles.dart';
import 'package:note_app/features/presentation/blocs/auth/auth_bloc.dart';
import 'package:note_app/features/presentation/blocs/profile/profile_cubit.dart';

import 'widgets/widgets.dart';
import 'package:note_app/core/config/drawer/app_drawer.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    DrawerSelect.selectedDrawerView = DrawerViews.setting;
    final emailController = TextEditingController();
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      drawer: const AppDrawer(),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent),
            );
          } else if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          String email = '';
          if (state is ProfileChanged) {
            email = state.email;
          }
          emailController.text = email;
          return ListView(
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Hồ sơ của bạn'),
                onTap: () {
                  context.go('/profile');
                },
              ),
              const SizedBox(height: 24),
              // Existing settings sections
              const Sections(
                sections: [
                  TilesSection(
                      title: 'Dispaly option', tiles: [ThemesItemTile()]),
                  TilesSection(title: '', tiles: [
                    ThemMucMoiSwitchTile(),
                    AuthSwitchTile(),
                    AttendanceSwitchTile(),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
