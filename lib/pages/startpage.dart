import 'package:attendlyproject_app/pages/loginpage.dart';
import 'package:attendlyproject_app/pages/registerpage.dart';
import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'register_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});
  static const id = "/startpage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_pinky.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Logo & Title
              Column(
                children: [
                  Image.asset(
                    "assets/images/pinkylibrary_logo.png",
                    height: 400,
                  ),
                  // const SizedBox(height: 12),
                ],
              ),

              // White Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/pinkypink.png", height: 100),

                    const Text(
                      "One Library, Endless Worlds",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 111, 67, 117),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            168,
                            197,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Register
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color.fromARGB(255, 111, 67, 117),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "+ Register",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 111, 67, 117),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        text: "Read ",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Terms & Conditions ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 111, 67, 117),
                            ),
                          ),
                          const TextSpan(text: "or "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: Color.fromARGB(255, 111, 67, 117),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
