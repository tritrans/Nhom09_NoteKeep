import 'package:flutter/material.dart';
import '../../../features/domain/entities/note.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/core/util/alerts/app_alerts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/presentation/blocs/auth/auth_bloc.dart';
import '../../../features/presentation/pages/auth/login_page.dart';
import '../../../features/presentation/pages/auth/register_page.dart';
import '../../../features/presentation/pages/auth/forgot_password_page.dart';
import '../../../features/presentation/pages/home/home_page.dart';
import '../../../features/presentation/pages/auth/otp_page.dart';
import '../../../features/presentation/pages/archive/archive_page.dart';
import '../../../features/presentation/pages/trash/trash_page.dart';
import '../../../features/presentation/pages/setting/setting_page.dart';
import '../../../features/presentation/pages/statistics/statistics_page.dart';
import '../../../features/presentation/pages/note/note_page.dart';
import '../../../features/presentation/pages/profile/profile_page.dart';
import '../../../features/presentation/pages/auth/welcome_page.dart';
import 'go_router_refresh_stream.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

GoRouter createGoRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final email = state.extra as String?;
          if (email == null) {
            return const LoginPage();
          }
          return OtpPage(email: email);
        },
      ),
      GoRoute(
        path: '/note/:id',
        name: 'note',
        builder: (context, state) {
          final note = state.extra! as Note;
          return NotePage(note: note);
        },
      ),
      GoRoute(
        path: '/archive',
        name: 'archive',
        builder: (context, state) => const ArchivePage(),
      ),
      GoRoute(
        path: '/trash',
        name: 'trash',
        builder: (context, state) => const TrashPage(),
      ),
      GoRoute(
        path: '/setting',
        name: 'setting',
        builder: (context, state) => const SettingPage(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      print('DEBUG ROUTER: authState = ' +
          authState.toString() +
          ', location = ' +
          state.matchedLocation);
      // Các route cho phép truy cập khi chưa đăng nhập
      final isPublicRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/';
      // Nếu chưa đăng nhập, chỉ cấm vào các route private
      if (authState is AuthInitial || authState is AuthError) {
        if (!isPublicRoute) {
          print('DEBUG ROUTER: Chưa đăng nhập, redirect về /login');
          return '/login';
        }
        print(
            'DEBUG ROUTER: Chưa đăng nhập, nhưng ở public route, không redirect');
        return null;
      }
      // Nếu đang loading, không redirect
      if (authState is AuthLoading) {
        print('DEBUG ROUTER: AuthLoading, không redirect');
        return null;
      }
      // Nếu đã đăng nhập, không cho vào các route public
      if (authState is AuthSuccess && authState.user != null) {
        if (isPublicRoute) {
          print('DEBUG ROUTER: Đã đăng nhập, redirect về /home');
          return '/home';
        }
        print('DEBUG ROUTER: Đã đăng nhập, ở private route, không redirect');
        return null;
      }
      // Nếu yêu cầu OTP, chỉ cho vào /otp
      if (authState is AuthOtpRequired) {
        if (state.matchedLocation != '/otp') {
          print('DEBUG ROUTER: Cần OTP, redirect về /otp');
          return '/otp';
        }
        print('DEBUG ROUTER: Đã ở /otp, không redirect');
        return null;
      }
      // Nếu không xác định được state và không ở public route, về /login
      if (!isPublicRoute) {
        print('DEBUG ROUTER: Không ở public route, redirect về /login');
        return '/login';
      }
      print('DEBUG ROUTER: Không redirect, trả về null');
      return null;
    },
  );
}
