import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/core/widgets/linear_profiles.dart';
import '../../blocs/profile/profile_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của bạn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/setting'),
        ),
      ),
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
          // Lấy email trực tiếp từ Firebase Auth
          final user = FirebaseAuth.instance.currentUser;
          String email = user?.email ?? '';
          String profileImg = '';
          if (state is ProfileChanged) {
            profileImg = state.profileImg;
          }
          emailController.text = email;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Email
              Center(
                child: Text(
                  email.isNotEmpty ? email : 'Chưa có email',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 24),
              // Card đổi email
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đổi email',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Nhập email mới',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProfileCubit>()
                                .changeEmail(emailController.text);
                          },
                          child: const Text('Lưu email'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card đổi mật khẩu
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đổi mật khẩu',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: oldPassController,
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu cũ',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: newPassController,
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu mới',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmPassController,
                        decoration: InputDecoration(
                          hintText: 'Xác nhận mật khẩu mới',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<ProfileCubit>().changePassword(
                                  oldPassController.text,
                                  newPassController.text,
                                  confirmPassController.text,
                                );
                          },
                          child: const Text('Đổi mật khẩu'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card các nút hành động
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Đăng xuất'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            print('DEBUG PROFILE: Đã nhấn nút Đăng xuất');
                            context.read<AuthBloc>().add(LogoutRequested());
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (context.mounted) context.go('/login');
                            });
                            print(
                                'DEBUG PROFILE: Đã gửi sự kiện LogoutRequested cho AuthBloc');
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Xóa tài khoản'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            print('DEBUG PROFILE: Bắt đầu xóa tài khoản');
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận xóa tài khoản'),
                                content: const Text(
                                    'Bạn có chắc chắn muốn xóa tài khoản? Thao tác này không thể hoàn tác!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                            print('DEBUG PROFILE: Xác nhận xóa = $confirm');
                            if (confirm == true) {
                              try {
                                print(
                                    'DEBUG PROFILE: Đang xóa tài khoản trên Firebase Auth');
                                await FirebaseAuth.instance.currentUser
                                    ?.delete();
                                print(
                                    'DEBUG PROFILE: Đã xóa tài khoản trên Firebase Auth');
                                // Xóa dữ liệu local
                                final prefs = context
                                    .read<ProfileCubit>()
                                    .sharedPreferences;
                                await prefs.remove('PROFILE_EMAIL');
                                await prefs.remove('PROFILE_PASSWORD');
                                await prefs.remove('PROFILE_IMG');
                                print('DEBUG PROFILE: Đã xóa dữ liệu local');
                                // Gửi sự kiện đăng xuất cho AuthBloc
                                print(
                                    'DEBUG PROFILE: Gửi LogoutRequested cho AuthBloc');
                                context.read<AuthBloc>().add(LogoutRequested());
                                print(
                                    'DEBUG PROFILE: Đã gửi LogoutRequested cho AuthBloc');
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  if (context.mounted) context.go('/login');
                                });
                              } catch (e) {
                                print(
                                    'DEBUG PROFILE: Lỗi khi xóa tài khoản: $e');
                                // Nếu gặp lỗi requires-recent-login, thông báo cho người dùng đăng nhập lại
                                if (e
                                    .toString()
                                    .contains('requires-recent-login')) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Bạn cần đăng nhập lại để xóa tài khoản. Vui lòng đăng xuất và đăng nhập lại.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi xóa tài khoản: ' +
                                            e.toString()),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
