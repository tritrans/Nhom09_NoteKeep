import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/features/data/datasources/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final AuthService _authService;

  AuthBloc({FirebaseAuth? firebaseAuth, required AuthService authService})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _authService = authService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<SignOut>(_onSignOut);
  }

  // Lưu OTP tạm thời (demo, thực tế nên lưu vào server hoặc Firestore)
  final Map<String, String> _otpStorage = {};

  // Hàm gửi OTP thực tế qua email
  Future<void> sendOtpToEmail(String email) async {
    await _authService.sendOtpToEmail(email, ""); // Truyền uid nếu cần
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(const AuthError('No user found'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        // Kiểm tra trạng thái xác thực
        final prefs = await SharedPreferences.getInstance();
        final authEnabled = prefs.getBool('auth_enabled') ?? true;
        if (authEnabled) {
          emit(AuthOtpRequired(event.email));
          await sendOtpToEmail(event.email); // Gửi OTP về email
        } else {
          emit(AuthSuccess(userCredential.user));
        }
      } else {
        emit(const AuthError('Đăng nhập thất bại!'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Tài khoản không tồn tại!';
          break;
        case 'wrong-password':
          errorMsg = 'Mật khẩu không đúng!';
          break;
        case 'invalid-email':
          errorMsg = 'Email không hợp lệ!';
          break;
        case 'user-disabled':
          errorMsg = 'Tài khoản đã bị vô hiệu hóa!';
          break;
        default:
          errorMsg = 'Đã xảy ra lỗi: ${e.message ?? 'chưa có tài khoản'}';
      }
      emit(AuthError(errorMsg));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG: Bắt đầu đăng ký với email: ${event.email}');
    emit(AuthLoading());
    try {
      print('DEBUG: Đang tạo tài khoản với Firebase...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        print('DEBUG: Đăng ký thành công, user: ${userCredential.user?.email}');
        print('DEBUG: Đang đăng xuất...');
        await _firebaseAuth.signOut();
        print('DEBUG: Đã đăng xuất, phát AuthInitial');
        emit(AuthInitial());
      } else {
        print('DEBUG: Đăng ký thất bại - không có user');
        emit(const AuthError('Registration failed'));
      }
    } on FirebaseAuthException catch (e) {
      print('DEBUG: Lỗi Firebase Auth: ${e.message}');
      emit(AuthError(e.message ?? 'An error occurred'));
    } catch (e) {
      print('DEBUG: Lỗi không xác định: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    print('DEBUG AUTHBLOC: emit AuthLoading');
    try {
      await _firebaseAuth.signOut();
      emit(AuthInitial());
      print('DEBUG AUTHBLOC: emit AuthInitial');
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An error occurred'));
      print('DEBUG AUTHBLOC: emit AuthError (Logout Exception)');
    } catch (e) {
      emit(AuthError(e.toString()));
      print('DEBUG AUTHBLOC: emit AuthError (Logout Exception)');
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An error occurred'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isValid = await _authService.verifyOTP(event.email, event.otp);
    if (!isValid) {
      emit(const AuthError('Mã OTP không đúng hoặc bạn chưa yêu cầu mã OTP.'));
      return;
    }
    // Sau khi xác thực OTP thành công, phát AuthSuccess
    final user = _firebaseAuth.currentUser;
    emit(AuthSuccess(user));
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Lấy user theo email (Firebase không cho đổi mật khẩu qua email trực tiếp nếu chưa đăng nhập)
      // Thực tế cần gửi link reset password hoặc dùng custom backend
      // Ở đây sẽ gửi link reset password về email
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(const AuthSuccess(null));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đổi mật khẩu thất bại.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
