import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  static const String _apiKey = "YOUR_HUGGING_FACE_TOKEN_HERE";
  static const String _primaryModel = "google/gemma-3-27b-it";
  static const String _fallbackModel = "Qwen/Qwen2.5-7B-Instruct";
  static const String _baseUrl =
      "https://router.huggingface.co/v1/chat/completions";

  Future<String> getChatResponse(List<Map<String, String>> history) async {
    return _requestChatCompletion(history, _primaryModel).then((response) {
      if (response != null) return response;
      return _requestChatCompletion(history, _fallbackModel).then(
        (altResponse) =>
            altResponse ??
            "I'm having a bit of trouble connecting to my thoughts. Can we try again?",
      );
    });
  }

  Future<String?> _requestChatCompletion(
    List<Map<String, String>> history,
    String model,
  ) async {
    try {
      final List<Map<String, String>> messages = [
        {
          "role": "system",
          "content":
              "You are Apriel, a supportive and empathetic AI companion for the MindTrack app. \n- ALWAYS respond in the same language the user uses (Arabic or English). \n- Be concise, kind, and focused on the user's feelings. \n- STRICTLY DO NOT add meta-comments or clarifications.",
        },
        ...history,
      ];

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Authorization": "Bearer $_apiKey",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "model": model,
              "messages": messages,
              "max_tokens": 500,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"].toString().trim();
      }
    } catch (e) {
      print("HF Chat Error ($model): $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> analyzeEntry(String content) async {
    final result = await _requestAnalysis(content, _primaryModel);
    if (result != null) return result;

    final fallbackResult = await _requestAnalysis(content, _fallbackModel);
    if (fallbackResult != null) return fallbackResult;

    return {
      "mood": "Reflective",
      "insight":
          "I'm processing your thoughts. Writing is a powerful way to clear your mind.",
      "score": 0.5,
    };
  }

  Future<Map<String, dynamic>?> _requestAnalysis(
    String content,
    String model,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Authorization": "Bearer $_apiKey",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "model": model,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "Analyze the journal entry. Respond ONLY in the language of the entry. Format:\nMOOD: [Title]\nINSIGHT: [One sentence advice]\nSCORE: [0-10]",
                },
                {"role": "user", "content": content},
              ],
              "max_tokens": 150,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String output = data["choices"][0]["message"]["content"];

        String mood = "Mindful Reflection";
        String insight = "Thank you for sharing your thoughts.";
        double score = 5.0;

        // Use RegExp for robust parsing regardless of formatting style
        final moodMatch = RegExp(
          r'MOOD:\s*(.*)',
          caseSensitive: false,
        ).firstMatch(output);
        final insightMatch = RegExp(
          r'INSIGHT:\s*(.*)',
          caseSensitive: false,
        ).firstMatch(output);
        final scoreMatch = RegExp(
          r'SCORE:\s*([\d.]+)',
          caseSensitive: false,
        ).firstMatch(output);

        if (moodMatch != null)
          mood = moodMatch.group(1)!.trim().replaceAll('*', '');
        if (insightMatch != null)
          insight = insightMatch.group(1)!.trim().replaceAll('*', '');
        if (scoreMatch != null)
          score = double.tryParse(scoreMatch.group(1)!) ?? 5.0;

        return {"mood": mood, "insight": insight, "score": score / 10.0};
      }
    } catch (e) {
      print("HF Analysis Error ($model): $e");
    }
    return null;
  }
}
