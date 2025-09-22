import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/forgot_password_model.dart';
import 'package:attendlyproject_app/services/forgot_password_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static const id = "/forgotpassword";

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  bool isSubmitting = false;

  // Memanggil API `requestOtp`
  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return; // validasi form

    setState(() => isSubmitting = true); // tampilkan loading
    try {
      // // Panggil service requestOtp dengan email input user
      ForgotPasswordModel result = await ForgotPasswordService.requestOtp(
        RequestOtp(email: emailC.text.trim()),
      );

      if (!mounted) return;
      // Tampilkan pesan sukses dari server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'OTP has been sent to your email.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: arahkan ke halaman verify OTP
      // Navigator.pushNamed(context, '/verify-otp', arguments: emailC.text.trim());
    } catch (e) {
      // Tangkap error & tampilkan ke user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send code. Please try again: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hentikan loading state
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bg,
        elevation: 0,
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),

      //body
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: AppColor.bg),
          ),

          // konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey, // hubungkan ke formKey
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // // Logo
                        //   Center(
                        //     child: Image.asset(
                        //       'assets/images/',
                        //       height: 120,
                        //       width: 120,
                        //     ),
                        //   ),
                        SizedBox(height: 24),
                        // Judul utama (Send Code)
                        const Text(
                          "Send Code",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subjudul (instruksi)
                        const Text(
                          "Please enter your email account to send the verification code to reset your password",

                          style: TextStyle(color: Colors.black54, height: 1.4),
                        ),
                        const SizedBox(height: 28),

                        // Label email
                        const Row(
                          children: [
                            Text(
                              "Email Address",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Email field
                        TextFormField(
                          controller: emailC,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: AppColor.form,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColor.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColor.textDark,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Email cannot be empty'
                              : !value.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                        ),

                        const SizedBox(height: 28),

                        // Send Code button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            // Action tombol → panggil fungsi _sendCode() jika tidak sedang loading
                            onPressed: isSubmitting
                                ? null // kalau sedang loading, tombol disabled
                                : _sendCode, // fungsi API request OTP
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.pinkMid,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            // cek state loading atau tidak
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    // loading spinner kecil putih
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

                        const SizedBox(height: 30),
                        CopyRightText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
