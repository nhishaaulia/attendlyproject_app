import 'package:attendlyproject_app/pages/dashboard/widget/check_in_out.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/header.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/history.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/submit_absen.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const id = "/DashboardPage";

  @override
  State<DashboardPage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            HeaderDashboard(),

            SizedBox(height: 20),

            // Check-in/Check-out
            CheckInOutContainer(
              initialAddress: '',
              initialDate: '',
              initialCheckInTime: '',
              initialCheckOutTime: '',
            ),

            const SizedBox(height: 20),

            SubmitAbsenWidget(
              onMapTap: () => Navigator.pushNamed(context, '/gmapspage'),
            ),

            // SECTION sejarah 7 hari (langsung fetch API)
            AttendanceHistory7Days(
              onDetailsTap: () =>
                  Navigator.pushNamed(context, '/history'), // optional
            ),
          ],
        ),
      ),
    );
  }
}
