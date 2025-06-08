import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/core.dart';
import 'package:note_app/app/di/get_it.dart' as di;
import '../../features/presentation/blocs/blocs.dart';
import '../../features/presentation/blocs/auth/auth_bloc.dart';
import '../../features/data/datasources/auth_service.dart';
import '../../features/domain/entities/note.dart';

/// Widget cung cấp các Bloc và Cubit cho toàn bộ cây widget của ứng dụng.
///
/// Sử dụng [MultiBlocProvider] để cung cấp nhiều Bloc/Cubit tại một điểm.
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('AppProviders built');
    return MultiBlocProvider(
      providers: [
        /// Cung cấp [AuthBloc] để quản lý trạng thái xác thực người dùng.
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
          lazy: false,
        ),

        /// Cung cấp [NoteBloc] để quản lý các ghi chú và dữ liệu liên quan.
        BlocProvider(
          create: (_) => di.gI<NoteBloc>()
            ..add(const LoadNotes(drawerSectionView: DrawerSectionView.home)),
        ),

        /// Cung cấp [StatusGridCubit] để quản lý trạng thái hiển thị lưới.
        BlocProvider(create: (_) => di.gI<StatusGridCubit>()),

        /// Cung cấp [StatusIconsCubit] để quản lý trạng thái các biểu tượng.
        ///
        /// Khởi tạo với một ghi chú trống để đảm bảo trạng thái ban đầu hợp lệ.
        BlocProvider(
          create: (_) => di.gI<StatusIconsCubit>()
            ..toggleIconsStatus(
                Note.empty(userId: AuthService().currentUser?.uid ?? '')),
        ),

        /// Cung cấp [ProfileCubit] để quản lý thông tin hồ sơ người dùng.
        BlocProvider(create: (_) => di.gI<ProfileCubit>()),

        /// Cung cấp [SearchCubit] để quản lý chức năng tìm kiếm.
        BlocProvider(create: (_) => di.gI<SearchCubit>()),

        /// Cung cấp [ThemeCubit] để quản lý chủ đề (theme) của ứng dụng.
        BlocProvider(create: (_) => di.gI<ThemeCubit>()..getCurrentThemeMode()),
      ],
      child: child,
    );
  }
}
