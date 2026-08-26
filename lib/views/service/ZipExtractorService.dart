import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p; // اضافه کردن پکیج path

class ZipExtractorService {
  static Future<bool> extractPayload({
    required String bundleName,
    required String targetPath,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      onProgress(0.1, "Creating destination directory...");
      // ۱. اطمینان از وجود پوشه اصلی مقصد
      final targetDir = Directory(targetPath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      onProgress(0.3, "Reading asset bundle...");
      // ۲. خواندن بایت‌های فایل زیپ از Assets
      final ByteData data = await rootBundle.load('assets/$bundleName');
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      onProgress(0.4, "Decompressing payload archive...");
      // ۳. دکود کردن فایل زیپ
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      if (archive.isEmpty) {
        print("Archive is empty!");
        return false;
      }

      onProgress(0.5, "Extracting files to installation directory...");
      final totalFiles = archive.length;
      int extractedCount = 0;

      // ۴. استخراج تک‌تک فایل‌ها و پوشه‌ها
      for (final archiveFile in archive) {
        // نرمال‌سازی مسیر متناسب با ویندوز
        final String normalizedPath = archiveFile.name.replaceAll('/', Platform.pathSeparator);
        final String fullPath = p.join(targetPath, normalizedPath);

        if (archiveFile.isFile) {
          final List<int> content = archiveFile.content as List<int>;
          final File outFile = File(fullPath);

          // ساخت کامل پوشه‌های والد پیش از ساخت فایل
          if (!outFile.parent.existsSync()) {
            await outFile.parent.create(recursive: true);
          }

          // نوشتن فایل
          await outFile.writeAsBytes(content, flush: true);
        } else {
          await Directory(fullPath).create(recursive: true);
        }

        extractedCount++;
        final progressVal = 0.5 + (0.4 * (extractedCount / totalFiles));
        onProgress(progressVal, "Extracting: ${archiveFile.name}");
      }

      onProgress(1.0, "Extraction complete.");
      return true;
    } catch (e, stackTrace) {
      print("Extraction error: $e");
      print("Stacktrace: $stackTrace");
      return false;
    }
  }static Future<bool> hasWritePermission(String targetPath) async {
  try {
    final testDir = Directory(targetPath);
    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
    }
    // ساخت یک فایل موقت برای تست دسترسی نوشتن
    final testFile = File('${testDir.path}\\.permission_test');
    await testFile.writeAsString('test');
    await testFile.delete(); // پاک کردن فایل تست
    return true;
  } catch (e) {
    return false; // دسترسی داده نشد!
  }
}
}