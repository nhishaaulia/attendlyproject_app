import 'package:flutter/material.dart';
import 'package:attendlyproject_app/constant/app_color.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = "/registerpage";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final TextEditingController nameC     = TextEditingController();
  final TextEditingController emailC    = TextEditingController();
  final TextEditingController trainingC = TextEditingController();
  final TextEditingController batchC    = TextEditingController();
  final TextEditingController passC     = TextEditingController();
  final TextEditingController confirmC  = TextEditingController();

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
              // child: Center(
                child: SingleChildScrollView(
                  child: Column(
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
                        "Sign Up",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Join us today and start your journey",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // ---- Full Name
                      const Row(
                        children: [
                          Text("Full Name",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameC,
                        decoration: InputDecoration(
                          hintText: "Enter your full name",
                          prefixIcon: const Icon(Icons.person_outline),
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
                      const SizedBox(height: 14),

                      // ---- Email
                      const Row(
                        children: [
                          Text("Email Address",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 14),

                      // ---- Training
                      const Row(
                        children: [
                          Text("Training",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: trainingC,
                        decoration: InputDecoration(
                          hintText: "Enter your training",
                          prefixIcon: const Icon(Icons.school_outlined),
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
                      const SizedBox(height: 14),

                      // ---- Batch
                      const Row(
                        children: [
                          Text("Batch",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: batchC,
                        decoration: InputDecoration(
                          hintText: "Enter your batch",
                          prefixIcon: const Icon(Icons.confirmation_number_outlined),
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
                      const SizedBox(height: 14),

                      // ---- Password
                      const Row(
                        children: [
                          Text("Password",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passC,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Create a password",
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
                      const SizedBox(height: 14),

                      // ---- Confirm Password
                      const Row(
                        children: [
                          Text("Confirm Password",
                              style: TextStyle(fontSize: 12, color: AppColor.textDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmC,
                        obscureText: !isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Re-enter password",
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
                            onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                            icon: Icon(isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---- Register button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: call API register
                            debugPrint(
                                'Register: name=${nameC.text}, email=${emailC.text}, training=${trainingC.text}, batch=${batchC.text}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.pinkPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ---- Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Sign In',
                                style: TextStyle(color: AppColor.pinkPrimary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // ),
        ],
      ),
    );
  }
}
