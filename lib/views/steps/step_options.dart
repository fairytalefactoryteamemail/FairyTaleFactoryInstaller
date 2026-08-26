import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/app_theme.dart';

class StepOptions extends StatefulWidget {
  final TextEditingController pathController;
  final bool addToPath;
  final bool createShortcut;
  final ValueChanged<bool> onAddPathChanged;
  final ValueChanged<bool> onShortcutChanged;
  final String pathLabel;
  final String addPathLabel;
  final String shortcutLabel;
  final String defaultSubDir; // دریافت نام پوشه از کانفیگ

  const StepOptions({
    super.key,
    required this.pathController,
    required this.addToPath,
    required this.createShortcut,
    required this.onAddPathChanged,
    required this.onShortcutChanged,
    required this.pathLabel,
    required this.addPathLabel,
    required this.shortcutLabel,
    required this.defaultSubDir,
  });

  @override
  State<StepOptions> createState() => _StepOptionsState();
}

class _StepOptionsState extends State<StepOptions> {
  @override
  void initState() {
    super.initState();
    // مقداردهی پویای مسیر نصب در صورت خالی بودن کنترلر
    if (widget.pathController.text.trim().isEmpty) {
      final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
      widget.pathController.text = p.join(programFiles, widget.defaultSubDir);
    }
  }

  Future<void> _pickDirectory() async {
    final String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory != null && selectedDirectory.trim().isNotEmpty) {
      widget.pathController.text = selectedDirectory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.pathLabel,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.pathController,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.bgSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                height: 38,
                child: IconButton(
                  onPressed: _pickDirectory,
                  icon: const Icon(FluentIcons.folder_open_16_regular, size: 16),
                  color: AppColors.textPrimary,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bgSurface,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: widget.addToPath,
          onChanged: (val) => widget.onAddPathChanged(val ?? false),
          title: Text(
            widget.addPathLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          value: widget.createShortcut,
          onChanged: (val) => widget.onShortcutChanged(val ?? false),
          title: Text(
            widget.shortcutLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }
}