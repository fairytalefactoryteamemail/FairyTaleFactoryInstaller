import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class StepLanguage extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onLangSelected;

  const StepLanguage({
    super.key,
    required this.currentLang,
    required this.onLangSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'fa', 'title': 'فارسی', 'sub': 'Persian'},
      {'code': 'en', 'title': 'English', 'sub': 'Global'},
      {'code': 'ru', 'title': 'Русский', 'sub': 'Russian'},
      {'code': 'ja', 'title': '日本語', 'sub': 'Japanese'},
    ];

    return Center(
      child: SizedBox(
        width: 380,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25, // کارت‌های کمی عمودی/مربعی متوازن
          ),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            final isSelected = lang['code'] == currentLang;

            return InkWell(
              onTap: () => onLangSelected(lang['code']!),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bgSurface : AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lang['code']!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang['title']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      lang['sub']!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}