import 'dart:io';

import 'package:installer/installer_manifest.dart' show InstallerMode;

class AppInstallationStatus {
  final bool isInstalled;
  final String? installedVersion;
  final String? installedPath;

  AppInstallationStatus({
    required this.isInstalled,
    this.installedVersion,
    this.installedPath,
  });
}

class InstallerDetectorService {
  /// بررسی وضعیت نصب برنامه در رجیستری ویندوز
  static Future<AppInstallationStatus> checkStatus(String appId) async {
    try {
      final registryKey = 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\$appId';
      
      final result = await Process.run('reg', ['query', registryKey]);
      if (result.exitCode != 0) {
        return AppInstallationStatus(isInstalled: false);
      }

      final lines = result.stdout.toString().split('\n');
      String? version;
      String? path;

      for (var line in lines) {
        if (line.contains('DisplayVersion')) {
          version = line.trim().split(RegExp(r'\s+')).last;
        }
        if (line.contains('InstallLocation')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 3) path = parts.sublist(2).join(' ');
        }
      }

      return AppInstallationStatus(
        isInstalled: true,
        installedVersion: version,
        installedPath: path,
      );
    } catch (e) {
      return AppInstallationStatus(isInstalled: false);
    }
  }

  /// مقایسه نسخه نصب‌شده با نسخه جدید
  static InstallerMode determineMode(AppInstallationStatus status, String newVersion) {
    if (!status.isInstalled) return InstallerMode.install;
    if (status.installedVersion != newVersion) return InstallerMode.update;
    return InstallerMode.repair;
  }
}