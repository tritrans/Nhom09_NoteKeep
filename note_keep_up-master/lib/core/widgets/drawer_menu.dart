import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router_name.dart';
import '../config/enum/drawer_section_view.dart';
import '../../features/presentation/blocs/blocs.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Keep Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () {
              context.read<NoteBloc>().add(
                    LoadNotes(drawerSectionView: DrawerSectionView.home),
                  );
              context.go('/home'); // Thêm dòng này
              context.pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Lưu trữ'),
            onTap: () {
              context.read<NoteBloc>().add(
                    LoadNotes(drawerSectionView: DrawerSectionView.archive),
                  );
              context.go('/trash');
              context.pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Thùng rác'),
            onTap: () {
              context.read<NoteBloc>().add(
                    LoadNotes(drawerSectionView: DrawerSectionView.trash),
                  );
              context.go(AppRouterName.trash.path);
              context.pop();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Thống kê & Báo cáo'),
            onTap: () {
              context.go(AppRouterName.statistics.path);
            },
          ),
        ],
      ),
    );
  }
}
