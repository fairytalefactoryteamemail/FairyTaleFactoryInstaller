import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:file_picker/file_picker.dart';
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
  });

  @override
  State<StepOptions> createState() => _StepOptionsState();
}

class _StepOptionsState extends State<StepOptions> {
  late bool _addToPath;
  late bool _createShortcut;

  @override
  void initState() {
    super.initState();
    _addToPath = widget.addToPath;
    _createShortcut = widget.createShortcut;
  }

  Future<void> _pickDirectory() async {
    final String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory != null) {
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
          height: 38, // ارتفاع یکسان برای Input و دکمه
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
          value: _addToPath,
          onChanged: (val) {
            final newValue = val ?? false;
            setState(() => _addToPath = newValue);
            widget.onAddPathChanged(newValue);
          },
          title: Text(
            widget.addPathLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          value: _createShortcut,
          onChanged: (val) {
            final newValue = val ?? false;
            setState(() => _createShortcut = newValue);
            widget.onShortcutChanged(newValue);
          },
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