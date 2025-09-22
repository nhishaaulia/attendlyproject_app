import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/login_model.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/auth_services.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = "/page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isPasswordVisible = false;
  bool isSubmitting = false;

  // Fungsi untuk menangani login pengguna
  Future<void> _manageUserLogin() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) return;

    // Tampilkan indikator loading
    setState(() => isSubmitting = true);

    try {
      // Hapus login lama jika ada
      await PreferenceHandler.removeLogin();

      LoginUserModel result;

      try {
        // Coba login tanpa token
        result = await AuthService.loginNoToken(emailC.text.trim(), passC.text);
      } catch (e) {
        // Kalau gagal, login pakai token kosong sebagai fallback
        result = await AuthService.loginWithToken(
          emailC.text.trim(),
          passC.text,
          '',
        );
      }

      // Simpan session / flag login
      await PreferenceHandler.saveLogin();

      // Cek kalau widget masih aktif sebelum akses context / setState
      if (!mounted) return;

      // Tampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful, welcome back!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigasi ke halaman Dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/OverviewPage',
        (route) => false, // hapus semua route sebelumnya
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('We could not log you in. Please try again: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Sembunyikan indikator loading
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    // Membersihkan controller ketika halaman di-close
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColor.bg),
          ),

          // Layer (konten)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey, // Pastikan form menggunakan key
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO
                        SizedBox(
                          height: 70,
                          child: Image.asset(
                            "assets/images/attendly_logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 50),
                        const Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Access your account and continue your journey",
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ---- Email label
                        const Row(
                          children: [
                            Text(
                              "Email Address",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ---- Email field
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
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColor.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColor.textDark,
                              ),
                            ),
                          ),
                          validator: (value) {
                            // Validasi email
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            } else if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null; // Jika valid
                          },
                        ),

                        const SizedBox(height: 16),

                        // ---- Password label
                        const Row(
                          children: [
                            Text(
                              "Password",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ---- Password field
                        TextFormField(
                          controller: passC,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: AppColor.form,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColor.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColor.textDark,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => isPasswordVisible = !isPasswordVisible,
                              ),
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            // Validasi password
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null; // Jika valid
                          },
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/forgotpassword'),

                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColor.pinkMid,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.pinkMid,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---- Login button (primary)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : _manageUserLogin, // Memanggil fungsi login
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.pinkMid,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.bg,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ---- Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/registerpage'),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  color: AppColor.pinkMid,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.pinkMid,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Copyright
                        const SizedBox(height: 120),
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
