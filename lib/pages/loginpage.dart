import 'package:flutter/material.dart';
import 'package:attendlyproject_app/constant/app_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = "/page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = false;

  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC  = TextEditingController();

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
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
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
                        "Sign In",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                            style: TextStyle(fontSize: 12, color: AppColor.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ---- Email field
                      TextField(
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColor.form,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: AppColor.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: AppColor.textDark),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ---- Password label
                      const Row(
                        children: [
                          Text(
                            "Password",
                            style: TextStyle(fontSize: 12, color: AppColor.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ---- Password field
                      TextField(
                        controller: passC,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: AppColor.form,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: AppColor.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: AppColor.textDark),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                            icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: navigate to forgot-password
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot Password tapped (UI only)')),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: AppColor.pinkPrimary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---- Login button (primary)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: call API signin
                            debugPrint('signin: email=${emailC.text} pass=${passC.text}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.pinkPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.bg,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ---- Sign Up (secondary)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColor.pinkSoft,
                            side: const BorderSide(color: AppColor.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: AppColor.pinkPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ---- Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: AppColor.pinkPrimary, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    ],
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
