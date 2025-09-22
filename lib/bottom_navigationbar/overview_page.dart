import 'package:attendlyproject_app/bottom_navigationbar/flashytab_bar.dart';
import 'package:attendlyproject_app/pages/Profile/profile_page.dart';
import 'package:attendlyproject_app/pages/attendance/detail_attendance_page.dart';
import 'package:attendlyproject_app/pages/dashboard/dashboardpage.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});
  static const String id = 'OverviewPage';
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _selectedIndex = 0;

  final List<Widget> _listWidget = const [
    DashboardPage(),
    DetailAttendancePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _listWidget.elementAt(_selectedIndex)),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(icon: Icon(Icons.home), title: Text('Dashboard')),
          FlashyTabBarItem(icon: Icon(Icons.history), title: Text('History')),
          FlashyTabBarItem(icon: Icon(Icons.person), title: Text('Profile')),
        ],
      ),
    );
  }
}
