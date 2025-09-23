import 'dart:io';

import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/model/profile_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
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
    _loadingProfile();
  }

  Future<void> _loadingProfile() async {
    final token = await PreferenceHandler.getToken();
    if (token != null) {
      setState(() {
        _futureProfile = ProfileService.getProfile(token);
      });
    }
  }

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
            profilePhoto: updated.profilePhoto,
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

  Future<void> _editName(DataProfile profile) async {
    String editedName = profile.name;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.pinkMid,
            ),
          ),
          content: TextFormField(
            initialValue: editedName,
            autofocus: true,
            cursorColor: AppColor.pinkMid,
            style: const TextStyle(color: AppColor.textDark),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: const TextStyle(color: AppColor.textDark),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.pinkMid, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.pinkMid),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => editedName = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColor.textDark),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.pinkMid,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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

  Future<void> _confirmAndLogout(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.textDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColor.textDark),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.textDark),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.pinkMid,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await PreferenceHandler.removeLogin();
      await PreferenceHandler.removeToken();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.textDark,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: AppColor.pinkMid.withOpacity(0.2),
                                //       blurRadius: 12,
                                //       offset: const Offset(0, 6),
                                //     ),
                                //   ],
                                // ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: AppColor.pinkMid.withOpacity(
                                    .3,
                                  ),
                                  backgroundImage:
                                      (profile.profilePhoto != null &&
                                          profile.profilePhoto!.isNotEmpty)
                                      ? NetworkImage(
                                          profile.profilePhoto!.startsWith(
                                                'http',
                                              )
                                              ? profile.profilePhoto!
                                              : 'https://appabsensi.mobileprojp.com/public/${profile.profilePhoto!}',
                                        )
                                      : null,
                                  child:
                                      (profile.profilePhoto == null ||
                                          profile.profilePhoto!.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUpload
                                      ? null
                                      : () => _UploadFoto(profile),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColor.pinkMid,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.pinkMid.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _editName(profile),
                              borderRadius: BorderRadius.circular(6),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColor.pinkMid,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.form,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.pinkMid.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _infoTile(
                                icon: Icons.layers_outlined,
                                title: 'Batch',
                                value: 'Batch ${profile.batchKe}',
                              ),
                              _divider(),
                              _infoTile(
                                icon: Icons.school_outlined,
                                title: 'Training',
                                value: profile.trainingTitle,
                              ),
                              _divider(),
                              _infoTile(
                                icon: Icons.wc_outlined,
                                title: 'Gender',
                                value: profile.jenisKelamin == 'L'
                                    ? 'Male'
                                    : profile.jenisKelamin == 'P'
                                    ? 'Female'
                                    : 'Not specified',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.pinkMid.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.pinkMid,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => _confirmAndLogout(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const CopyRightText(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.pinkMid),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColor.textDark,
        ),
      ),
      subtitle: Text(value, style: const TextStyle(color: AppColor.textDark)),
      dense: true,
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.6);
}
