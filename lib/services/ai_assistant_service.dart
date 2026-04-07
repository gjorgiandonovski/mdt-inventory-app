import 'dart:convert';
import 'package:http/http.dart' as http;

import '../providers/language_provider.dart';

class AiAssistantService {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  Future<String> ask({
    required String message,
    required AppLanguage language,
  }) async {
    if (geminiApiKey.trim().isEmpty) {
      throw Exception('Missing Gemini API key.');
    }

    final prompt = language == AppLanguage.mk
        ? 'Ти си ИТ помошник за вработени во јавна институција. '
            'Помагај со вообичаени ИТ проблеми на уреди и апликации '
            '(камера, интернет, апликација замрзната, печатач, логирање, ажурирања). '
            'Одговори на македонски со јасни, кратки чекори. '
            'Ако недостасуваат информации, постави едно разјаснувачко прашање. '
            'Ако проблемот е ризичен, предложи контакт со ИТ.\n\n'
            'Корисник: $message'
        : 'You are an IT assistant for staff in a government organization. '
            'Help with common device and app issues '
            '(camera, internet, frozen app, printer, login, updates). '
            'Reply in English with clear, short steps. '
            'Ask one clarifying question if needed. '
            'If the issue is risky, suggest contacting IT.\n\n'
            'User: $message';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 400,
      }
    });

    const endpoints = [
      'https://generativelanguage.googleapis.com/v1/models',
      'https://generativelanguage.googleapis.com/v1beta/models',
    ];
    const models = [
      'gemini-2.5-flash-lite',
      'gemini-2.5-flash',
      'gemini-3-flash',
      'gemini-1.5-flash',
      'gemini-1.5-flash-8b',
      'gemini-1.0-pro',
      'gemini-pro',
    ];

    http.Response? response;
    String? lastError;

    for (final endpoint in endpoints) {
      for (final modelName in models) {
        final uri = Uri.parse(
          '$endpoint/$modelName:generateContent?key=$geminiApiKey',
        );
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        if (response.statusCode == 404 || response.statusCode == 429) {
          lastError = response.body;
          continue;
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          break;
        }
        lastError = response.body;
        break;
      }
      if (response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        break;
      }
    }

    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'AI request failed (${response?.statusCode ?? 0}): ${lastError ?? ''}',
      );
    }

    final data = jsonDecode(response.body);
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Empty AI response.');
    }
    final parts = candidates[0]?['content']?['parts'];
    if (parts is! List || parts.isEmpty) {
      throw Exception('Empty AI response.');
    }
    final reply = parts.map((part) => part['text']).join('').toString().trim();
    if (reply.isEmpty) {
      throw Exception('Empty AI response.');
    }
    return reply;
  }
}
