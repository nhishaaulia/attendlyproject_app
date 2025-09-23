import 'package:attendlyproject_app/bottom_navigationbar/overview_page.dart';
import 'package:attendlyproject_app/pages/attendance/detail_attendance_page.dart';
import 'package:attendlyproject_app/pages/auth/forgot_password_page.dart';
import 'package:attendlyproject_app/pages/auth/register_page.dart';
import 'package:attendlyproject_app/pages/check_in_out_maps/check_in_out_page.dart';
import 'package:attendlyproject_app/pages/dashboard/dashboardpage.dart';
import 'package:attendlyproject_app/pages/izin%20page/izin_page.dart';
import 'package:attendlyproject_app/splash_screen/splash_screen.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
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
      theme: ThemeData(
        timePickerTheme: TimePickerThemeData(
          timeSelectorSeparatorColor: WidgetStatePropertyAll(AppColor.pinkMid),

          // hourMinuteShape: AppColor.pinkMid,
          // hourMinuteColor: AppColor.pinkMid,
          // dialTextColor: AppColor.pinkMid,
          entryModeIconColor: AppColor.pinkMid, // keyboard kiri
          // dayPeriodTextColor: AppColor.pinkMid, // am pm
          dialHandColor: AppColor.pinkMid, // jarum
          // dialTextColor: AppColor.pinkMid, // angka didalem
          // dayPeriodColor: AppColor.pinkMid, // dibawah am
          // hourMinuteTextColor: AppColor.pinkMid, // jam diatas yg besar
          confirmButtonStyle: ButtonStyle(
            textStyle: WidgetStatePropertyAll(TextStyle(color: AppColor.black)),
            // backgroundColor: WidgetStatePropertyAll(AppColor.pinkMid),
          ),
        ),
        // colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFE64C8C)),
        colorSchemeSeed: Color(0xFFE64C8C),
      ),

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
        '/': (context) => SplashScreen(),
        '/OverviewPage': (context) => OverviewPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        OverviewPage.id: (context) => const OverviewPage(),
        DashboardPage.id: (context) => const DashboardPage(),
        ForgotResetPasswordPage.id: (context) =>
            const ForgotResetPasswordPage(),
        CheckInOutPage.id: (context) => const CheckInOutPage(),
        DetailAttendancePage.id: (context) => const DetailAttendancePage(),
        IzinPage.id: (context) => const IzinPage(),
      },
      // home: ReminderScreen(),
    );
  }
}
