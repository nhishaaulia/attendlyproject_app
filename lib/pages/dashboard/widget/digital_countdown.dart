// // File: lib/widgets/digital_countdown_with_api.dart
// import 'dart:async';

// import 'package:attendlyproject_app/model/today_absen_model.dart';
// // === API & Model ===
// import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
// import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
// import 'package:attendlyproject_app/utils/app_color.dart';
// import 'package:flutter/material.dart';

// /// =======================================================================
// /// WIDGET WRAPPER YANG TERHUBUNG API
// /// - Fetch "today absen" dari server menggunakan token
// /// - Mengubah data jadi status isCheckedIn / isCheckedOut
// /// - Menyisipkan DigitalCountdownSimple (jam + countdown + reminder)
// /// - Tampil "Attendance Complete" kalau sudah check-in & check-out
// /// =======================================================================
// class AttendanceClockCard extends StatefulWidget {
//   /// Jam masuk (sesuaikan dengan aturan kantor)
//   final TimeOfDay shiftStart;

//   /// Jam pulang (sesuaikan dengan aturan kantor)
//   final TimeOfDay shiftEnd;

//   /// X menit sebelum target (Check In / Check Out) untuk diingatkan
//   final int remindMinutes;

//   const AttendanceClockCard({
//     super.key,
//     this.shiftStart = const TimeOfDay(hour: 8, minute: 0),
//     this.shiftEnd = const TimeOfDay(hour: 15, minute: 0),
//     this.remindMinutes = 5,
//   });

//   @override
//   State<AttendanceClockCard> createState() => _AttendanceClockCardState();
// }

// class _AttendanceClockCardState extends State<AttendanceClockCard> {
//   bool _loading = false;
//   String? _error;

//   // Waktu checkin / checkout dari API (string “HH:mm” atau null)
//   String? _checkInTime;
//   String? _checkOutTime;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTodayFromApi(); // COMMAND: Saat widget dibuat → ambil status absen hari ini
//   }

//   /// COMMAND: Ambil data absen hari ini dari API
//   /// 1) Ambil token dari storage
//   /// 2) Panggil AttendanceApiService.today(token)
//   /// 3) Mapping hasil → checkInTime & checkOutTime
//   /// 4) Jika sukses, update state → jam digital membaca status terbaru
//   Future<void> _fetchTodayFromApi() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final token = await PreferenceHandler.getToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Token tidak ditemukan. Silakan login ulang.');
//       }

//       final DataAbsenToday? today = await AttendanceApiService.today(token);

//       // Catatan:
//       // - today == null artinya belum ada absen hari ini
//       // - today.checkOutTime bisa null
//       if (!mounted) return;
//       setState(() {
//         _checkInTime = (today?.checkInTime ?? '').trim().isEmpty
//             ? null
//             : today!.checkInTime;
//         final co = today?.checkOutTime?.toString() ?? '';
//         _checkOutTime = co.trim().isEmpty ? null : co;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _error = e.toString());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal memuat status absensi: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Status untuk jam digital:
//     final bool isCheckedIn =
//         _checkInTime != null && _checkInTime!.trim().isNotEmpty;
//     final bool isCheckedOut =
//         _checkOutTime != null && _checkOutTime!.trim().isNotEmpty;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Kartu JAM + COUNTDOWN + REMINDER
//         DigitalCountdownSimple(
//           shiftStart: widget.shiftStart,
//           shiftEnd: widget.shiftEnd,
//           isCheckedIn: isCheckedIn,
//           isCheckedOut: isCheckedOut,
//           remindMinutes: widget.remindMinutes,
//         ),

//         // Baris status singkat + tombol refresh manual (opsional)
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               if (_loading)
//                 const SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               else
//                 IconButton(
//                   tooltip: 'Refresh status absensi',
//                   onPressed: _fetchTodayFromApi,
//                   icon: const Icon(
//                     Icons.refresh_rounded,
//                     color: AppColor.textDark,
//                   ),
//                 ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   _error != null
//                       ? 'Error: $_error'
//                       : isCheckedIn && isCheckedOut
//                       ? 'Attendance Complete 🎉'
//                       : isCheckedIn
//                       ? 'Checked in at ${_checkInTime ?? "-"}'
//                       : 'Belum check-in',
//                   style: const TextStyle(
//                     color: AppColor.textDark,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// =======================================================================
// /// DIGITAL COUNTDOWN SIMPLE (JAM + COUNTDOWN + REMINDER SNACKBAR)
// /// - Menampilkan jam digital HH:mm:ss
// /// - Menentukan target otomatis (Check In / Check Out) dari status
// /// - Tombol “Remind me X min before” → SnackBar saat waktunya
// /// =======================================================================
// class DigitalCountdownSimple extends StatefulWidget {
//   final TimeOfDay shiftStart;
//   final TimeOfDay shiftEnd;
//   final bool isCheckedIn;
//   final bool isCheckedOut;
//   final int remindMinutes;

//   const DigitalCountdownSimple({
//     super.key,
//     required this.shiftStart,
//     required this.shiftEnd,
//     required this.isCheckedIn,
//     required this.isCheckedOut,
//     this.remindMinutes = 10,
//   });

//   @override
//   State<DigitalCountdownSimple> createState() => _DigitalCountdownSimpleState();
// }

// class _DigitalCountdownSimpleState extends State<DigitalCountdownSimple> {
//   late Timer _tick; // update jam tiap detik
//   Timer? _reminderTimer; // timer untuk reminder SnackBar
//   DateTime _now = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     _tick = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() {
//     _tick.cancel();
//     _reminderTimer?.cancel();
//     super.dispose();
//   }

//   /// Helper: buat DateTime “hari ini jam t”
//   DateTime _todayAt(TimeOfDay t) {
//     final n = DateTime.now();
//     return DateTime(n.year, n.month, n.day, t.hour, t.minute);
//   }

//   /// Tentukan target berdasarkan status:
//   /// - belum check-in  → target = shiftStart ("Check In")
//   /// - sudah check-in, belum check-out → target = shiftEnd ("Check Out")
//   /// - sudah check-out → null (complete)
//   _Target? _targetNow() {
//     final start = _todayAt(widget.shiftStart);
//     final end = _todayAt(widget.shiftEnd);

//     if (!widget.isCheckedIn) {
//       return _Target('Check In', start);
//     }
//     if (!widget.isCheckedOut) {
//       return _Target('Check Out', end);
//     }
//     return null;
//   }

//   String _two(int n) => n.toString().padLeft(2, '0');
//   String _fmtClock(DateTime dt) =>
//       '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
//   Duration _leftTo(DateTime t) => t.difference(_now);

//   /// Set reminder sederhana (SnackBar) X menit sebelum target
//   void _setReminder() {
//     final tgt = _targetNow();
//     if (tgt == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Attendance Complete — tidak ada target lagi.'),
//         ),
//       );
//       return;
//     }

//     final reminderAt = tgt.at.subtract(Duration(minutes: widget.remindMinutes));
//     final diff = reminderAt.difference(DateTime.now());

//     _reminderTimer?.cancel();

//     if (diff.isNegative) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Waktu reminder sudah lewat. Kurangi menit atau ubah jam ${tgt.label}.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     _reminderTimer = Timer(diff, () {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             '${widget.remindMinutes} menit lagi ${tgt.label.toLowerCase()}!',
//           ),
//         ),
//       );
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Reminder disetel: ${widget.remindMinutes} menit sebelum ${tgt.label}',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tgt = _targetNow();

//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColor.form,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColor.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Jam digital besar
//           Text(
//             _fmtClock(_now),
//             style: const TextStyle(
//               fontSize: 40,
//               letterSpacing: 1.5,
//               fontWeight: FontWeight.w800,
//               color: AppColor.textDark,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // Countdown / Complete
//           if (tgt == null)
//             const Text(
//               'Attendance Complete 🎉',
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: AppColor.textDark,
//               ),
//             )
//           else
//             _CountdownLine(label: tgt.label, left: _leftTo(tgt.at)),

//           const SizedBox(height: 12),

//           // Tombol set reminder (muncul kalau masih ada target)
//           if (tgt != null)
//             SizedBox(
//               height: 42,
//               child: OutlinedButton.icon(
//                 onPressed: _setReminder,
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppColor.pinkMid,
//                   side: const BorderSide(color: AppColor.pinkMid),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 icon: const Icon(Icons.alarm_add_outlined, size: 18),
//                 label: Text('Remind me ${widget.remindMinutes} min before'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// /// Komponen kecil: teks hitung mundur
// class _CountdownLine extends StatelessWidget {
//   final String label; // "Check In" / "Check Out"
//   final Duration left; // sisa waktu (bisa negatif)

//   const _CountdownLine({required this.label, required this.left});

//   String _two(int n) => n.toString().padLeft(2, '0');

//   @override
//   Widget build(BuildContext context) {
//     final isPast = left.isNegative;
//     final d = left.abs();
//     final h = d.inHours;
//     final m = d.inMinutes.remainder(60);
//     final s = d.inSeconds.remainder(60);

//     final txt = isPast
//         ? '${_two(h)}:${_two(m)}:${_two(s)} late to $label'
//         : '${_two(h)}:${_two(m)}:${_two(s)} to $label';

//     return Text(
//       txt,
//       style: TextStyle(
//         fontWeight: FontWeight.w600,
//         color: isPast ? Colors.redAccent : AppColor.textDark,
//       ),
//     );
//   }
// }

// /// Struktur sederhana untuk target event
// class _Target {
//   final String label;
//   final DateTime at;
//   _Target(this.label, this.at);
// }
