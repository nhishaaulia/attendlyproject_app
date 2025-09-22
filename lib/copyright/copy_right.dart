import 'package:attendlyproject_app/utils/app_color.dart';
import 'package:flutter/material.dart';

class CopyRightText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CopyRightText({
    super.key,
    this.text = '© 2025 Attendly. Nhisha Aulia.',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style:
            style ??
            Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColor.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
