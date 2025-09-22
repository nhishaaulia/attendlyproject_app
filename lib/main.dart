import 'package:attendlyproject_app/bottom_navigationbar/overview_page.dart';
import 'package:attendlyproject_app/pages/attendance/detail_attendance_page.dart';
import 'package:attendlyproject_app/pages/auth/forgot_password_page.dart';
import 'package:attendlyproject_app/pages/auth/login_page.dart';
import 'package:attendlyproject_app/pages/auth/register_page.dart';
import 'package:attendlyproject_app/pages/check_in_out_maps/check_in_out_page.dart';
import 'package:attendlyproject_app/pages/dashboard/dashboardpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),

      // initialRoute: OverviewPage.id,
      // routes: {
      //   LoginPage.id: (context) => const LoginPage(),
      //   // RegisterPage.id: (context) => const RegisterPage(),
      //   OverviewPage.id: (context) => const OverviewPage(),
      //   // DashboardPage.id: (context) => const DashboardPage(),
      //   // ForgotPasswordPage.id: (context) => const ForgotPasswordPage(),
      // },
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/OverviewPage': (context) => OverviewPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        OverviewPage.id: (context) => const OverviewPage(),
        DashboardPage.id: (context) => const DashboardPage(),
        ForgotPasswordPage.id: (context) => const ForgotPasswordPage(),
        CheckInOutPage.id: (context) => const CheckInOutPage(),
        DetailAttendancePage.id: (context) => const DetailAttendancePage(),
      },
    );
    // home: const OverviewPage(),
  }
}
