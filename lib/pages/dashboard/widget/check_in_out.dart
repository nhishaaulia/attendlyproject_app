import 'package:attendlyproject_app/model/today_absen_model.dart';
// API & token
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckInOutContainer extends StatefulWidget {
  final String initialAddress;
  final String initialDate;
  final String initialCheckInTime;
  final String initialCheckOutTime;

  const CheckInOutContainer({
    super.key,
    required this.initialAddress,
    required this.initialDate,
    required this.initialCheckInTime,
    required this.initialCheckOutTime,
  });

  @override
  State<CheckInOutContainer> createState() => _CheckInOutContainerState();
}

class _CheckInOutContainerState extends State<CheckInOutContainer> {
  late String address;
  late String date;
  late String checkInTime;
  late String checkOutTime;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // SET NILAI AWAL DARI PARAMETER
    address = widget.initialAddress;
    date = widget.initialDate;

    // SEBELUM CHECK-IN/CHECK-OUT → TAMPILKAN "-" (BUKAN JAM DUMMY)
    checkInTime = (widget.initialCheckInTime.trim().isEmpty)
        ? '-'
        : widget.initialCheckInTime;
    checkOutTime = (widget.initialCheckOutTime.trim().isEmpty)
        ? '-'
        : widget.initialCheckOutTime;

    // SAAT WIDGET DIBUAT → LANGSUNG AMBIL DATA ABSEN HARI INI
    _fetchToday();
  }

  /// PUBLIC: Dipanggil PARENT setelah check-in / check-out sukses.
  /// Contoh penggunaan di parent:
  ///   final key = GlobalKey<_CheckInOutContainerState>();
  ///   CheckInOutContainer(key: key, ...);
  ///   // setelah sukses check-in / check-out:
  ///   key.currentState?.reload();
  Future<void> reload() async {
    await _fetchToday();
  }

  /// COMMAND: Ambil absen HARI INI
  /// 1) Ambil token dari storage
  /// 2) Panggil AttendanceApiService.today(token)
  /// 3) Isi state:
  ///    - Tanggal format EN: EEEE, d MMM yyyy
  ///    - Jam: "-" jika kosong
  ///    - Alamat: prioritaskan check_in_address, fallback ke check_out_address
  Future<void> _fetchToday() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final DataAbsenToday? today = await AttendanceApiService.today(token);

      if (today != null && mounted) {
        final DateTime d = today.attendanceDate;

        setState(() {
          // FORMAT TANGGAL ENGLISH
          date = DateFormat('EEEE, d MMM yyyy', 'en_US').format(d);

          // WAKTU AMAN "-": SEBELUM CHECK-IN/CHECK-OUT
          checkInTime = (today.checkInTime.trim().isEmpty)
              ? '-'
              : today.checkInTime;

          final String? co = today.checkOutTime?.toString().trim();
          checkOutTime = (co == null || co.isEmpty) ? '-' : co;

          // ALAMAT AKURAT DARI API (CHECK-IN DULU, Fallback CHECK-OUT)
          address = today.checkInAddress.isNotEmpty
              ? today.checkInAddress
              : (today.checkOutAddress?.toString().isNotEmpty == true
                    ? today.checkOutAddress.toString()
                    : address);
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat absen hari ini: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // GRADIENT PINK
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF88CB), Color(0xFFFF6FBA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS ALAMAT + INDIKATOR LOADING KECIL (TANPA TOMBOL REFRESH)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (_loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // CHIP TANGGAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // DUA "PILL" UNTUK CHECK IN / CHECK OUT
          Row(
            children: [
              Expanded(
                child: _pillTime(
                  label: 'Check In',
                  time: checkInTime,
                  icon: Icons.login_rounded,
                  bg: Colors.white,
                  fg: AppColor.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pillTime(
                  label: 'Check Out',
                  time: checkOutTime,
                  icon: Icons.logout_rounded,
                  bg: Colors.white.withOpacity(0.85),
                  fg: AppColor.textDark,
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // KOMPONEN KECIL UNTUK "PILL" WAKTU
  Widget _pillTime({
    required String label,
    required String time,
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColor.pinkExtraLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.pinkMid, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: fg.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  // SEBELUM CHECK-IN/CHECK-OUT → TAMPILKAN "-"
                  (time.isEmpty ? '-' : time),
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
