import 'package:attendlyproject_app/constant/app_color.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/avatar_placeholder.png"),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nhisha Aulia",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Junior Mobile Dev",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColor.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
