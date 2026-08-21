import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  final String title;

  const CustomTitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      color: const Color(0xFF1B1C22),
      child: Row(
        children: [
          // بخش قابل درگ کردن برای جابه‌جایی پنجره
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      FluentIcons.wrench_24_regular,
                      size: 16,
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF3F4F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // دکمه Minimize
          IconButton(
            icon: const Icon(FluentIcons.subtract_24_regular, size: 14),
            color: const Color(0xFF9CA3AF),
            onPressed: () => windowManager.minimize(),
            splashRadius: 18,
          ),
          
          // دکمه Close
          IconButton(
            icon: const Icon(FluentIcons.dismiss_24_regular, size: 14),
            color: const Color(0xFF9CA3AF),
            hoverColor: const Color(0xFFE11D48),
            onPressed: () => windowManager.close(),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}