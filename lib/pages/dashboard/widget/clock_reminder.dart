// import 'dart:async';

// import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
// import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
// import 'package:attendlyproject_app/utils/app_color.dart';
// import 'package:flutter/material.dart';

// class DigitalClockCountdown extends StatefulWidget {
//   const DigitalClockCountdown({super.key});

//   @override
//   State<DigitalClockCountdown> createState() => _DigitalClockCountdownState();
// }

// class _DigitalClockCountdownState extends State<DigitalClockCountdown> {
//   Timer? _timer;
//   DateTime _now = DateTime.now();
//   String _reminderText = 'Memuat jadwal...';

//   @override
//   void initState() {
//     super.initState();
//     _loadTodaySchedule();
//     // update jam setiap detik
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       setState(() => _now = DateTime.now());
//     });
//   }

//   Future<void> _loadTodaySchedule() async {
//     try {
//       final token = await PreferenceHandler.getToken();
//       if (token == null) {
//         setState(() => _reminderText = "Token tidak ditemukan");
//         return;
//       }

//       final data = await AttendanceApiService.today(token);
//       if (data == null) {
//         setState(() => _reminderText = "Jadwal tidak tersedia");
//         return;
//       }

//       final now = DateTime.now();
//       DateTime? checkIn;
//       DateTime? checkOut;

//       if (data.checkInTime.isNotEmpty) {
//         final p = data.checkInTime.split(':');
//         checkIn = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           int.parse(p[0]),
//           int.parse(p[1]),
//         );
//       }
//       if (data.checkOutTime != null && data.checkOutTime!.isNotEmpty) {
//         final p = data.checkOutTime!.split(':');
//         checkOut = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           int.parse(p[0]),
//           int.parse(p[1]),
//         );
//       }

//       // update reminder setiap menit
//       Timer.periodic(const Duration(minutes: 1), (_) {
//         setState(() => _reminderText = _makeReminder(checkIn, checkOut));
//       });

//       setState(() => _reminderText = _makeReminder(checkIn, checkOut));
//     } catch (e) {
//       setState(() => _reminderText = "Gagal memuat jadwal");
//     }
//   }

//   String _makeReminder(DateTime? checkIn, DateTime? checkOut) {
//     final now = DateTime.now();

//     if (checkIn != null && now.isBefore(checkIn)) {
//       final diff = checkIn.difference(now).inMinutes;
//       return "Check-in masih $diff menit lagi";
//     }

//     if (checkOut != null && now.isBefore(checkOut)) {
//       final diff = checkOut.difference(now).inMinutes;
//       return "Check-out masih $diff menit lagi";
//     }

//     if (checkIn != null && checkOut != null && now.isAfter(checkOut)) {
//       return "Jam kerja selesai";
//     }

//     return "Menunggu jadwal absen";
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final timeString =
//         "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//       decoration: BoxDecoration(
//         color: AppColor.form,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Text(
//             timeString,
//             style: const TextStyle(
//               color: AppColor.textDark,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Courier', // gaya jam digital
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _reminderText,
//             style: const TextStyle(
//               color: AppColor.textDark,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
