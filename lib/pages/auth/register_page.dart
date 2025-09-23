import 'dart:convert'; // untuk base64Encode (convert file jadi string)
import 'dart:io'; // untuk akses File

import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/extension/navigation.dart';
import 'package:attendlyproject_app/model/batches_model.dart';
import 'package:attendlyproject_app/model/training_model.dart';
import 'package:attendlyproject_app/pages/auth/login_page.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:attendlyproject_app/services/auth_services.dart';
import 'package:attendlyproject_app/services/batches_services.dart';
import 'package:attendlyproject_app/services/trainings_services.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = "/registerpage";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final TextEditingController confirmC = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool isSubmitting = false;
  bool isLoadingList = true;

  List<DataBatches> batches = [];
  List<DataTrainings> trainings = [];

  DataBatches? selectedBatch;
  DataTrainings? selectedTraining;

  final List<Map<String, String>> genderOptions = [
    {'label': 'Male', 'value': 'L'},
    {'label': 'Female', 'value': 'P'},
  ];
  String? selectedGenderCode;

  File? _profileFile;

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileFile = File(picked.path));
  }

  Future<String> _fileToDataUrl(File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    return 'data:$mimeType;base64,$base64Str';
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => isLoadingList = true);
    try {
      final trainingsResponse = await TrainingsService.getTrainingList();
      final batchesResponse = await BatchesServices.getBatchList();

      setState(() {
        trainings = trainingsResponse.data;
        batches = batchesResponse.data;
        if (trainings.isNotEmpty) selectedTraining = trainings.first;
        if (batches.isNotEmpty) selectedBatch = batches.first;
        isLoadingList = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingList = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load lists: $e')));
    }
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGenderCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your gender')),
      );
      return;
    }
    if (selectedBatch == null || selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose batch and training')),
      );
      return;
    }

    final int batchId = selectedBatch!.id;
    final int trainingId = selectedTraining!.id;
    final String jenisKelamin = selectedGenderCode!;
    String profilePhoto = "";
    if (_profileFile != null) {
      profilePhoto = await _fileToDataUrl(_profileFile!);
    }

    setState(() => isSubmitting = true);

    try {
      await AuthService.registerUser(
        nameC.text.trim(),
        emailC.text.trim(),
        passC.text,
        jenisKelamin,
        profilePhoto,
        batchId,
        trainingId,
      );

      await PreferenceHandler.saveLogin();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/sukses_animation.json',
                  width: 150,
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Registration complete! Please log in.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 4), () {
        Navigator.of(context).pop();
        context.pushReplacement(LoginPage());
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration Failed!")));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColor.bg,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Create your account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.bg,
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColor.pinkMid.withOpacity(
                                    .5,
                                  ),
                                  backgroundImage: _profileFile != null
                                      ? FileImage(_profileFile!)
                                      : null,
                                  child: _profileFile == null
                                      ? const Icon(
                                          Icons.person_add,
                                          size: 42,
                                          color: AppColor.bg,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: _pickAvatar,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: AppColor.pinkMid,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Choose a profile photo (Optional)",
                                  style: TextStyle(
                                    color: AppColor.pinkMid,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel("Name"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: nameC,
                            hint: "Username",
                            icon: Icons.person_outline,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Username cannot be empty'
                                : v.length < 3
                                ? 'Username must be at least 3 characters'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel("Email"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: emailC,
                            hint: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Email cannot be empty'
                                : !v.contains('@')
                                ? 'Please enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel("Password"),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: passC,
                            hintText: "Password",
                            visible: isPasswordVisible,
                            onToggle: () => setState(
                              () => isPasswordVisible = !isPasswordVisible,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Password cannot be empty'
                                : v.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel("Confirm Password"),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: confirmC,
                            hintText: "Confirm Password",
                            visible: isConfirmPasswordVisible,
                            onToggle: () => setState(
                              () => isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Confirm Password cannot be empty'
                                : v != passC.text
                                ? 'Password and Confirm Password do not match'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          const _FieldLabel("Select Training"),
                          const SizedBox(height: 8),
                          isLoadingList
                              ? const SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.pinkMid,
                                    ),
                                  ),
                                )
                              : _buildDropdown<DataTrainings>(
                                  value: selectedTraining,
                                  items: trainings,
                                  display: (item) => item.title,
                                  onChanged: (val) =>
                                      setState(() => selectedTraining = val),
                                  prefixIcon: Icons.school_outlined,
                                  validator: (val) => val == null
                                      ? "Please select training"
                                      : null,
                                ),
                          const SizedBox(height: 14),

                          const _FieldLabel("Select Batch"),
                          const SizedBox(height: 8),
                          isLoadingList
                              ? const SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.pinkMid,
                                    ),
                                  ),
                                )
                              : _buildDropdown<DataBatches>(
                                  value: selectedBatch,
                                  items: batches,
                                  display: (item) => item.batchKe,
                                  onChanged: (val) =>
                                      setState(() => selectedBatch = val),
                                  prefixIcon: Icons.layers_outlined,
                                  validator: (val) => val == null
                                      ? "Please select batch"
                                      : null,
                                ),
                          const SizedBox(height: 16),

                          const _FieldLabel("Gender"),
                          const SizedBox(height: 8),
                          Row(
                            children: genderOptions.map((option) {
                              return Expanded(
                                child: RadioListTile<String>(
                                  value: option['value']!,
                                  groupValue: selectedGenderCode,
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  activeColor: AppColor.pinkMid,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(option['label']!),
                                  onChanged: (val) =>
                                      setState(() => selectedGenderCode = val),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (isSubmitting || isLoadingList)
                            ? null
                            : _submitRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.pinkMid,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "REGISTER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const CopyRightText(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColor.form,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.textDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool visible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
        ),
        filled: true,
        fillColor: AppColor.form,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.textDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: AppColor.form,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.textDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(display(item))),
          )
          .toList(),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppColor.textDark),
    );
  }
}
