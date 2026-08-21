import 'package:flutter/material.dart';

class AppLanguage extends ChangeNotifier {
  String _currentLang = 'fa';

  String get currentLang => _currentLang;
  bool get isRtl => _currentLang == 'fa';

  void setLanguage(String langCode) {
    _currentLang = langCode;
    notifyListeners();
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'fa': {
      'app_title': 'راهنمای نصب TaleForger',
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
      'eula_text': 'شرایط و قوانین استفاده از نرم‌افزار (EULA):\n\n۱. کلیه حقوق مادی و معنوی این نرم‌افزار محفوظ می‌باشد.\n۲. با نصب این برنامه، متغیرهای محیطی سیستم (PATH) در صورت تایید شما به‌روزرسانی خواهند شد.\n۳. این نرم‌افزار هیچ‌گونه اطلاعات شخصی یا داده‌ای از سیستم شما جمع‌آوری نمی‌کند.',
    },
    'en': {
      'app_title': 'TaleForger Setup Wizard',
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
      'eula_text': 'End User License Agreement (EULA):\n\n1. All intellectual property rights belong to the software developers.\n2. By installing, system environment variables (PATH) may be modified if opted.\n3. No personal user data or private telemetry is harvested by this installer.',
    },
    'ru': {
      'app_title': 'Мастер установки TaleForger',
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
      'eula_text': 'Лицензионное соглашение с конечным пользователем (EULA):\n\n1. Все права на интеллектуальную собственность принадлежат разработчикам.\n2. При установке системные переменные окружения (PATH) могут быть изменены по вашему выбору.\n3. Данный инсталлятор не собирает и не передает личные данные пользователей.',
    },
    'ja': {
      'app_title': 'TaleForger セットアップウィザード',
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
      'eula_text': 'エンドユーザーライセンス利用規約 (EULA):\n\n1. 本ソフトウェアに関するすべての知的財産権は開発者に帰属します。\n2. オプションを有効にした場合、システムの環境変数 (PATH) が更新されます。\n3. このインストーラーが個人情報やテレメトリデータを収集することはありません。',
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