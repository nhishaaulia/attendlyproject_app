import 'package:attendlyproject_app/copyright/copy_right.dart';
// === API TOKENS & SERVICE ===
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/check_in_out_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CheckInOutPage extends StatefulWidget {
  const CheckInOutPage({super.key});
  static const id = "/gmapspage";
  @override
  State<CheckInOutPage> createState() => _CheckInOutPageState();
}

class _CheckInOutPageState extends State<CheckInOutPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  double _currentZoom = 16;
  Marker? _marker;

  String _address = 'Retrieving Adsress...';
  String? _checkInTime;
  String? _checkOutTime;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLocalAttendance(); // ← muat jam lokal dulu
    _initLocation(); // ← tetap ambil lokasi
  }

  // Ambil lokasi user + reverse geocoding alamat, lalu set marker & kamera
  Future<void> _initLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    String addr = 'Address not found';
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      // lebih detail + fallback kalau null
      addr = [
        if ((p.street ?? '').isNotEmpty) p.street,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
        if ((p.locality ?? '').isNotEmpty) p.locality,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
        if ((p.postalCode ?? '').isNotEmpty) p.postalCode,
        if ((p.country ?? '').isNotEmpty) p.country,
      ].join(', ');
    }

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _address = addr;
      _marker = Marker(
        markerId: const MarkerId('Location'),
        position: _currentPosition,
      );
    });
  }

  Future<void> _animateZoom(double delta) async {
    if (_mapController == null) return;
    final newZoom = (_currentZoom + delta).clamp(2.0, 21.0);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: newZoom),
      ),
    );
    setState(() => _currentZoom = newZoom);
  }

  // ====== LOCAL ATTENDANCE HELPERS (DALAM STATE) ======

  // Kunci unik per-hari
  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Muat jam checkin/checkout dari storage agar tombol & label langsung sesuai
  Future<void> _loadLocalAttendance() async {
    final inTime = await PreferenceHandler.getString('checkin_$_todayKey');
    final outTime = await PreferenceHandler.getString('checkout_$_todayKey');
    if (!mounted) return;
    setState(() {
      _checkInTime = inTime; // bisa null kalau belum ada
      _checkOutTime = outTime; // bisa null kalau belum ada
    });
  }

  // Simpan jam checkin/checkout ke storage setelah sukses API
  Future<void> _saveLocalAttendance() async {
    if (_checkInTime != null) {
      await PreferenceHandler.setString('checkin_$_todayKey', _checkInTime!);
    }
    if (_checkOutTime != null) {
      await PreferenceHandler.setString('checkout_$_todayKey', _checkOutTime!);
    }
  }

  // Tombol utama
  // - Jika belum check-in → panggil API checkIn()
  // - Jika sudah check-in & belum check-out → panggil API checkOut()
  // - Token WAJIB ada; kalau null/empty → tampilkan error
  Future<void> _onPressMainButton() async {
    if (_isSubmitting) return; // cegah double tap
    setState(() => _isSubmitting = true);

    try {
      // 1) Ambil token dari storage
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found / Expired');
      }

      // 2) Siapkan payload lokasi untuk API
      final lat = _currentPosition.latitude;
      final lng = _currentPosition.longitude;
      final locationString = '$lat,$lng';
      final address = _address;

      // 3) Call API sesuai state
      if (_checkInTime == null) {
        // === CHECK IN ===
        final res = await CheckInOutService.checkIn(
          token: token,
          lat: lat,
          lng: lng,
          location: locationString,
          address: address,
        );

        setState(() {
          _checkInTime = (res.data.checkInTime.isNotEmpty)
              ? res.data.checkInTime
              : TimeOfDay.now().format(context);
        });

        // ⬇️ SIMPAN jam check-in ke storage (biar persist)
        await _saveLocalAttendance();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Check-in successful'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (_checkOutTime == null) {
        // === CHECK OUT ===
        final res = await CheckInOutService.checkOut(
          token: token,
          lat: lat,
          lng: lng,
          location: locationString,
          address: address,
        );

        setState(() {
          _checkOutTime = (res.data.checkOutTime.isNotEmpty)
              ? res.data.checkOutTime
              : TimeOfDay.now().format(context);
        });

        // ⬇️ SIMPAN jam check-out ke storage (biar persist)
        await _saveLocalAttendance();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Check-out successful'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final weekday = _weekdayLabel(now.weekday);
    final dateLabel = DateFormat('EEEE, d MMM yyyy', 'en_US').format(now);

    final mapHeight =
        MediaQuery.of(context).size.height * 0.38; // ➜ lebih pendek
    final completed = _checkInTime != null && _checkOutTime != null;

    return Scaffold(
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(
            color: AppColor.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColor.bg,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColor.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ===== MAPS =====
          Container(
            height: mapHeight,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: _currentZoom,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _marker != null ? {_marker!} : {},
                    onMapCreated: (c) => _mapController = c,
                  ),

                  // Zoom in/out
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      children: [
                        _roundIconButton(
                          icon: Icons.add,
                          onTap: () => _animateZoom(1),
                        ),
                        const SizedBox(height: 10),
                        _roundIconButton(
                          icon: Icons.remove,
                          onTap: () => _animateZoom(-1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENT CARD + COPYRIGHT =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _address,
                    maxLines: 3, // 3 baris
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.pinkExtraLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _timeTile(
                                icon: Icons.login,
                                label: "Check In",
                                time: _checkInTime,
                                accent: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _timeTile(
                                icon: Icons.logout,
                                label: "Check Out",
                                time: _checkOutTime,
                                accent: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // COMMAND: tekan → _onPressMainButton()
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: completed
                          ? null
                          : _onPressMainButton, // disable kalau complete
                      style: ElevatedButton.styleFrom(
                        backgroundColor: completed
                            ? AppColor.grey
                            : AppColor.pinkMid,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              completed
                                  ? "Attendance Complete"
                                  : (_checkInTime == null
                                        ? "Check In"
                                        : "Check Out"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const CopyRightText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColor.textDark),
        ),
      ),
    );
  }

  Widget _timeTile({
    required IconData icon,
    required String label,
    required String? time,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time ?? "-",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: time == null ? AppColor.grey : AppColor.textDark,
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

  String _weekdayLabel(int w) {
    const arr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return arr[w - 1];
  }

  String _monthLabel(int m) {
    const arr = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return arr[m - 1];
  }
}
