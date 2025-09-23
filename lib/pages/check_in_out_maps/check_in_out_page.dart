import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/today_absen_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:attendlyproject_app/services/all_condition_absen_Service.dart';
import 'package:attendlyproject_app/services/check_in_out_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// === Tambah Import untuk API Today Absen ===

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

  String _address = 'Retrieving Address...';

  bool _isSubmitting = false;
  bool _isLoadingToday = true;
  String? _errorToday;

  TodayAbsenModel? absenToday;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadAbsenToday();
  }

  // === Ambil absen hari ini dari API ===
  Future<void> _loadAbsenToday() async {
    setState(() {
      _isLoadingToday = true;
      _errorToday = null;
    });
    try {
      final data = await AttendanceApiService.getAbsenToday();
      if (!mounted) return;
      setState(() {
        absenToday = data;
        _isLoadingToday = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorToday = e.toString();
        _isLoadingToday = false;
      });
    }
  }

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
      print(addr);
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

  // === Tombol utama untuk checkin/checkout ===
  Future<void> _onPressMainButton() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found / Expired');
      }

      final lat = _currentPosition.latitude;
      final lng = _currentPosition.longitude;
      final locationString = '$lat,$lng';
      final address = _address;

      if ((absenToday?.data.checkInTime ?? "").isEmpty) {
        // === CHECK IN ===
        final res = await CheckInOutService.checkIn(
          token: token,
          lat: lat,
          lng: lng,
          location: locationString,
          address: address,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Check-in successful')),
          );
        }
      } else if ((absenToday?.data.checkOutTime ?? "").isEmpty) {
        // === CHECK OUT ===
        final res = await CheckInOutService.checkOut(
          token: token,
          lat: lat,
          lng: lng,
          location: locationString,
          address: address,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Check-out successful')),
          );
        }
      }

      // ⬇️ setelah sukses, reload API biar update
      await _loadAbsenToday();
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
    final dateLabel = DateFormat('EEEE, d MMM yyyy', 'en_US').format(now);

    final mapHeight = MediaQuery.of(context).size.height * 0.38;

    final checkInTime = absenToday?.data.checkInTime ?? "--:--";
    final checkOutTime = absenToday?.data.checkOutTime ?? "--:--";
    final completed = checkInTime != "--:--" && checkOutTime != "--:--";

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
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    markers: _marker != null ? {_marker!} : {},
                    onMapCreated: (c) => _mapController = c,
                  ),

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

          // ===== CONTENT CARD =====
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
                  Text(_address, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),

                  // Card absensi
                  if (_isLoadingToday)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorToday != null)
                    Text(
                      "Error: $_errorToday",
                      style: const TextStyle(color: Colors.red),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.form, // warna form sesuai request
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.pinkMid.withOpacity(
                              0.2,
                            ), // shadow pink halus
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                  time: checkInTime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _timeTile(
                                  icon: Icons.logout,
                                  label: "Check Out",
                                  time: checkOutTime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: completed ? null : _onPressMainButton,
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
                                  : (checkInTime == "--:--"
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.bg, // warna form
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.pinkMid.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gradient Circle Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColor.pinkMid, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                    color: (time == null || time == "--:--")
                        ? AppColor.grey
                        : AppColor.textDark,
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
