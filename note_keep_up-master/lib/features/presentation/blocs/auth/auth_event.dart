part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class SignOut extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class OtpSubmitted extends AuthEvent {
  final String email;
  final String otp;

  const OtpSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String newPassword;

  const ResetPasswordSubmitted(
      {required this.email, required this.newPassword});

  @override
  List<Object?> get props => [email, newPassword];
}
