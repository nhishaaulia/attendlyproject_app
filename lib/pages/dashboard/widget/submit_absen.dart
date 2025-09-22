import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class SubmitAbsenWidget extends StatelessWidget {
  final VoidCallback onMapTap;

  const SubmitAbsenWidget({super.key, required this.onMapTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFE9EDF2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Kiri: ikon kalender + teks
            const Icon(
              Icons.calendar_month,
              size: 20,
              color: AppColor.textDark,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Take attendance',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.textDark,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Kanan: tombol Submit
            _SubmitButton(
              onPressed: () {
                onMapTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.pinkMid,
          foregroundColor: AppColor.form,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
