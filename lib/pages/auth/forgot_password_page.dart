import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/forgot_password_model.dart'; // RequstOtpModel
import 'package:attendlyproject_app/services/forgot_password_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class ForgotResetPasswordPage extends StatefulWidget {
  const ForgotResetPasswordPage({super.key});
  static const id = "/forgot-reset-password";

  @override
  State<ForgotResetPasswordPage> createState() =>
      _ForgotResetPasswordPageState();
}

class _ForgotResetPasswordPageState extends State<ForgotResetPasswordPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _otpC = TextEditingController();
  final TextEditingController _newPassC = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  bool _obscurePass = true; // <- untuk toggle icon
  String? _message;

  @override
  void dispose() {
    _emailC.dispose();
    _otpC.dispose();
    _newPassC.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      RequstOtpModel res = await ForgotPasswordService.requestOtp(
        _emailC.text.trim(),
      );
      setState(() {
        _otpSent = true;
        _message = res.message ?? "OTP berhasil dikirim ke email";
      });
    } catch (e) {
      setState(() {
        _message = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKeyStep2.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      RequstOtpModel res = await ForgotPasswordService.resetPassword(
        email: _emailC.text.trim(),
        otp: _otpC.text.trim(),
        newPassword: _newPassC.text.trim(),
      );
      setState(() {
        _message = res.message ?? "Password berhasil direset";
      });
    } catch (e) {
      setState(() {
        _message = "Gagal reset password: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle(1, active: true),
        _stepLine(),
        _stepCircle(2, active: _otpSent),
      ],
    );
  }

  Widget _stepCircle(int step, {bool active = false}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: active ? AppColor.pinkMid : Colors.grey.shade300,
      child: Text(
        "$step",
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _stepLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColor.form,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColor.textDark),
      ),
    );
  }

  Widget _buildRequestOtpForm() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Send Code",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColor.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please enter your email account to send the verification code to reset your password",
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 28),
          const Text(
            "Email Address",
            style: TextStyle(fontSize: 14, color: AppColor.textDark),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailC,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              "Enter your email",
              Icons.email_outlined,
            ),
            validator: (v) => v == null || v.isEmpty
                ? "Email cannot be empty"
                : !v.contains("@")
                ? "Please enter a valid email"
                : null,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _requestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.pinkMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Send Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.bg,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===> FORM STEP 2 (password dengan validator & toggle)
  Widget _buildResetPasswordForm() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reset Password",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColor.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your OTP and new password.",
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 28),
          const Text(
            "OTP",
            style: TextStyle(fontSize: 14, color: AppColor.textDark),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpC,
            decoration: _inputDecoration("Enter OTP", Icons.verified_user),
            validator: (v) =>
                v == null || v.isEmpty ? " OTP cannot be empty" : null,
          ),
          const SizedBox(height: 20),
          const Text(
            "New password",
            style: TextStyle(fontSize: 14, color: AppColor.textDark),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPassC,
            obscureText: _obscurePass,
            decoration: _inputDecoration(
              "Enter new password",
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.textDark,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Password cannot be empty";
              if (v.length < 6) return "Password must be at least 6 characters";
              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                return "Must Contain an uppercase letter";
              }
              if (!RegExp(r'[a-z]').hasMatch(v)) {
                return "Must Contain an lowercase letter";
              }
              if (!RegExp(r'[0-9]').hasMatch(v)) {
                return "Must contain a number";
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.pinkMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.bg,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        backgroundColor: AppColor.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forgot / Reset Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 30),
              !_otpSent ? _buildRequestOtpForm() : _buildResetPasswordForm(),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color:
                        _message!.toLowerCase().contains("failed") ||
                            _message!.toLowerCase().contains("error")
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
              const CopyRightText(),
            ],
          ),
        ),
      ),
    );
  }
}
