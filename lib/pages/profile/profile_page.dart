import 'dart:io';

import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/profile_model.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:attendlyproject_app/services/profile_service.dart';
import 'package:attendlyproject_app/splash_screen/splash_screen.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<DataProfile>? _futureProfile;
  bool _isUpload = false;

  @override
  void initState() {
    super.initState();
    _loadingProfile(); // buka page -> load profil
  }

  // ====== API: GET profile ======
  Future<void> _loadingProfile() async {
    final token = await PreferenceHandler.getToken();
    if (token != null) {
      setState(() {
        _futureProfile = ProfileService.getProfile(token);
      });
    }
  }

  // ====== API: Update photo (gallery) ======
  Future<void> _UploadFoto(DataProfile profile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final token = await PreferenceHandler.getToken();
    if (token == null) return;

    setState(() => _isUpload = true);

    try {
      final updated = await ProfileService.updatePhoto(
        token: token,
        photoFile: File(pickedFile.path),
      );

      setState(() {
        _futureProfile = Future.value(
          DataProfile(
            id: profile.id,
            name: profile.name,
            email: profile.email,
            batchKe: profile.batchKe,
            trainingTitle: profile.trainingTitle,
            batch: profile.batch,
            training: profile.training,
            jenisKelamin: profile.jenisKelamin,
            profilePhoto: updated.profilePhoto, // url foto terbaru
          ),
        );
        _isUpload = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUpload = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====== Edit nama ======
  Future<void> _editName(DataProfile profile) async {
    String editedName = profile.name;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.form,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          title: const Text('Name Edit'),
          content: Padding(
            padding: EdgeInsets.only(),
            child: SizedBox(
              height: 64, // compact
              child: Center(
                child: TextFormField(
                  initialValue: editedName,
                  autofocus: true,
                  cursorColor: AppColor.pinkMid,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: AppColor.textDark),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.pinkMid),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.pinkMid),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.pinkMid, width: 2),
                    ),
                  ),
                  onChanged: (v) => editedName = v,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColor.textDark),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // kalau mau tombol pink: backgroundColor: AppColor.pinkMid, foregroundColor: Colors.white,
                foregroundColor: AppColor.textDark,
              ),
              onPressed: () async {
                final token = await PreferenceHandler.getToken();
                if (token == null) return;
                try {
                  final updated = await ProfileService.updateName(
                    token: token,
                    name: editedName,
                  );
                  setState(() {
                    _futureProfile = Future.value(
                      DataProfile(
                        id: updated.id,
                        name: updated.name,
                        email: updated.email,
                        batchKe: profile.batchKe,
                        trainingTitle: profile.trainingTitle,
                        batch: profile.batch,
                        training: profile.training,
                        jenisKelamin: profile.jenisKelamin,
                        profilePhoto: profile.profilePhoto,
                      ),
                    );
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update name: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ====== Konfirmasi + logout ======
  Future<void> _confirmAndLogout(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.form,
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.textDark),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.textDark),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await PreferenceHandler.removeLogin();
      await PreferenceHandler.removeToken();
      // await PreferenceHandler.removeLogin();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // anti-overflow saat keyboard muncul
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.textDark,
        elevation: 0.5,
      ),
      body: _futureProfile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.pinkMid),
            )
          : FutureBuilder<DataProfile>(
              future: _futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.pinkMid),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Failed to load profile'));
                }

                final profile = snapshot.data!;
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // === Avatar + edit photo ===
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColor.grey,
                                backgroundImage:
                                    (profile.profilePhoto != null &&
                                        profile.profilePhoto!.isNotEmpty)
                                    ? NetworkImage(
                                        profile.profilePhoto!.startsWith('http')
                                            ? profile.profilePhoto!
                                            : 'https://appabsensi.mobileprojp.com/public/${profile.profilePhoto!}',
                                      )
                                    : null,
                                child:
                                    (profile.profilePhoto == null ||
                                        profile.profilePhoto!.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColor.bg,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUpload
                                      ? null
                                      : () => _UploadFoto(profile),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColor.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: _isUpload
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // === Nama + ikon edit ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _editName(profile),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColor.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // === Info Batch - Training - Gender ===
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.form,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.border),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.layers_outlined,
                                  color: AppColor.textDark,
                                ),
                                title: const Text(
                                  'Batch',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Batch ${profile.batchKe}'),
                              ),
                              const Divider(height: 8),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.school_outlined,
                                  color: AppColor.textDark,
                                ),
                                title: const Text(
                                  'Training',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(profile.trainingTitle),
                              ),
                              const Divider(height: 8),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.wc_outlined,
                                  color: AppColor.textDark,
                                ),
                                title: const Text(
                                  'Gender',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  profile.jenisKelamin == 'L'
                                      ? 'Male'
                                      : profile.jenisKelamin == 'P'
                                      ? 'Female'
                                      : 'Not specified',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // === Tombol Logout (konfirmasi+eksekusi) ===
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.pinkMid,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => _confirmAndLogout(context),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const CopyRightText(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
