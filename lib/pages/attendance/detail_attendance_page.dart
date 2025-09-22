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
  // ===== STATE =====
  bool _loading = false;
  String? _error;

  DataStatistik? _stat; // Statistik ringkas
  List<DataHistory> _history = []; // Riwayat lengkap

  @override
  void initState() {
    super.initState();
    _loadAll(); // COMMAND: saat halaman dibuka → ambil statistik + history
  }

  /// COMMAND: Ambil statistik + history attendance dari API
  /// 1) Ambil token dari storage
  /// 2) Panggil AttendanceApiService.summary(token)
  /// 3) Panggil AttendanceApiService.historyList(token)
  /// 4) Simpan ke state untuk dirender di UI
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

      // Urutkan terbaru dulu
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
        onRefresh: _loadAll, // COMMAND: tarik ke bawah untuk refresh API
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
        // ===== STATISTIK SUMMARY =====
        _statsSection(),

        const SizedBox(height: 18),

        // ===== TITLE RIWAYAT =====
        Row(
          children: const [
            Text(
              'All Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ===== LIST HISTORY =====
        if (_history.isEmpty)
          _emptyCard('Belum ada riwayat absensi.')
        else
          ..._history.map((h) => _historyCard(h)),
      ],
    );
  }

  // =========================
  // ========== UI ===========
  // =========================

  Widget _statsSection() {
    final doneToday = _stat?.sudahAbsenHariIni == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
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
                  color: const Color(0xFF24A148),
                  bg: const Color(0xFFE7F8EC),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statTile(
                  title: 'Permission',
                  value: (_stat?.totalIzin ?? 0).toString(),
                  color: const Color(0xFFB56200),
                  bg: const Color(0xFFFFF3E6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                doneToday ? Icons.check_circle : Icons.radio_button_unchecked,
                color: doneToday ? const Color(0xFF24A148) : AppColor.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                doneToday
                    ? 'You have taken attendance today'
                    : 'You have not taken attendance today',
                style: TextStyle(
                  color: doneToday
                      ? const Color(0xFF24A148)
                      : AppColor.textDark,
                  fontWeight: FontWeight.w600,
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
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(DataHistory item) {
    final dayName = DateFormat('EEEE', 'en_US').format(item.attendanceDate);
    final dateText =
        '${item.attendanceDate.day}/${item.attendanceDate.month}/${item.attendanceDate.year}';

    final inTime = _fmtTime(item.checkInTime);
    final outTime = _fmtTime(item.checkOutTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Hari
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
              _statusChip(item.status),
            ],
          ),

          const SizedBox(height: 12),

          // Check In / Check Out Blocks
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

          // Optional: alamat
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
    border: Border.all(color: const Color(0xFFE9EDF2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Format jam untuk tampilan:
  /// - Jika null/empty → "-- : -- : --"
  /// - Jika "07:30" atau "07:30:00" → ambil 5 char pertama ("07:30")
  String _fmtTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-- : -- : --';
    final s = raw.trim();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }
}
