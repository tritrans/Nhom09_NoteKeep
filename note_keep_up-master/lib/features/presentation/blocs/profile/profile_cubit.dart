import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/core.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SharedPreferences sharedPreferences;

  ProfileCubit({required this.sharedPreferences})
      : super(ProfileChanged(
          sharedPreferences.getString('PROFILE_IMG') ?? AppIcons.profiles[0],
          sharedPreferences.getString('PROFILE_EMAIL') ?? '',
        ));
  String get currentEmail =>
      state is ProfileChanged ? (state as ProfileChanged).email : '';
  String get currentProfileImg => state is ProfileChanged
      ? (state as ProfileChanged).profileImg
      : AppIcons.profiles[0];

  void changeProfile(int indexProfile) {
    final profileImg = AppIcons.profiles[indexProfile];
    sharedPreferences.setString('PROFILE_IMG', profileImg);
    emit(ProfileChanged(profileImg, currentEmail));
  }

  void changeEmail(String newEmail) {
    sharedPreferences.setString('PROFILE_EMAIL', newEmail);
    emit(ProfileChanged(currentProfileImg, newEmail));
  }

  void changePassword(String oldPass, String newPass, String confirmPass) {
    final currentPass = sharedPreferences.getString('PROFILE_PASSWORD') ?? '';
    if (oldPass != currentPass) {
      emit(ProfileError('Mật khẩu cũ không đúng.'));
      return;
    }
    if (newPass != confirmPass) {
      emit(ProfileError('Mật khẩu mới không khớp.'));
      return;
    }
    if (newPass.length < 6) {
      emit(ProfileError('Mật khẩu mới phải từ 6 ký tự.'));
      return;
    }
    sharedPreferences.setString('PROFILE_PASSWORD', newPass);
    emit(ProfileSuccess('Đổi mật khẩu thành công!'));
  }
}
