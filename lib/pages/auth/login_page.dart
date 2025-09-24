import 'package:attendlyproject_app/bottom_navigationbar/overview_page.dart';
import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/extension/navigation.dart';
import 'package:attendlyproject_app/model/login_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:attendlyproject_app/services/auth_services.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = "/loginpage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isPasswordVisible = false;
  bool isSubmitting = false;
  bool isVisibility = false;
  // bool _obscurePassword = true;
  bool isLoading = false;

  LoginUserModel? user;
  String? errorMessage;

  void loginUser() async {
    setState(() {
      isSubmitting = true;
      isLoading = true;
      errorMessage = null;
    });

    final email = emailC.text.trim();
    final password = passC.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email, Password cannot be empty")),
      );
      isLoading = false;
      return;
    }

    try {
      final result = await AuthService.loginUser(
        email: email,
        password: password,
      );

      setState(() {
        user = result;
      });

      // SnackBar tetap
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Welcome!")));

      // Simpan token
      PreferenceHandler.saveToken(user?.data.token.toString() ?? "");
      final savedUserId = await PreferenceHandler.getUserId();
      print("Saved User Id: $savedUserId");

      // Tampilkan Lottie dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/sukses_animation.json',
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Login Succesfully!!!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );

      // Tutup dialog otomatis setelah 4 detik, lalu push ke OverviewPage
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop(); // tutup dialog
        context.pushReplacement(OverviewPage());
      });

      print(user?.toJson());
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Incorrect Password!")));
    } finally {
      setState(() {});
      isLoading = false;
      isSubmitting = false;
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
                        const SizedBox(height: 20),
                        // LOGO
                        SizedBox(
                          height: 140,
                          child: Image.asset(
                            "assets/images/attendly_logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 30),
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
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/forgot-reset-password',
                            ),

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
                                : loginUser, // Memanggil fungsi login
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
                        const SizedBox(height: 50),
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
