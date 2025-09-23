// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';

// class CheckInReminder extends StatefulWidget {
//   final DateTime checkInTime; // biar fleksibel, bisa atur dari dashboard

//   const CheckInReminder({super.key, required this.checkInTime});

//   @override
//   State<CheckInReminder> createState() => _CheckInReminderState();
// }

// class _CheckInReminderState extends State<CheckInReminder> {
//   late DateTime _simulatedNow;
//   Timer? _ticker;

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     _simulatedNow = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       now.hour,
//       now.minute,
//       now.second,
//     );

//     // update setiap detik biar jam digital jalan
//      _ticker = Timer.periodic(const Duration(seconds: 1), () {
//       setState(() {
//         _simulatedNow = _simulatedNow.add(const Duration(seconds: 1));
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _ticker?.cancel();
//     super.dispose();
//   }

//   String _formatTime(DateTime t) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
//   }

//   String _buildReminderText(DateTime now) {
//     final nowTrim = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       now.hour,
//       now.minute,
//     );
//     final checkInTrim = DateTime(
//       widget.checkInTime.year,
//       widget.checkInTime.month,
//       widget.checkInTime.day,
//       widget.checkInTime.hour,
//       widget.checkInTime.minute,
//     );

//     if (nowTrim.isBefore(checkInTrim) ||
//         nowTrim.isAtSameMomentAs(checkInTrim)) {
//       final sisaMenit = checkInTrim.difference(nowTrim).inMinutes;
//       if (sisaMenit == 0) return 'Absen sekarang! Waktunya masuk.';
//       return 'Absen sekarang! $sisaMenit menit lagi kamu bakal terlambat.';
//     } else {
//       final terlambatMenit = nowTrim.difference(checkInTrim).inMinutes;
//       return 'Anda terlambat $terlambatMenit menit dari jam masuk.';
//     }
//   }

//   void _triggerSnackBar() {
//     final msg = _buildReminderText(_simulatedNow);
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reminder = _buildReminderText(_simulatedNow);
//     final checkInLabel =
//         '${widget.checkInTime.hour.toString().padLeft(2, '0')}:${widget.checkInTime.minute.toString().padLeft(2, '0')}';

//     return Column(
//       children: [
//         Text(
//           _formatTime(_simulatedNow),
//           style: const TextStyle(
//             fontSize: 40,
//             fontFeatures: [FontFeature.tabularFigures()],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text('Jam masuk: $checkInLabel'),
//         const SizedBox(height: 12),
//         Text(
//           reminder,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: _triggerSnackBar,
//           child: const Text('Trigger Test'),
//         ),
//       ],
//     );
//   }
// }
