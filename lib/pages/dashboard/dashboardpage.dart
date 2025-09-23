import 'package:attendlyproject_app/extension/navigation.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/check_in_out.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/header.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/history.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/takeattendance.dart';
import 'package:attendlyproject_app/pages/izin%20page/izin_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const id = "/DashboardPage";

  @override
  State<DashboardPage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<DashboardPage> {
  // GlobalKey untuk akses state CheckInOutContainer
  final GlobalKey<CheckInOutContainerState> checkKey =
      GlobalKey<CheckInOutContainerState>();

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

            const SizedBox(height: 20),

            // Check-in/Check-out
            CheckInOutContainer(
              key: checkKey,
              initialAddress: '',
              initialDate: '',
              initialCheckInTime: '',
              initialCheckOutTime: '',
            ),

            const SizedBox(height: 12),

            // ReminderCheckIn(),

            // // const DigitalClockCountdown(),
            // const SizedBox(height: 20),
            // Tombol submit absen → buka halaman map
            // SubmitAbsenWidget(
            //   onMapTap: () async {
            //     // buka halaman map
            //     await Navigator.pushNamed(context, '/gmapspage');

            // // setelah balik dari map, reload data checkin/checkout
            // checkKey.currentState?.reload();
            //   },
            // ),
            TakeAttendancePage(
              onMapTap: () async {
                await Navigator.pushNamed(context, '/gmapspage');
                // context.push(const CheckInOutPage());
                checkKey.currentState?.reload();
              },

              onIzinTap: () {
                // arahkan ke halaman izin
                context.pushReplacement(const IzinPage());
              },
            ),

            // const SizedBox(height: 20),
            const SizedBox(height: 20),
            // Riwayat 7 hari
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
