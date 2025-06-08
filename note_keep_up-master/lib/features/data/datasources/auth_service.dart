import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart' show Message, Address, send;
import 'package:mailer/smtp_server.dart' show gmail;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String email = 'tritranminh484@gmail.com';
  static const String emailPassword = 'gffo lcws dkge qbjk';
  final Map<String, String> _otpStore = {};

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Add static email template methods
  static String otpTemplate(String otp, String userName) {
    return '''
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px 24px; background: #fff; border-radius: 12px; box-shadow: 0 4px 24px rgba(33,150,243,0.08), 0 1.5px 6px rgba(0,0,0,0.04); border: 1px solid #e3e8ee;">
        <div style="text-align: center; margin-bottom: 24px;">
          <img src='https://img.icons8.com/color/96/000000/verified-account.png' alt='OTP' style='width:64px;height:64px;'>
        </div>
        <h2 style="color: #1976D2; text-align: center; margin-bottom: 8px; letter-spacing: 1px;">Xác thực tài khoản</h2>
        <p style="text-align: center; color: #333; font-size: 16px;">Xin chào <strong>$userName</strong>,</p>
        <p style="text-align: center; color: #555; font-size: 15px; margin-bottom: 24px;">Cảm ơn bạn đã đăng ký tài khoản. Mã OTP của bạn là:</p>
        <div style="background: linear-gradient(90deg, #1976D2 0%, #64B5F6 100%); color: #fff; padding: 18px 0; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 8px; border-radius: 8px; margin: 0 auto 20px auto; width: 80%; box-shadow: 0 2px 8px rgba(33,150,243,0.10);">
          $otp
        </div>
        <p style="text-align: center; color: #888; font-size: 14px; margin-bottom: 8px;">Mã này sẽ hết hạn sau <strong>5 phút</strong>.</p>
        <p style="text-align: center; color: #888; font-size: 14px;">Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>
        <div style="border-top: 1px solid #e3e8ee; margin: 32px 0 16px 0;"></div>
        <p style="color: #b0b0b0; font-size: 12px; text-align: center;">
          Đây là email tự động, vui lòng không trả lời email này.<br>
          <span style="font-size:11px;">&copy; Note Keep Up Team</span>
        </p>
      </div>
      <div style="text-align:center; color:#bbb; font-size:11px; margin-top:12px;">Powered by Note Keep Up</div>
    ''';
  }

  static String passwordResetTemplate(String resetLink, String userName) {
    return '''
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px 24px; background: #fff; border-radius: 12px; box-shadow: 0 4px 24px rgba(33,150,243,0.08), 0 1.5px 6px rgba(0,0,0,0.04); border: 1px solid #e3e8ee;">
        <div style="text-align: center; margin-bottom: 24px;">
          <img src='https://img.icons8.com/color/96/000000/password-reset.png' alt='Reset Password' style='width:64px;height:64px;'>
        </div>
        <h2 style="color: #1976D2; text-align: center; margin-bottom: 8px; letter-spacing: 1px;">Đặt lại mật khẩu</h2>
        <p style="text-align: center; color: #333; font-size: 16px;">Xin chào <strong>$userName</strong>,</p>
        <p style="text-align: center; color: #555; font-size: 15px; margin-bottom: 24px;">Bạn đã yêu cầu đặt lại mật khẩu. Vui lòng nhấn vào nút bên dưới để đặt lại mật khẩu của bạn:</p>
        <div style="text-align: center; margin: 28px 0;">
          <a href="$resetLink" style="background: linear-gradient(90deg, #1976D2 0%, #64B5F6 100%); color: #fff; padding: 14px 36px; text-decoration: none; border-radius: 6px; font-size: 18px; font-weight: 600; box-shadow: 0 2px 8px rgba(33,150,243,0.10); display: inline-block; letter-spacing: 1px;">Đặt lại mật khẩu</a>
        </div>
        <p style="text-align: center; color: #888; font-size: 14px; margin-bottom: 8px;">Liên kết này sẽ hết hạn sau <strong>1 giờ</strong>.</p>
        <p style="text-align: center; color: #888; font-size: 14px;">Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
        <div style="border-top: 1px solid #e3e8ee; margin: 32px 0 16px 0;"></div>
        <p style="color: #b0b0b0; font-size: 12px; text-align: center;">
          Đây là email tự động, vui lòng không trả lời email này.<br>
          <span style="font-size:11px;">&copy; Note Keep Up Team</span>
        </p>
      </div>
      <div style="text-align:center; color:#bbb; font-size:11px; margin-top:12px;">Powered by Note Keep Up</div>
    ''';
  }

  // Send OTP to email
  Future<void> sendOtpToEmail(String recipientEmail, String uid,
      {String? userName}) async {
    try {
      // Create SMTP server configuration
      final smtpServer = gmail(email, emailPassword);

      // Generate OTP
      final otp = _generateOTP();
      _otpStore[recipientEmail] = otp;

      // Use provided userName or fallback to email prefix
      final name = userName ?? recipientEmail.split('@').first;

      // Create email message
      final message = Message()
        ..from = Address(email, 'Note Keep Up')
        ..recipients.add(recipientEmail)
        ..subject = 'Xác thực email của bạn'
        ..html = otpTemplate(otp, name);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String email, String otp) async {
    final storedOTP = _otpStore[email];
    if (storedOTP == null) {
      return false;
    }

    if (storedOTP == otp) {
      _otpStore.remove(email);
      return true;
    }
    return false;
  }

  // Reset password
  Future<void> resetPassword(String recipientEmail, {String? userName}) async {
    try {
      // Create SMTP server configuration
      final smtpServer = gmail(email, emailPassword);

      // Generate reset token (simulate a link for this template)
      final resetToken = _generateResetToken();
      final resetLink =
          'https://your-app.com/reset-password?token=$resetToken&email=$recipientEmail';

      // Use provided userName or fallback to email prefix
      final name = userName ?? recipientEmail.split('@').first;

      // Create email message
      final message = Message()
        ..from = Address(email, 'Note Keep Up')
        ..recipients.add(recipientEmail)
        ..subject = 'Đặt lại mật khẩu'
        ..html = passwordResetTemplate(resetLink, name);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }

  // Generate OTP
  String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 6);
  }

  // Generate reset token
  String _generateResetToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 8);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
