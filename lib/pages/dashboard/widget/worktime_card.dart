import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class WorkTimeCard extends StatefulWidget {
  final String startText;
  final String endText;
  final String locationText;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool isLoading;

  const WorkTimeCard({
    super.key,
    required this.startText,
    required this.endText,
    required this.locationText,
    required this.primaryLabel,
    this.onPrimaryPressed,
    this.isLoading = false,
  });

  @override
  State<WorkTimeCard> createState() => _WorkTimeCardState();
}

class _WorkTimeCardState extends State<WorkTimeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
        boxShadow: const [
          BoxShadow(
            color: AppColor.pinkLight,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Working Time",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.pinkExtraLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.startText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.endText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColor.navy,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.locationText,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.pinkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColor.bg,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      widget.primaryLabel,
                      style: const TextStyle(
                        color: AppColor.bg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
