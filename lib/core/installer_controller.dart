import 'package:flutter/material.dart';

enum InstallStep { language, eula, options, progress, complete }

class InstallerController extends ChangeNotifier {
  InstallStep currentStep = InstallStep.language;

  // کانفیگ‌های نصب
  String installPath = r"C:\Program Files\TaleForger";
  bool addToPath = true;
  bool createDesktopShortcut = true;
  bool eulaAccepted = false;

  // وضعیت پیشرفت
  double progress = 0.0;
  String statusMessage = "";

  void goToStep(InstallStep step) {
    currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    switch (currentStep) {
      case InstallStep.language:
        currentStep = InstallStep.eula;
        break;
      case InstallStep.eula:
        if (eulaAccepted) currentStep = InstallStep.options;
        break;
      case InstallStep.options:
        currentStep = InstallStep.progress;
        startInstallation();
        break;
      case InstallStep.progress:
        currentStep = InstallStep.complete;
        break;
      case InstallStep.complete:
        break;
    }
    notifyListeners();
  }

  void previousStep() {
    switch (currentStep) {
      case InstallStep.eula:
        currentStep = InstallStep.language;
        break;
      case InstallStep.options:
        currentStep = InstallStep.eula;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void setEulaAccepted(bool value) {
    eulaAccepted = value;
    notifyListeners();
  }

  Future<void> startInstallation() async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      progress = i / 100;
      if (i == 30) statusMessage = "Extracting core assets...";
      if (i == 70) statusMessage = "Updating System PATH...";
      if (i == 90) statusMessage = "Creating shortcuts...";
      notifyListeners();
    }
    currentStep = InstallStep.complete;
    notifyListeners();
  }
}