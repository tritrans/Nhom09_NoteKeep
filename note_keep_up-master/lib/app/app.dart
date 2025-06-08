import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/core.dart';
import 'package:note_app/features/presentation/blocs/auth/auth_bloc.dart';
import 'package:note_app/features/presentation/blocs/blocs.dart';
import 'package:go_router/go_router.dart';
import '../core/config/routes/app_router.dart' show createGoRouter;

import 'provider/app_provider.dart';

class NoteApp extends StatefulWidget {
  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  GoRouter? _goRouter;
  AuthBloc? _lastAuthBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authBloc = BlocProvider.of<AuthBloc>(context);
    // Chỉ tạo lại GoRouter nếu AuthBloc instance đổi
    if (_goRouter == null || _lastAuthBloc != authBloc) {
      _goRouter = createGoRouter(authBloc);
      _lastAuthBloc = authBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('NoteApp built');
    AppDevice.setStatusBart(context);
    return AppProviders(
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(),
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            print('ThemeCubit state: $state');
            if (state is LoadedTheme) {
              print('Building MaterialApp.router');
              return BlocListener<AuthBloc, AuthState>(
                listenWhen: (previous, current) =>
                    current is AuthInitial || current is AuthError,
                listener: (context, state) {
                  GoRouter.of(context).go('/login');
                },
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Note App Version 2',
                  theme: AppTheme.lightWithFont(state.fontFamily),
                  darkTheme: AppTheme.darkWithFont(state.fontFamily),
                  themeMode: state.themeMode,
                  routerConfig: _goRouter!,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
