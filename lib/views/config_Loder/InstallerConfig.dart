import 'dart:convert';
import 'package:flutter/services.dart';

class InstallerConfig {
  final String appId;
  final String appName;
  final String publisher;
  final String version;
  final String mainExeName;
  final String uninstallerExeName;
  final String defaultSubDir;
  final int estimatedSizeKB;
  final String bundleFileName;
  final Map<String, String> urls;
  final bool defaultAddToPath;
  final bool defaultCreateDesktopShortcut;

  InstallerConfig({
    required this.appId,
    required this.appName,
    required this.publisher,
    required this.version,
    required this.mainExeName,
    required this.uninstallerExeName,
    required this.defaultSubDir,
    required this.estimatedSizeKB,
    required this.bundleFileName,
    required this.urls,
    required this.defaultAddToPath,
    required this.defaultCreateDesktopShortcut,
  });

  factory InstallerConfig.fromJson(Map<String, dynamic> json) {
    final options = json['defaultOptions'] as Map<String, dynamic>? ?? {};
    final rawUrls = json['urls'] as Map<String, dynamic>? ?? {};

    return InstallerConfig(
      appId: json['appId'] ?? '',
      appName: json['appName'] ?? 'App',
      publisher: json['publisher'] ?? '',
      version: json['version'] ?? '1.0.0',
      mainExeName: json['mainExeName'] ?? '',
      uninstallerExeName: json['uninstallerExeName'] ?? 'uninstall.exe',
      defaultSubDir: json['defaultSubDir'] ?? 'App',
      estimatedSizeKB: json['estimatedSizeKB'] ?? 0,
      bundleFileName: json['bundleFileName'] ?? 'app_payload.zip',
      urls: Map<String, String>.from(rawUrls),
      defaultAddToPath: options['addToPath'] ?? true,
      defaultCreateDesktopShortcut: options['createDesktopShortcut'] ?? true,
    );
  }

  static Future<InstallerConfig> loadFromAssets(
      [String path = 'assets/installer_config.json']) async {
    final String response = await rootBundle.loadString(path);
    final data = json.decode(response) as Map<String, dynamic>;
    return InstallerConfig.fromJson(data);
  }
}