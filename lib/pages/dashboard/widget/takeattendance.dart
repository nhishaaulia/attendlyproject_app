import 'dart:async';

import 'package:attendlyproject_app/extension/navigation.dart';
import 'package:attendlyproject_app/pages/izin%20page/izin_page.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class TakeAttendancePage extends StatefulWidget {
  final VoidCallback onMapTap;
  final VoidCallback? onIzinTap;

  const TakeAttendancePage({super.key, required this.onMapTap, this.onIzinTap});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  late Timer _timer;
  String _digitalClock = "";
  String _statusText = "";

  DateTime? jamMasuk;
  bool _alreadyTriggered = false;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _digitalClock =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      if (jamMasuk != null) {
        if (now.isBefore(jamMasuk!)) {
          final diff = jamMasuk!.difference(now);
          _statusText = "Check in within ${diff.inMinutes} minutes";

          if (diff.inMinutes <= 5 && !_alreadyTriggered) {
            _triggerReminder("${diff.inMinutes} minutes left to check in!");
            _alreadyTriggered = true;
          }
        } else {
          jamMasuk = jamMasuk!.add(const Duration(days: 1));
          _alreadyTriggered = false;

          final diff = jamMasuk!.difference(now);
          _statusText = "Check in within ${diff.inMinutes} minutes";
        }
      } else {
        _statusText = "No specific check-in time set yet";
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _triggerReminder(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        leading: const Icon(Icons.notifications_active, color: Colors.pink),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      messenger.hideCurrentMaterialBanner();
    });
  }

  Future<void> _pickJamMasuk() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (selectedDateTime.isBefore(now)) {
        selectedDateTime = selectedDateTime.add(const Duration(days: 1));
      }

      setState(() {
        jamMasuk = selectedDateTime;
        _alreadyTriggered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jamMasukText = jamMasuk != null
        ? "${jamMasuk!.hour.toString().padLeft(2, '0')}:${jamMasuk!.minute.toString().padLeft(2, '0')} (${jamMasuk!.day}/${jamMasuk!.month}/${jamMasuk!.year})"
        : "Not selected yet";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // container utama putih
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.pinkMid.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Reminder Section =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.alarm, size: 22, color: AppColor.textDark),
                    SizedBox(width: 8),
                    Text(
                      "Digital Clock Reminder",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _digitalClock,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Check-in Time: $jamMasukText",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickJamMasuk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.pinkMid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Set Check-in Time"),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 24),

            // ===== Take Attendance Section =====
            Row(
              children: const [
                Icon(Icons.calendar_month, size: 22, color: AppColor.textDark),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Take Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                // Tombol Leave
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        widget.onIzinTap ??
                        () {
                          context.pushReplacement(const IzinPage());
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.form,
                      foregroundColor: AppColor.textDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Leave',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Present
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onMapTap,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.pinkMid, AppColor.pinkLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: const Text(
                          'Present',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
