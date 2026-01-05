import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String _apiKey = "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";
  final String _apiUrl = "https://router.huggingface.co/v1/chat/completions";

  Future<Map<String, dynamic>> analyzeEntry(String text) async {
    final bool isArabicInput = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final String targetLanguage = isArabicInput ? "Arabic" : "English";

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              "Authorization": "Bearer $_apiKey",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "model": "Qwen/Qwen2.5-7B-Instruct",
              "messages": [
                {
                  "role": "system",
                  "content":
                      """You are a highly advanced multilingual mental health analyzer.
Analyze the user's journal entry for:
1. Emotional State (Mood)
2. Accurate Valence Score (0.0 to 1.0) where:
   - 0.0 to 0.2: Extreme distress, sadness, illness, or loss.                                             
   - 0.3 to 0.4: Discomfort, frustration, or mild sadness.
   - 0.5: Neutral, reflective, or calm.
   - 0.6 to 0.8: Happiness, productivity, or satisfaction.
   - 0.9 to 1.0: Joy, excitement, or deep gratitude.

LANGUAGE RULE: The user is writing in $targetLanguage. Your response fields 'mood' and 'insight' MUST be in $targetLanguage ONLY.

Return ONLY a valid JSON object:
{"mood": "empathetic short label", "insight": "one deep caring sentence reflecting the context", "score": float}""",
                },
                {"role": "user", "content": text},
              ],
              "max_tokens": 200,
              "temperature": 0.3,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result['choices'] != null && result['choices'].isNotEmpty) {
          String content = result['choices'][0]['message']['content'];

          // Clean markdown code blocks
          content = content
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          try {
            final Map<String, dynamic> data = jsonDecode(content);
            return {
              "mood": data['mood'] ?? (isArabicInput ? "تفكير" : "Reflective"),
              "insight":
                  data['insight'] ??
                  (isArabicInput
                      ? "شكراً لمشاركتك مشاعرك."
                      : "Thank you for sharing your thoughts."),
              "score": (data['score'] ?? 0.5).toDouble(),
            };
          } catch (e) {
            return _generateFallbackResponse(text);
          }
        }
      }
      return _generateFallbackResponse(text);
    } catch (e) {
      return _generateFallbackResponse(text);
    }
  }

  Map<String, dynamic> _generateFallbackResponse(String text) {
    final lowerText = text.toLowerCase();
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);

    // Advanced Local Keywords for better curve precision even offline
    bool isVerySad =
        lowerText.contains('died') ||
        lowerText.contains('موت') ||
        lowerText.contains('وفاة');
    bool isSad =
        lowerText.contains('bad') ||
        lowerText.contains('sad') ||
        lowerText.contains('سيء') ||
        lowerText.contains('حزين') ||
        lowerText.contains('متعب') ||
        lowerText.contains('not good') ||
        lowerText.contains('مرض') ||
        lowerText.contains('ألم') ||
        lowerText.contains('تعب');
    bool isHappy =
        lowerText.contains('good') ||
        lowerText.contains('happy') ||
        lowerText.contains('سعيد') ||
        lowerText.contains('فرح') ||
        lowerText.contains('جميل') ||
        lowerText.contains('الحمد لله');

    if (isVerySad) {
      return {
        "mood": isArabic ? "حزن عميق" : "Extreme Sorrow",
        "insight": isArabic
            ? "يؤسفني هذا الخبر جداً، خذ وقتك في الحزن وكن بجانب من تحب."
            : "I am deeply sorry for your loss. Take your time to grieve and stay close to loved ones.",
        "score": 0.05,
      };
    } else if (isSad) {
      return {
        "mood": isArabic ? "يوم شاق" : "Challenging Day",
        "insight": isArabic
            ? "أشعر بصدق كلماتك، تذكر أن الأيام الصعبة ستمضي."
            : "I feel the weight of your words. Remember that tough days will pass.",
        "score": 0.2,
      };
    } else if (isHappy) {
      return {
        "mood": isArabic ? "طاقة إيجابية" : "Positive Energy",
        "insight": isArabic
            ? "رائع جداً! استثمر هذا الشعور لتقوم بشيء تحبه اليوم."
            : "Wonderful! Use this great feeling to do something you love today.",
        "score": 0.9,
      };
    }

    return {
      "mood": isArabic ? "هادئ ومراقب" : "Steady & Neutral",
      "insight": isArabic
          ? "تبدو في حالة من الهدوء والملاحظة الصادقة."
          : "You seem to be in a grounded state of observation.",
      "score": 0.5,
    };
  }
}
