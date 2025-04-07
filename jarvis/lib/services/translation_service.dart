import 'dart:convert';
import 'dart:io';
import '../models/language.dart';

enum TranslationMode { realTime, speechToText }

class TranslationService {
  Language fromLang = Language.supportedLanguages[0]; // Default to English
  Language toLang = Language.supportedLanguages[1]; // Default to Chinese
  TranslationMode mode = TranslationMode.speechToText;

  TranslationService();

  Future<void> initialize() async {
    // No initialization needed for LLM-based translation
  }

  void setMode(TranslationMode newMode) {
    mode = newMode;
  }

  void setLanguages(String fromCode, String toCode) {
    fromLang = Language.getLanguageByCode(fromCode);
    toLang = Language.getLanguageByCode(toCode);
  }

  Map<String, String> getLanguages() {
    return {
      "from": fromLang.code,
      "to": toLang.code,
      "fromName": fromLang.name,
      "toName": toLang.name,
    };
  }

  List<Language> getSupportedLanguages() {
    return Language.supportedLanguages;
  }

  Future<String> translate(String text) async {
    // For now, we'll use a simple placeholder for translation
    // This will be implemented later with the LLM
    return "Translated: $text";
  }

  void dispose() {
    // No cleanup needed
  }
}
