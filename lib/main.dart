import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app_theme.dart';
import 'views/installer_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه مدیریت پنجره و ویندوز
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    size: Size(850, 550),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // مخفی‌سازی نوار عنوان نیتیو ویندوز
    title: "TaleForger Setup Wizard",
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // قفل کردن کامل ابعاد و غیرفعال کردن تغییر سایز
    await windowManager.setResizable(false); 
    // خاموش کردن دکمه Maximize
    await windowManager.setMaximizable(false); 

    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const CustomInstallerApp());
}

class CustomInstallerApp extends StatelessWidget {
  const CustomInstallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaleForger Setup Wizard',
      theme: AppTheme.darkTheme,
      home: const InstallerMainPage(),
    );
  }
}