// import 'package:attendlyproject_app/extension/navigation.dart';
// import 'package:attendlyproject_app/pages/izin%20page/izin_page.dart';
// import 'package:attendlyproject_app/utils/app_color.dart';
// import 'package:flutter/material.dart';

// class SubmitAbsenWidget extends StatelessWidget {
//   final VoidCallback onMapTap;
//   final VoidCallback? onIzinTap; // optional callback izin

//   const SubmitAbsenWidget({super.key, required this.onMapTap, this.onIzinTap});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white, // ✅ Container putih
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColor.pinkLight),
//           boxShadow: [
//             BoxShadow(
//               color: AppColor.pinkMid.withOpacity(0.15),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ===== Header: Icon + Title =====
//             Row(
//               children: const [
//                 Icon(Icons.calendar_month, size: 22, color: AppColor.textDark),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Take Attendance',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppColor.textDark,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 18),

//             // ===== Buttons: Leave & Present =====
//             Row(
//               children: [
//                 // Tombol Leave (form pink background)
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed:
//                         onIzinTap ??
//                         () {
//                           context.pushReplacement(const IzinPage());
//                         },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.form, // ✅ warna form
//                       foregroundColor: AppColor.textDark,
//                       elevation: 2,
//                       shadowColor: AppColor.pinkMid.withOpacity(0.2),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Leave',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // Tombol Present (pinkMid)
//                 // Tombol Present (gradient)
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: onMapTap,
//                     style: ElevatedButton.styleFrom(
//                       padding:
//                           EdgeInsets.zero, // harus nol supaya gradient full
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                       shadowColor: AppColor.pinkMid.withOpacity(0.25),
//                     ),
//                     child: Ink(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColor.pinkMid,
//                             AppColor.pinkLight,
//                           ], // gradient pink
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Container(
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 12,
//                         ),
//                         child: const Text(
//                           'Present',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
