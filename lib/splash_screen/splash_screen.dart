import 'package:attendlyproject_app/bottom_navigationbar/overview_page.dart';
import 'package:attendlyproject_app/pages/auth/login_page.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkinfologin();
  }

  Future<void> _checkinfologin() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash delay
    final loginKey = await PreferenceHandler.getLogin();
    if (!mounted) return;
    if (loginKey == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OverviewPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/attendly_logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
