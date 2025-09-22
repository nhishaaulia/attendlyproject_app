import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mengecek & meminta izin
  static Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // kalau deniedForever, biarin caller yg handle (return apa adanya)
    return permission;
  }

  // Ambil posisi terkini
  static Future<Position?> fetchCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    final permission = await requestLocationPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // PERBAIKAN: gunakan getCurrentPosition (bukan fetchCurrentPosition)
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10), // opsional
    );
  }

  // Reverse geocoding
  static Future<String?> getAddressCoordinates(Position pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Jarak user → kantor (meter)
  static Future<double?> calculateDistance() async {
    const officeLatitude = -6.210873460989455;
    const officeLongitude = 106.81294507856053;

    final pos = await fetchCurrentLocation();
    if (pos == null) return null;

    return Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      officeLatitude,
      officeLongitude,
    );
  }

  // Ambil alamat saat ini
  static Future<String?> fetchCurrentAddress() async {
    final pos = await fetchCurrentLocation();
    if (pos == null) return null;
    return getAddressCoordinates(pos);
  }
}
