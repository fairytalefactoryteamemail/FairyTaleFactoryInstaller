import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLanguage extends ChangeNotifier {
  String _currentLang = 'fa';

  String get currentLang => _currentLang;
  bool get isRtl => _currentLang == 'fa';

  AppLanguage() {
    // بارگذاری لایسنس زبان اول به محض ساخته شدن کلاس
    loadEulaForCurrentLang();
  }

  /// تغییر زبان و بارگذاری خودکار فایل لایسنس مربوطه
  Future<void> setLanguage(String langCode) async {
    _currentLang = langCode;
    notifyListeners(); // برای تغییر سریع بقیه متون برنامه
    await loadEulaForCurrentLang();
  }

  /// بارگذاری پویای فایل لایسنس از assets/licenses/eula_{lang}.txt
  Future<void> loadEulaForCurrentLang() async {
    try {
      final String path = 'assets/licenses/eula_$_currentLang.txt';
      final String loadedContent = await rootBundle.loadString(path);
      _localizedValues[_currentLang]?['eula_text'] = loadedContent;
    } catch (_) {
      try {
        final String fallbackContent = await rootBundle.loadString('assets/licenses/eula_en.txt');
        _localizedValues[_currentLang]?['eula_text'] = fallbackContent;
      } catch (_) {
        _localizedValues[_currentLang]?['eula_text'] = 'Error: EULA file not found.';
      }
    }
    // خبر دادن به UI برای جایگزین کردن متن واقعی لایسنس به جای Loading
    notifyListeners();
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'fa': {
    
      'next': 'بعدی',
      'back': 'قبلی',
      'install': 'نصب',
      'finish': 'پایان',
      'select_lang': 'زبان نصب را انتخاب کنید',
      'eula_accept': 'شرایط و قوانین استفاده را می‌پذیرم',
      'install_path': 'مسیر نصب برنامه:',
      'browse': 'انتخاب پوشه...',
      'add_path': 'افزودن مسیر برنامه به PATH سیستم',
      'desktop_shortcut': 'ایجاد آیکون روی دسکتاپ',
      'installing_title': 'در حال نصب نرم‌افزار...',
      'completed_title': 'نصب با موفقیت به پایان رسید!',
      'completed_sub': 'به خانواده TaleForger خوش آمدید.\nکوره‌ات را روشن کن و دنیایت را بساز!',
      'eula_text': 'در حال بارگذاری متن توافق‌نامه...',
    },
    'en': {
      'next': 'Next',
      'back': 'Back',
      'install': 'Install',
      'finish': 'Finish',
      'select_lang': 'Select Installation Language',
      'eula_accept': 'I accept the license agreement terms',
      'install_path': 'Destination Directory:',
      'browse': 'Browse...',
      'add_path': 'Add application executable path to System PATH',
      'desktop_shortcut': 'Create Desktop Shortcut',
      'installing_title': 'Installing Application...',
      'completed_title': 'Installation Successfully Completed!',
      'completed_sub': 'Welcome to the TaleForger family.\nLight up your forge and shape your craft!',
      'eula_text': 'Loading license agreement...',
    },
    'ru': {
      'next': 'Далее',
      'back': 'Назад',
      'install': 'Установить',
      'finish': 'Готово',
      'select_lang': 'Выберите язык установки',
      'eula_accept': 'Я принимаю условия лицензионного соглашения',
      'install_path': 'Путь к папке установки:',
      'browse': 'Обзор...',
      'add_path': 'Добавить исполняемый путь в системный PATH',
      'desktop_shortcut': 'Создать ярлык на рабочем столе',
      'installing_title': 'Выполняется установка приложения...',
      'completed_title': 'Установка успешно завершена!',
      'completed_sub': 'Добро пожаловать в семью TaleForger.\nРазожгите свою кузницу и созидайте!',
      'eula_text': 'Загрузка лицензионного соглашения...',
    },
    'ja': {
      'next': '次へ',
      'back': '戻る',
      'install': 'インストール',
      'finish': '完了',
      'select_lang': 'インストール言語を選択してください',
      'eula_accept': 'ライセンス利用規約の条件に同意します',
      'install_path': 'インストール先のフォルダ:',
      'browse': '参照...',
      'add_path': 'アプリケーションのパスをシステム PATH に追加',
      'desktop_shortcut': 'デスクトップにショートカットを作成',
      'installing_title': 'アプリケーションをインストール中...',
      'completed_title': 'インストールが正常に完了しました！',
      'completed_sub': 'TaleForger ファミリーへようこそ。\n鍛冶場に火を灯して、あなたの世界を鍛え上げましょう！',
      'eula_text': 'ライセンス規約を読み込み中...',
    },
  };

  String translate(String key) {
    final langData = _localizedValues[_currentLang];
    if (langData != null && langData.containsKey(key)) {
      return langData[key]!;
    }
    return _localizedValues['en']?[key] ?? key;
  }
}