import 'dart:async';

import 'package:attendlyproject_app/model/history_absen_model.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// SECTION "Attendance History (7 Days)" yang langsung fetch dari API.
/// Cara pakai di Dashboard:
///   AttendanceHistory7Days(
///     onDetailsTap: () => Navigator.pushNamed(context, '/history'), // optional
///   )
class AttendanceHistory7Days extends StatefulWidget {
  final VoidCallback? onDetailsTap;
  const AttendanceHistory7Days({super.key, this.onDetailsTap});

  @override
  State<AttendanceHistory7Days> createState() => _AttendanceHistory7DaysState();
}

class _AttendanceHistory7DaysState extends State<AttendanceHistory7Days> {
  bool _loading = false;
  String? _error;
  List<DataHistory> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory(); // COMMAND: fetch saat widget dibuat
  }

  /// COMMAND: Fetch 7 data history terbaru dari API AttendanceApiService.historyList
  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final all = await AttendanceApiService.historyList(token);

      // Sort by attendanceDate DESC, ambil 7 teratas
      all.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
      final top7 = all.take(7).toList();

      if (!mounted) return;
      setState(() => _items = top7);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat riwayat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        children: [
          // Header title + "Details >"
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onDetailsTap,
                child: const Text(
                  'Details',
                  style: TextStyle(color: AppColor.pinkMid),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (_loading) ...[
            _loadingCard(),
          ] else if (_error != null) ...[
            _errorCard(_error!),
          ] else if (_items.isEmpty) ...[
            _emptyCard(),
          ] else ...[
            // Render setiap item
            for (final it in _items) _HistoryCard(item: it),
          ],
        ],
      ),
    );
  }

  Widget _loadingCard() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(20),
    decoration: _box(),
    child: Row(
      children: const [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Loading history...'),
      ],
    ),
  );

  Widget _errorCard(String err) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: _box(),
    child: Text(err, style: const TextStyle(color: Colors.red)),
  );

  Widget _emptyCard() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: _box(),
    child: const Text(
      'Belum ada data riwayat.',
      style: TextStyle(color: AppColor.textDark),
    ),
  );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE9EDF2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// Kartu item tunggal seperti contoh foto:
/// - Hari: Monday
/// - Tanggal: 22/9/2025
/// - Chip status: PRESENT (hijau) / IZIN (oranye) / ABSENT (abu)
/// - Kolom Check in / Check out (kalau null tampil `-- : -- : --`)
class _HistoryCard extends StatelessWidget {
  final DataHistory item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE', 'en_US').format(item.attendanceDate);
    // Format dd/M/yyyy (tanpa leading zero di bulan, mirip foto)
    final dateText =
        '${item.attendanceDate.day}/${item.attendanceDate.month}/${item.attendanceDate.year}';

    final inTime = _fmtTime(item.checkInTime);
    final outTime = _fmtTime(item.checkOutTime);

    final chip = _statusChip(item.status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: Hari + (opsional bisa tambahkan titik hijau kalau mau)
          Text(
            dayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.textDark,
            ),
          ),
          const SizedBox(height: 6),

          // Tanggal + Chip Status
          Row(
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  color: AppColor.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              chip,
            ],
          ),

          const SizedBox(height: 12),

          // Kolom check in / out
          Row(
            children: [
              Expanded(
                child: _timeBlock(title: 'Check in', time: inTime),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeBlock(title: 'Check out', time: outTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Time formatter:
  /// - Kalau null/empty → `-- : -- : --` biar mirip contoh.
  /// - Kalau "07:30" atau "07:30:00" → tampil jam:menit (ambil 5 char pertama).
  static String _fmtTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-- : -- : --';
    final s = raw.trim();
    // Ambil jam:menit
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }

  Widget _statusChip(String status) {
    // Backend kamu: "masuk" / "izin" / mungkin "alpha" atau lain.
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status.toLowerCase()) {
      case 'masuk':
      case 'present':
        bg = const Color(0xFFE7F8EC);
        fg = const Color(0xFF24A148);
        label = 'PRESENT';
        break;
      case 'izin':
        bg = const Color(0xFFFFF3E6);
        fg = const Color(0xFFB56200);
        label = 'IZIN';
        break;
      default:
        bg = const Color(0xFFF1F2F6);
        fg = const Color(0xFF5F6B7A);
        label = 'ABSENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _timeBlock({required String title, required String time}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              color: AppColor.textDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
