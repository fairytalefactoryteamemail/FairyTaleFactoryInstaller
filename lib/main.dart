import 'dart:io' show Platform, Process, exit;

import 'package:flutter/material.dart';
import 'package:installer/views/config_Loder/InstallerConfig.dart' show InstallerConfig;
import 'package:window_manager/window_manager.dart';

import 'core/app_theme.dart';
import 'views/installer_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────
  // Administrator Check
  // ─────────────────────────────────────────────

  if (Platform.isWindows && !(await _isAdmin())) {
    await _elevateToAdmin();
    return;
  }

  // ─────────────────────────────────────────────
  // Window Manager
  // ─────────────────────────────────────────────

  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    size: Size(850, 550),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Fairy Tale Factory Setup Wizard',
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.setResizable(false);
      await windowManager.setMaximizable(false);

      await windowManager.show();
      await windowManager.focus();
    },
  );
final config = await InstallerConfig.loadFromAssets();

  runApp(CustomInstallerApp(config: config,));
}

// ─────────────────────────────────────────────
// Administrator Detection
// ─────────────────────────────────────────────

Future<bool> _isAdmin() async {
  try {
    final result = await Process.run(
      'net',
      ['session'],
      runInShell: true,
    );

    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

// ─────────────────────────────────────────────
// Request Administrator
// ─────────────────────────────────────────────

Future<void> _elevateToAdmin() async {
  final exePath = Platform.resolvedExecutable;

  final result = await Process.run(
    'powershell.exe',
    [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      'Start-Process -FilePath "$exePath" -Verb RunAs',
    ],
    runInShell: true,
  );

  // اگر PowerShell در اجرای UAC مشکل داشته باشد
  // یا دستور اجرا نشود، برنامه فعلی بسته می‌شود.
  if (result.exitCode != 0) {
    exit(1);
  }

  // نسخه بدون دسترسی را می‌بندیم.
  exit(0);
}

// ─────────────────────────────────────────────
// Application
// ─────────────────────────────────────────────
class CustomInstallerApp extends StatelessWidget {
  final InstallerConfig config;

  const CustomInstallerApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${config.appName} Setup Wizard',
      theme: AppTheme.darkTheme,
      home: const InstallerMainPage(),
    );
  }
}