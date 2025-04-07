import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyAuthController extends GetxController {
  Rx<UserCredential?> userCredential = Rx<UserCredential?>(null);

  Future<void> signInAnonymously() async {
    try {
      userCredential.value = await FirebaseAuth.instance.signInAnonymously();
      log("Successfully signed in with temporary account: ${userCredential.value?.user?.uid}");
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} ${e.message}");
      rethrow;
    } catch (e) {
      log("Unknown error during sign in: $e");
      rethrow;
    }
  }

  Future<String> fetchLlmToken() async {
    try {
      final authController = Get.find<MyAuthController>();
      final authToken =
          await authController.userCredential.value?.user?.getIdToken();

      if (authToken == null) {
        log("Error: Auth token is null");
        throw Exception("Auth token is null");
      }

      log("Fetching LLM token with auth token: ${authToken.substring(0, 10)}...");

      final response = await http.get(
        Uri.parse('https://token.one-api.bud.inc/'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          final llmToken = data['token'];
          log("Successfully retrieved LLM token: ${llmToken.substring(0, 10)}...");

          // Store the token in FlutterForegroundTask
          await FlutterForegroundTask.saveData(
              key: 'llmToken', value: llmToken);
          log("Successfully stored LLM token in FlutterForegroundTask");

          return llmToken;
        } else {
          log("Error: Response data does not contain token");
          throw Exception("Response data does not contain token");
        }
      } else {
        log("Error: Failed to fetch LLM token. Status code: ${response.statusCode}");
        log("Response body: ${response.body}");
        throw Exception(
            "Failed to fetch LLM token. Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("Error in fetchLlmToken: $e");
      rethrow;
    }
  }
}
