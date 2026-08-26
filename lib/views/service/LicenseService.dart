import 'package:flutter/services.dart' show rootBundle;

class LicenseService {
  /// بارگذاری متن لایسنس بر اساس کد زبان (مثلاً en, fa, de, ru)
  static Future<String> loadLicense(String languageCode) async {
    try {
      final String path = 'assets/licenses/eula_$languageCode.txt';
      return await rootBundle.loadString(path);
    } catch (_) {
      // در صورت یافت نشدن فایل زبان درخواستی، لایسنس انگلیسی بارگذاری می‌شود
      try {
        return await rootBundle.loadString('assets/licenses/eula_en.txt');
      } catch (_) {
        return 'End User License Agreement not found.';
      }
    }
  }
}