import 'dart:async';

import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
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
          _statusText = "Masuk dalam ${diff.inMinutes} menit";

          if (diff.inMinutes <= 5 && !_alreadyTriggered) {
            _triggerReminder("Waktu masuk tinggal ${diff.inMinutes} menit!");
            _alreadyTriggered = true;
          }
        } else {
          // sudah lewat → otomatis pindah ke hari berikutnya
          jamMasuk = jamMasuk!.add(const Duration(days: 1));
          _alreadyTriggered = false;

          final diff = jamMasuk!.difference(now);
          _statusText = "Masuk dalam ${diff.inMinutes} menit";
        }
      } else {
        _statusText = "Belum ada jam masuk yang ditentukan";
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
        leading: const Icon(Icons.notifications_active, color: Colors.blue),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: const Text("Tutup"),
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

      // kalau jam yang dipilih sudah lewat → otomatis jadwalkan besok
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
        : "Belum dipilih";

    return Scaffold(
      appBar: AppBar(title: const Text("Reminder Jam Digital")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _digitalClock,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text("Jam masuk: $jamMasukText"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickJamMasuk,
              child: const Text("Atur Jam Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}
