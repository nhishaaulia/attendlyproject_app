import 'package:attendlyproject_app/constant/app_color.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/header.dart';
import 'package:attendlyproject_app/pages/dashboard/widget/total_attendance';
import 'package:attendlyproject_app/pages/dashboard/widget/working_time.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: const [
              HeaderWidget(),
              WorkingTimeWidget(),
              TotalAttendanceWidget(),
              // WorkingHoursWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
