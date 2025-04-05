import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/language.dart';

enum TranslationMode { realTime, speechToText }

class TranslationService {
  final String appId;
  final String apiKey;
  final String apiSecret;
  final String host = "itrans.xfyun.cn";
  final String requestUri = "/v2/its";
  Language fromLang = Language.supportedLanguages[0]; // Default to English
  Language toLang = Language.supportedLanguages[1]; // Default to Chinese
  TranslationMode mode = TranslationMode.speechToText;

  TranslationService({
    required this.appId,
    required this.apiKey,
    required this.apiSecret,
  });

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

  String _hash256(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return "SHA-256=${base64.encode(digest.bytes)}";
  }

  String _generateSignature(String digest, String date) {
    String signatureStr = "host: $host\n";
    signatureStr += "date: $date\n";
    signatureStr += "POST $requestUri HTTP/1.1\n";
    signatureStr += "digest: $digest";

    var hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    var signature = hmacSha256.convert(utf8.encode(signatureStr));
    return base64.encode(signature.bytes);
  }

  Future<String> translate(String text) async {
    if (mode == TranslationMode.realTime) {
      return await _translateWithLocalModel(text);
    } else {
      return await _translateWithAPI(text);
    }
  }

  Future<String> _translateWithAPI(String text) async {
    String date = HttpDate.format(DateTime.now().toUtc());
    String content = base64.encode(utf8.encode(text)).replaceAll("\n", "");

    Map<String, dynamic> requestBody = {
      "common": {"app_id": appId},
      "business": {"from": fromLang.code, "to": toLang.code},
      "data": {"text": content},
    };

    String body = jsonEncode(requestBody);
    String digest = _hash256(body);
    String signature = _generateSignature(digest, date);

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Host": host,
      "Date": date,
      "Digest": digest,
      "Authorization":
          'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line digest", signature="$signature"',
    };

    Uri url = Uri.https(host, requestUri);
    http.Response response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData["code"] == 0) {
        return responseData["data"]["result"]["trans_result"]["dst"];
      } else {
        throw Exception("Translation failed: ${responseData["desc"]}");
      }
    } else {
      throw Exception("HTTP Error: ${response.statusCode}");
    }
  }

  Future<String> _translateWithLocalModel(String text) async {
    // For now, we'll use a simple placeholder for local translation
    // This will be implemented later with a proper local model
    return "Translated: $text";
  }
}
