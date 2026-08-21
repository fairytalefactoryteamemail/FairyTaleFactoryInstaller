import 'package:fluentui_system_icons/fluentui_system_icons.dart' show FluentIcons;
import 'package:flutter/material.dart';
import 'package:installer/core/app_theme.dart' show AppColors;
import 'package:window_manager/window_manager.dart';
import '../core/i18n.dart';
import '../core/installer_controller.dart';
import 'steps/step_language.dart';
import 'steps/step_eula.dart';
import 'steps/step_options.dart';

class InstallerMainPage extends StatefulWidget {
  const InstallerMainPage({super.key});

  @override
  State<InstallerMainPage> createState() => _InstallerMainPageState();
}

class _InstallerMainPageState extends State<InstallerMainPage> {
  final _appLang = AppLanguage();
  final _controller = InstallerController();
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: _controller.installPath);
    _appLang.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF121318),
        body: Column(
          children: [
            // Custom TitleBar
            Container(
              height: 36,
              color: const Color(0xFF1B1C22),
              child: Row(
                children: [
                  Expanded(
                    child: DragToMoveArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _appLang.translate('app_title'),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            ),

            // Step Content Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildCurrentStepView(),
              ),
            ),

            // Bottom Navigation Actions
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1B1C22),
              child: Row(
                children: [
                  if (_controller.currentStep != InstallStep.language &&
                      _controller.currentStep != InstallStep.progress &&
                      _controller.currentStep != InstallStep.complete)
                    OutlinedButton(
                      onPressed: () => _controller.previousStep(),
                      child: Text(_appLang.translate('back')),
                    ),
                  const Spacer(),
                  if (_controller.currentStep != InstallStep.progress)
                    ElevatedButton(
                      onPressed: (_controller.currentStep == InstallStep.eula &&
                              !_controller.eulaAccepted)
                          ? null
                          : () {
                              if (_controller.currentStep == InstallStep.complete) {
                                windowManager.close();
                              } else {
                                _controller.nextStep();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 27, 122, 255),
                      ),
                      child: Text(
                        _controller.currentStep == InstallStep.options
                            ? _appLang.translate('install')
                            : _controller.currentStep == InstallStep.complete
                                ? _appLang.translate('finish')
                                : _appLang.translate('next'),
                                style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_controller.currentStep) {
      case InstallStep.language:
        return StepLanguage(
          currentLang: _appLang.currentLang,
          onLangSelected: (lang) => _appLang.setLanguage(lang),
        );
      case InstallStep.eula:
        return StepEula(
          isAccepted: _controller.eulaAccepted,
          onAcceptChanged: (val) => _controller.setEulaAccepted(val),
          acceptText: _appLang.translate('eula_accept'),
          eulaContent: _appLang.translate('eula_text'), // <--- این بخش مقداردهی شد
        );
      case InstallStep.options:
        return StepOptions(
          pathController: _pathController,
          addToPath: _controller.addToPath,
          createShortcut: _controller.createDesktopShortcut,
          onAddPathChanged: (val) => _controller.addToPath = val,
          onShortcutChanged: (val) => _controller.createDesktopShortcut = val,
          pathLabel: _appLang.translate('install_path'),
          addPathLabel: _appLang.translate('add_path'),
          shortcutLabel: _appLang.translate('desktop_shortcut'),
        );
      case InstallStep.progress:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_appLang.translate('installing_title'), style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _controller.progress, color: const Color(0xFF6366F1)),
            const SizedBox(height: 8),
            Text(_controller.statusMessage, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        );
    
      case InstallStep.complete:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12), // پس‌زمینه ملایم با رنگ آکسنت
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(
                  FluentIcons.checkmark_24_regular, // یا FluentIcons.checkmark_24_filled
                  size: 36,
                  color: AppColors.accent,
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                _appLang.translate('completed_title'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _appLang.translate('completed_sub'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
    
    
    }
  }
}