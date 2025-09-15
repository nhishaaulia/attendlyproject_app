import 'package:flutter/material.dart';

class Attendancepage extends StatefulWidget {
  const Attendancepage({super.key});
  static const id = "/Attendancepage";

  @override
  State<Attendancepage> createState() => _AttendancepageState();
}

class _AttendancepageState extends State<Attendancepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:,
      body: const Center(child: Text('Welcome to the event')),
    );
  }
}
