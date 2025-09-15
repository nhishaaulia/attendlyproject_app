import 'package:attendlyproject_app/bottom_navigationbar/overviewpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Library Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),

      // initialRoute: StartPage.id,
      // routes: {
      //   StartPage.id: (context) => const StartPage(),
      //   OverviewPage.id: (context) => const OverviewPage(),
      // },
      home: const OverviewPage(),
    );
  }
}
