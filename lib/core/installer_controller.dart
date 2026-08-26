import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'package:installer/views/config_Loder/InstallerConfig.dart' show InstallerConfig;
import 'package:installer/views/service/WindowsSystemService.dart' show WindowsSystemService;

enum InstallStep { language, eula, options, progress, complete }
enum InstallMode { install, update, repair }

class InstallerController extends ChangeNotifier {
  InstallerConfig? config;

  InstallStep currentStep = InstallStep.language;
  InstallMode installMode = InstallMode.install;

  String installPath = '';
  bool addToPath = true;
  bool createDesktopShortcut = true;
  bool eulaAccepted = false;

  double progress = 0.0;
  String statusMessage = "";
  String currentEulaText = "";

  InstallerController() {
    _init();
  }

  Future<void> _init() async {
    config = await InstallerConfig.loadFromAssets();
    _initDefaultPath();
    await checkExistingInstallation();
    await loadLicenseForLanguage('en');
  }

  /// مقداردهی پویا برای مسیر پیش‌فرض: C:\Program Files\Publisher\DefaultSubDir
  void _initDefaultPath() {
    final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
    
    final publisher = config?.publisher ?? 'Fairy Tale Factory';
    final subDir = config?.defaultSubDir ?? 'TaleForger';

    // ترکیب نام ناشر و نام برنامه برای پوشه‌بندی استاندارد ویندوز
    installPath = p.join(programFiles, publisher, subDir);
    
    addToPath = config?.defaultAddToPath ?? true;
    createDesktopShortcut = config?.defaultCreateDesktopShortcut ?? true;
    
    notifyListeners();
  }

  /// لود کردن پویای فایل لایسنس
  Future<void> loadLicenseForLanguage(String langCode) async {
    currentEulaText = await LicenseService.loadLicense(langCode);
    notifyListeners();
  }

  Future<void> checkExistingInstallation() async {
    try {
      final appId = config?.appId ;
      final registryKey = 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\$appId';
      final result = await Process.run('reg', ['query', registryKey]);

      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        String? installedVer;

        for (var line in lines) {
          if (line.contains('DisplayVersion')) {
            installedVer = line.trim().split(RegExp(r'\s+')).last;
          }
          if (line.contains('InstallLocation')) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              installPath = parts.sublist(2).join(' ');
            }
          }
        }

        if (installedVer != null && installedVer != config?.version) {
          installMode = InstallMode.update;
        } else {
          installMode = InstallMode.repair;
        }
      } else {
        installMode = InstallMode.install;
      }
    } catch (_) {
      installMode = InstallMode.install;
    }
    notifyListeners();
  }

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

Future<void> _createUninstallerVbs() async {
  final currentConfig = config;
  if (currentConfig == null) return;

  final vbsFile = File(p.join(installPath, 'uninstall.vbs'));

  // مسیرهای لازم
  final exeName = currentConfig.mainExeName;
  final appName = currentConfig.appName;
  final appId = currentConfig.appId;
  final cleanInstallPath = installPath.replaceAll('\\', '\\\\');

  final vbsContent = '''
On Error Resume Next
Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' 1. بستن پروسه برنامه اگر در حال اجراست
WshShell.Run "taskkill /F /IM $exeName", 0, True

' 2. حذف شورتکات دسکتاپ
desktopPath = WshShell.SpecialFolders("Desktop")
shortcutFile = desktopPath & "\\$appName.lnk"
If FSO.FileExists(shortcutFile) Then
    FSO.DeleteFile shortcutFile, True
End If

' 3. پاک کردن کلید ریجستری
regKey = "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\$appId\\"
WshShell.RegDelete regKey

' 4. حذف خود پوشه نصب به صورت خودکار پس از ۲ ثانیه
cmdCommand = "cmd.exe /c timeout /t 2 /nobreak > nul & rmdir /s /q """ & "$cleanInstallPath" & """"
WshShell.Run cmdCommand, 0, False
''';

  await vbsFile.writeAsString(vbsContent, encoding: utf8);
}

Future<void> _writeUninstallRegistry() async {
  final currentConfig = config;
  if (currentConfig == null) return;

  final registryKey =
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${currentConfig.appId}';

  final uninstallVbs = p.join(installPath, 'uninstall.vbs');

  // دستور اجرای VBScript بدون باز شدن هیچ پنجره اضافی
  final uninstallCommand = 'wscript.exe "$uninstallVbs"';

  final entries = <List<String>>[
    ['DisplayName', 'REG_SZ', currentConfig.appName],
    ['DisplayVersion', 'REG_SZ', currentConfig.version],
    ['Publisher', 'REG_SZ', currentConfig.publisher],
    ['InstallLocation', 'REG_SZ', installPath],
    ['UninstallString', 'REG_SZ', uninstallCommand],
    ['DisplayIcon', 'REG_SZ', p.join(installPath, currentConfig.mainExeName)],
    ['EstimatedSize', 'REG_DWORD', currentConfig.estimatedSizeKB.toString()],
  ];

  for (final entry in entries) {
    await Process.run('reg', [
      'add',
      registryKey,
      '/v',
      entry[0],
      '/t',
      entry[1],
      '/d',
      entry[2],
      '/f',
    ]);
  }
}

Future<void> _createInstallationInfo() async {
  final currentConfig = config;

  if (currentConfig == null) {
    return;
  }

  final file = File(
    p.join(installPath, 'installer_info.json'),
  );

  final data = {
    'appId': currentConfig.appId,
    'appName': currentConfig.appName,
    'version': currentConfig.version,
  };

  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(data),
    encoding: utf8,
  );
}



  Future<bool> startInstallation() async {
    progress = 0.0;
    statusMessage = "Loading configuration...";
    notifyListeners();

    try {
      final currentConfig = config ?? await InstallerConfig.loadFromAssets();

      statusMessage = "Starting extraction...";
      notifyListeners();

      // ۱. اکسترکت فایل زیپ
      final success = await ZipExtractorService.extractPayload(
        bundleName: currentConfig.bundleFileName,
        targetPath: installPath,
        onProgress: (pVal, status) {
          progress = pVal;
          statusMessage = status;
          notifyListeners();
        },
      );

      if (success) {
        statusMessage = "Configuring system integration...";
        notifyListeners();


await _createInstallationInfo();

await _createUninstallerVbs();
   await _writeUninstallRegistry();

        // ۳. ساخت فایل BAT و افزودن به PATH
        if (addToPath) {
          statusMessage = "Adding to system PATH...";
          notifyListeners();

          await WindowsSystemService.createBatchWrapper(
            installPath,
            currentConfig.mainExeName,
          );

          await WindowsSystemService.addDirectoryToPath(installPath);
        }

        // ۴. ساخت شورت‌کات دسکتاپ
        if (createDesktopShortcut) {
          statusMessage = "Creating desktop shortcut...";
          notifyListeners();

          final exeFullPath = p.join(installPath, currentConfig.mainExeName);

          await WindowsSystemService.createDesktopShortcut(
            targetExePath: exeFullPath,
            shortcutName: currentConfig.appName,
          );
        }
        currentStep = InstallStep.complete;
        notifyListeners();
        return true;
      } else {
        statusMessage = "Installation failed!";
        notifyListeners();
        return false;
      }
    } catch (e) {
      statusMessage = "Configuration or installation error: $e";
      notifyListeners();
      return false;
    }
  }
}

// ==========================================
// سرویس‌های زیرساختی
// ==========================================

class LicenseService {
  static Future<String> loadLicense(String langCode) async {
    final String path = 'assets/licenses/eula_$langCode.txt';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      try {
        return await rootBundle.loadString('assets/licenses/eula_en.txt');
      } catch (_) {
        return 'End User License Agreement file was not found.';
      }
    }
  }
}
class ZipExtractorService {
  static Future<bool> extractPayload({
    required String bundleName,
    required String targetPath,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      // ─────────────────────────────────────────────
      // 1. Load ZIP
      // ─────────────────────────────────────────────

      onProgress(0.10, "Loading asset bundle...");

      final ByteData data =
          await rootBundle.load('assets/$bundleName');

      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // ─────────────────────────────────────────────
      // 2. Decode ZIP
      // ─────────────────────────────────────────────

      onProgress(0.20, "Decompressing payload package...");

      final Archive archive = ZipDecoder().decodeBytes(bytes);

      // ZIP نباید خالی باشد.
      if (archive.isEmpty) {
        onProgress(0.20, "Installation package is empty.");
        return false;
      }

      final int totalFiles = archive.length;
      int extractedCount = 0;

      // ─────────────────────────────────────────────
      // 3. Extract safely
      // ─────────────────────────────────────────────

      for (final archiveFile in archive) {
        final String filename = archiveFile.name;

        // بررسی مسیر قبل از نوشتن فایل
        final String? filePath = _safeExtractPath(
          targetPath,
          filename,
        );

        if (filePath == null) {
          throw StateError(
            "Unsafe archive path detected: $filename",
          );
        }

        // فعلاً اجازه Symbolic Link داخل payload را نمی‌دهیم.
        if (archiveFile.isSymbolicLink) {
          throw StateError(
            "Symbolic links are not allowed: $filename",
          );
        }

        if (archiveFile.isFile) {
          final List<int> content =
              archiveFile.content as List<int>;

          final File outFile = File(filePath);

          await outFile.create(recursive: true);
          await outFile.writeAsBytes(content);
        } else {
          await Directory(filePath).create(
            recursive: true,
          );
        }

        extractedCount++;

        final double progressVal =
            0.20 +
            (0.55 * (extractedCount / totalFiles));

        onProgress(
          progressVal,
          "Extracting: $filename",
        );
      }

      return true;
    } catch (e) {
      print("Extraction failure: $e");
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Safe ZIP Path Validation
  // ─────────────────────────────────────────────

  static String? _safeExtractPath(
    String targetPath,
    String archiveName,
  ) {
    // ZIP معمولاً از / استفاده می‌کند.
    // Backslash را هم normalize می‌کنیم.
    final String normalizedName =
        archiveName.replaceAll('\\', '/');

    // مسیر absolute ممنوع
    if (normalizedName.startsWith('/') ||
        normalizedName.startsWith('//')) {
      return null;
    }

    // مسیرهای Windows مثل C:/...
    if (RegExp(r'^[A-Za-z]:/').hasMatch(normalizedName)) {
      return null;
    }

    final List<String> parts =
        normalizedName.split('/');

    // .. ممنوع
    if (parts.any((part) => part == '..')) {
      return null;
    }

    // قسمت‌های خالی و . را حذف می‌کنیم.
    final String cleanName = parts
        .where(
          (part) =>
              part.isNotEmpty &&
              part != '.',
        )
        .join('/');

    if (cleanName.isEmpty) {
      return null;
    }

    final String root =
        p.normalize(targetPath);

    final String destination =
        p.normalize(
      p.join(root, cleanName),
    );

    // مطمئن شو مقصد داخل root باقی مانده.
    final String relative =
        p.relative(
      destination,
      from: root,
    );

    if (relative == '..' ||
        relative.startsWith(
          '..${p.separator}',
        ) ||
        p.isAbsolute(relative)) {
      return null;
    }

    return destination;
  }
}