import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../models/language.dart';

class TranslationControls extends StatelessWidget {
  final TranslationService translationService;
  final Function(TranslationMode) onModeChanged;
  final Function(String, String) onLanguageChanged;

  const TranslationControls({
    Key? key,
    required this.translationService,
    required this.onModeChanged,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mode: '),
            ToggleButtons(
              isSelected: [
                translationService.mode == TranslationMode.speechToText,
                translationService.mode == TranslationMode.realTime,
              ],
              onPressed: (index) {
                onModeChanged(
                  index == 0
                      ? TranslationMode.speechToText
                      : TranslationMode.realTime,
                );
              },
              children: const [
                Text('Speech-to-Text'),
                Text('Real-Time Translation'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Language Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Source Language
            Column(
              children: [
                const Text('From:'),
                DropdownButton<Language>(
                  value: translationService.fromLang,
                  items: translationService
                      .getSupportedLanguages()
                      .map((Language lang) {
                    return DropdownMenuItem<Language>(
                      value: lang,
                      child: Text('${lang.name} (${lang.nativeName})'),
                    );
                  }).toList(),
                  onChanged: (Language? value) {
                    if (value != null) {
                      onLanguageChanged(
                          value.code, translationService.toLang.code);
                    }
                  },
                ),
              ],
            ),
            // Target Language
            Column(
              children: [
                const Text('To:'),
                DropdownButton<Language>(
                  value: translationService.toLang,
                  items: translationService
                      .getSupportedLanguages()
                      .map((Language lang) {
                    return DropdownMenuItem<Language>(
                      value: lang,
                      child: Text('${lang.name} (${lang.nativeName})'),
                    );
                  }).toList(),
                  onChanged: (Language? value) {
                    if (value != null) {
                      onLanguageChanged(
                          translationService.fromLang.code, value.code);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
