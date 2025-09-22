import 'package:attendlyproject_app/copyright/copy_right.dart';
import 'package:attendlyproject_app/services/izin_service.dart';
import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});
  static const id = "/izinPage";

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();
  DateTime? _selectedDate;
  String? _tipeIzin;
  bool _isLoading = false;

  final List<Map<String, String>> _tipeIzinOptions = [
    {'value': 'sick', 'label': 'Sick Leave'},
    {'value': 'personal', 'label': 'Personal Leave'},
    {'value': 'business', 'label': 'Business Trip'},
    {'value': 'family', 'label': 'Family Matter'},
    {'value': 'other', 'label': 'Other'},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.pinkMid, // header & buttons OK/Cancel
              onPrimary: Colors.white, // teks header putih
              onSurface: AppColor.textDark, // teks tanggal
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.pinkMid, // tombol OK/Cancel
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitIzin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _tipeIzin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date & leave type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final izin = await IzinService.izinAbsen(
        date: _selectedDate!.toIso8601String().split("T")[0],
        alasanIzin: _alasanController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(izin.message ?? "Leave request submitted"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedDate = null;
        _tipeIzin = null;
        _alasanController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColor.textDark,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/OverviewPage',
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.textDark,
        title: const Text(
          'Leave Request',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Info Box =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.form,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.pinkMid.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: AppColor.pinkMid, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please select a date and provide your leave reason. '
                        'Leave can be requested up to 30 days in advance.',
                        style: TextStyle(
                          color: AppColor.textDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== Dropdown Leave Type =====
              DropdownButtonFormField<String>(
                initialValue: _tipeIzin,
                decoration: InputDecoration(
                  labelText: "Leave Type",
                  filled: true,
                  fillColor: AppColor.form,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColor.pinkMid,
                      width: 1.5,
                    ),
                  ),
                ),
                items: _tipeIzinOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt['value'],
                        child: Text(
                          opt['label']!,
                          style: const TextStyle(color: AppColor.textDark),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _tipeIzin = val),
                validator: (val) =>
                    val == null ? "Leave type must be selected" : null,
              ),
              const SizedBox(height: 20),

              // ===== Date Picker =====
              const Text(
                "Leave Date",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.textDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.form,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.pinkMid.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColor.textDark,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDate == null
                            ? "Select leave date"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(color: AppColor.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== Reason =====
              const Text(
                "Reason",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.textDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alasanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your leave reason...",
                  filled: true,
                  fillColor: AppColor.form,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColor.pinkMid,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Reason is required" : null,
              ),
              const SizedBox(height: 30),

              // ===== Submit Button =====
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.pinkMid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColor.pinkMid.withOpacity(0.25),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Leave",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
              const CopyRightText(),
            ],
          ),
        ),
      ),
    );
  }
}
