import 'package:attendlyproject_app/model/profile_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:attendlyproject_app/services/profile_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class HeaderDashboard extends StatefulWidget {
  const HeaderDashboard({super.key});

  @override
  State<HeaderDashboard> createState() => _HeaderDashboardState();
}

class _HeaderDashboardState extends State<HeaderDashboard> {
  DataProfile? _profile; // hasil API getProfile
  bool _loading = true; // state loading awal
  String? _error; // error message (kalau ada)

  @override
  void initState() {
    super.initState();
    _loadHeader(); // saat widget dibuat, langsung muat data
  }

  /// Muat header:
  /// 1) Ambil token dari storage
  /// 2) Panggil API: ProfileService.getProfile(token)
  Future<void> _loadHeader() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final data = await ProfileService.getProfile(token); // <— PANGGIL API

      if (!mounted) return;
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // === LOADING STATE ===
      return Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 16),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE9EDF2)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 16, width: 160),
                  const SizedBox(height: 8),
                  _shimmerBox(height: 14, width: 200),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      // === ERROR STATE ===
      return Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 16),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE9EDF2)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gagal memuat profil',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadHeader, // retry
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Retry',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final p = _profile!;
    final photoUrl = (p.profilePhoto != null && p.profilePhoto!.isNotEmpty)
        ? (p.profilePhoto!.startsWith('http')
              ? p.profilePhoto!
              : 'https://appabsensi.mobileprojp.com/public/${p.profilePhoto!}')
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto profil
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColor.pinkMid.withOpacity(.3),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(Icons.person, color: AppColor.bg, size: 30)
                : null,
          ),
          const SizedBox(width: 16),

          // Info profil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${p.name}!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${p.training.title} - Batch ${p.batch.batchKe}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // skeleton kecil
  Widget _shimmerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.border),
      ),
    );
  }
}
