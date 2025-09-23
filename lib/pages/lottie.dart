import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showLottieDialog({
  required BuildContext context,
  required String asset,
  required String message,
  required VoidCallback onClose,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                asset,
                repeat: false,
                onLoaded: (composition) {
                  // ⏱ tutup otomatis setelah durasi animasi
                  Future.delayed(composition.duration, () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                      onClose();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
