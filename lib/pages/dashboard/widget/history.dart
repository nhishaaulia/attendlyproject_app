import 'dart:async';

import 'package:attendlyproject_app/extension/navigation.dart';
import 'package:attendlyproject_app/model/history_absen_model.dart';
import 'package:attendlyproject_app/pages/attendance/detail_attendance_page.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    _loadHistory();
  }

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
      all.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
      final top3 = all.take(3).toList();

      if (!mounted) return;
      setState(() => _items = top3);
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
                onPressed: () {
                  context.push(const DetailAttendancePage());
                },
                child: const Text(
                  'Details',
                  style: TextStyle(color: AppColor.pinkMid),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            _loadingCard()
          else if (_error != null)
            _errorCard(_error!)
          else if (_items.isEmpty)
            _emptyCard()
          else
            ..._items.map((it) => _HistoryCard(item: it)),
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
      'No attendance history yet.',
      style: TextStyle(color: AppColor.textDark),
    ),
  );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColor.pinkMid.withOpacity(0.15)),
    boxShadow: [
      BoxShadow(
        color: AppColor.pinkMid.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class _HistoryCard extends StatelessWidget {
  final DataHistory item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE', 'en_US').format(item.attendanceDate);
    final dateText =
        '${item.attendanceDate.day}/${item.attendanceDate.month}/${item.attendanceDate.year}';

    final inTime = _fmtTime(item.checkInTime);
    final outTime = _fmtTime(item.checkOutTime);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.pinkMid.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.textDark,
            ),
          ),
          const SizedBox(height: 6),
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
              _statusChip(item.status),
            ],
          ),
          if ((item.status.toLowerCase() == 'izin' ||
                  item.status.toLowerCase() == 'leave') &&
              (item.alasanIzin ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason : ${item.alasanIzin}',
              style: const TextStyle(
                color: AppColor.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeBlock(
                  title: 'Check In',
                  time: inTime,
                  accent: AppColor.pinkMid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeBlock(
                  title: 'Check Out',
                  time: outTime,
                  accent: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-- : -- : --';
    final s = raw.trim();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  Widget _statusChip(String status) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status.toLowerCase()) {
      case 'masuk':
      case 'present':
        bg = AppColor.pinkMid.withOpacity(0.15);
        fg = AppColor.pinkMid;
        label = 'PRESENT';
        break;
      case 'izin':
      case 'leave':
        bg = const Color(0xFFFCCFCF);
        fg = const Color(0xFFB94B4B);
        label = 'LEAVE';
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

  Widget _timeBlock({
    required String title,
    required String time,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
            style: TextStyle(
              fontSize: 18,
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
