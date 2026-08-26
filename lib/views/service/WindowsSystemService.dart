import 'dart:io';

import 'package:path/path.dart' as p;

class WindowsSystemService {
  /// ساخت فایل BAT برای پاس دادن آرگومان‌ها به EXE اصلی
  static Future<bool> createBatchWrapper(
    String targetDirectory,
    String mainExeName,
  ) async {
    try {
      final baseName = p.basenameWithoutExtension(mainExeName);
      final batPath = p.join(targetDirectory, '$baseName.bat');

      final batContent = '''@echo off
"%~dp0$mainExeName" %*
''';

      final batFile = File(batPath);
      await batFile.writeAsString(
        batContent,
        encoding: systemEncoding,
      );

      return true;
    } catch (e) {
      print('Error creating bat wrapper: $e');
      return false;
    }
  }

  /// ساخت Shortcut روی Desktop
  static Future<bool> createDesktopShortcut({
    required String targetExePath,
    required String shortcutName,
  }) async {
    try {
      final userProfile = Platform.environment['USERPROFILE'];

      if (userProfile == null || userProfile.isEmpty) {
        return false;
      }

      final normalizedExePath =
          p.normalize(targetExePath).replaceAll('/', r'\');

      final workingDir = p.dirname(normalizedExePath);

      final desktopPath = p
          .join(
            userProfile,
            'Desktop',
            '$shortcutName.lnk',
          )
          .replaceAll('/', r'\');

      const psScript = r'''
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($env:SHORTCUT_PATH)
$Shortcut.TargetPath = $env:TARGET_PATH
$Shortcut.WorkingDirectory = $env:WORKING_DIR
$Shortcut.Save()
''';

      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          psScript,
        ],
        environment: {
          ...Platform.environment,
          'SHORTCUT_PATH': desktopPath,
          'TARGET_PATH': normalizedExePath,
          'WORKING_DIR': workingDir,
        },
      );

      return result.exitCode == 0;
    } catch (e) {
      print('Error creating desktop shortcut: $e');
      return false;
    }
  }

  /// ساخت Shortcut در Start Menu
  static Future<bool> createStartMenuShortcut({
    required String targetExePath,
    required String appName,
  }) async {
    try {
      final userProfile = Platform.environment['USERPROFILE'];

      if (userProfile == null || userProfile.isEmpty) {
        return false;
      }

      final startMenuFolder = p
          .join(
            userProfile,
            r'AppData\Roaming\Microsoft\Windows\Start Menu\Programs',
            appName,
          )
          .replaceAll('/', r'\');

      final directory = Directory(startMenuFolder);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final normalizedExePath =
          p.normalize(targetExePath).replaceAll('/', r'\');

      final workingDir = p.dirname(normalizedExePath);

      final shortcutPath = p
          .join(
            startMenuFolder,
            '$appName.lnk',
          )
          .replaceAll('/', r'\');

      const psScript = r'''
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($env:SHORTCUT_PATH)
$Shortcut.TargetPath = $env:TARGET_PATH
$Shortcut.WorkingDirectory = $env:WORKING_DIR
$Shortcut.Save()
''';

      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          psScript,
        ],
        environment: {
          ...Platform.environment,
          'SHORTCUT_PATH': shortcutPath,
          'TARGET_PATH': normalizedExePath,
          'WORKING_DIR': workingDir,
        },
      );

      return result.exitCode == 0;
    } catch (e) {
      print('Error creating start menu shortcut: $e');
      return false;
    }
  }

  /// اضافه کردن مسیر نصب به Machine PATH
  static Future<bool> addDirectoryToPath(String dirPath) async {
    try {
     final normalizedPath =
    p.normalize(dirPath).replaceAll('/', r'\').replaceFirst(
      RegExp(r'\\+$'),
      '',
    );
      const psScript = r'''
$targetDir = $env:TARGET_DIR
$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')

if ($null -eq $oldPath) {
    $oldPath = ''
}

$pathList = @(
    $oldPath -split ';' |
    ForEach-Object {
        if ($_ -and $_.Trim()) {
            $_.Trim().TrimEnd('\')
        }
    }
)

if ($pathList -notcontains $targetDir) {
    if ([string]::IsNullOrWhiteSpace($oldPath)) {
        $newPath = $targetDir
    }
    else {
        $newPath = $oldPath.TrimEnd(';') + ';' + $targetDir
    }

    [Environment]::SetEnvironmentVariable(
        'Path',
        $newPath,
        'Machine'
    )

    $HWND_BROADCAST = [IntPtr]0xffff
    $WM_SETTINGCHANGE = 0x001A
    $result = [IntPtr]::Zero

    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class NativeMethods
{
    [DllImport(
        "user32.dll",
        SetLastError = true,
        CharSet = CharSet.Auto
    )]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        string lParam,
        uint fuFlags,
        uint uTimeout,
        out IntPtr lpdwResult
    );
}
'@

    [NativeMethods]::SendMessageTimeout(
        $HWND_BROADCAST,
        $WM_SETTINGCHANGE,
        [IntPtr]::Zero,
        'Environment',
        2,
        5000,
        [ref]$result
    )
}
''';

      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          psScript,
        ],
        environment: {
          ...Platform.environment,
          'TARGET_DIR': normalizedPath,
        },
      );

      return result.exitCode == 0;
    } catch (e) {
      print('Error adding to PATH: $e');
      return false;
    }
  }
}