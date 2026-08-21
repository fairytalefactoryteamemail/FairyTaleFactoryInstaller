import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class StepEula extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onAcceptChanged;
  final String acceptText;
  final String eulaContent;

  const StepEula({
    super.key,
    required this.isAccepted,
    required this.onAcceptChanged,
    required this.acceptText,
    required this.eulaContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              child: Text(
                eulaContent,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: isAccepted,
          onChanged: (val) => onAcceptChanged(val ?? false),
          title: Text(
            acceptText,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}