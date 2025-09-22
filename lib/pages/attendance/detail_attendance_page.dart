// ignore_for_file: use_build_context_synchronously
import 'package:attendlyproject_app/model/history_absen_model.dart';
import 'package:attendlyproject_app/model/statistik_absen_model.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailAttendancePage extends StatefulWidget {
  const DetailAttendancePage({super.key});
  static const id = "/AttendancePage";

  @override
  State<DetailAttendancePage> createState() => _DetailAttendancePageState();
}

class _DetailAttendancePageState extends State<DetailAttendancePage> {
  bool _loading = false;
  String? _error;

  DataStatistik? _stat;
  List<DataHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final stat = await AttendanceApiService.summary(token);
      final items = await AttendanceApiService.historyList(token);
      items.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));

      if (!mounted) return;
      setState(() {
        _stat = stat;
        _history = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: AppColor.textDark,
      ),
      body: RefreshIndicator(
        color: AppColor.pinkMid,
        onRefresh: _loadAll,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.pinkMid),
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [_errorCard(_error!)],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statsSection(),
        const SizedBox(height: 20),
        const Text(
          'All Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          _emptyCard('Belum ada riwayat absensi.')
        else
          ..._history.map((h) => _historyCard(h)),
      ],
    );
  }

  // ===== Statistik Ringkas =====
  Widget _statsSection() {
    final doneToday = _stat?.sudahAbsenHariIni == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insert_chart, color: AppColor.pinkMid, size: 20),
              SizedBox(width: 8),
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColor.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  title: 'Total Days',
                  value: (_stat?.totalAbsen ?? 0).toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  title: 'Present',
                  value: (_stat?.totalMasuk ?? 0).toString(),
                  color: Colors.white,
                  bg: AppColor.pinkMid.withOpacity(0.85),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  title: 'Leave',
                  value: (_stat?.totalIzin ?? 0).toString(),
                  color: Colors.white,
                  bg: const Color(0xFFFCCFCF), // soft pink
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                doneToday ? Icons.check_circle : Icons.radio_button_unchecked,
                color: doneToday ? AppColor.pinkMid : AppColor.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  doneToday
                      ? 'You have taken attendance today'
                      : 'You have not taken attendance today',
                  style: TextStyle(
                    color: doneToday ? AppColor.pinkMid : AppColor.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required String title,
    required String value,
    Color color = AppColor.textDark,
    Color bg = const Color(0xFFF8FAFD),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColor.pinkMid.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.12),
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
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Card History (tambah Reason di sini) =====
  Widget _historyCard(DataHistory item) {
    final dayName = DateFormat('EEEE', 'en_US').format(item.attendanceDate);
    final dateText =
        '${item.attendanceDate.day}/${item.attendanceDate.month}/${item.attendanceDate.year}';
    final inTime = _fmtTime(item.checkInTime);
    final outTime = _fmtTime(item.checkOutTime);

    final showReason =
        item.status.toLowerCase() == 'izin' &&
        (item.alasanIzin?.isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _box(),
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
          if ((item.checkInAddress ?? '').isNotEmpty ||
              (item.checkOutAddress ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColor.grey,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (item.checkOutAddress ?? item.checkInAddress ?? '')
                        .toString(),
                    style: const TextStyle(
                      color: AppColor.textDark,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // ======== Reason ========
          if (showReason) ...[
            const SizedBox(height: 12),
            const Text(
              'Reason',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColor.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.alasanIzin ?? '',
              style: const TextStyle(fontSize: 13, color: AppColor.textDark),
            ),
          ],
        ],
      ),
    );
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

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Text(message, style: const TextStyle(color: AppColor.textDark)),
    );
  }

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

  String _fmtTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-- : -- : --';
    final s = raw.trim();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }
}
