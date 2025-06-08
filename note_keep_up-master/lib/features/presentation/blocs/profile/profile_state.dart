part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileChanged extends ProfileState {
  final String profileImg;
  final String email;

  const ProfileChanged(this.profileImg, this.email);

  @override
  List<Object> get props => [profileImg, email];
}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

final class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);
  @override
  List<Object> get props => [message];
}
