import 'package:attendlyproject_app/model/today_absen_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
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
  State<CheckInOutContainer> createState() => CheckInOutContainerState();
}

class CheckInOutContainerState extends State<CheckInOutContainer> {
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

  Future<void> reload() async {
    await _fetchToday();
  }

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
          date = DateFormat('EEEE, d MMM yyyy', 'en_US').format(d);
          checkInTime = (today.checkInTime.trim().isEmpty)
              ? '-'
              : today.checkInTime;

          final String? co = today.checkOutTime?.toString().trim();
          checkOutTime = (co == null || co.isEmpty) ? '-' : co;

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
          content: Text('Failed to load today attendance: $e'),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColor.pinkMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.textDark.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.5), // shadow pink
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Baris Alamat ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_loading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // === Tanggal ===
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // === Dua pill check in/out ===
          Row(
            children: [
              Expanded(
                child: _pillTime(
                  label: 'Check In',
                  time: checkInTime,
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _pillTime(
                  label: 'Check Out',
                  time: checkOutTime,
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pillTime({
    required String label,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.form,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.4), // shadow pink
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.pinkMid, AppColor.pinkLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColor.textDark.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time.isEmpty ? '-' : time,
                  style: const TextStyle(
                    color: AppColor.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
