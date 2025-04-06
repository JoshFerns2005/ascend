import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';

class QuoteGenerator {
  final String geminiApiKey;

  QuoteGenerator({required this.geminiApiKey});

  Future<String> generateExerciseQuote() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest', // Updated model name
        apiKey: geminiApiKey,
      );

      final prompt = """
You are creating a motivational quote about exercise and fitness that will be displayed in a Flutter app. 
Follow these formatting rules:


1. GENERAL RULES:
   - Avoid markdown symbols (#, __)
   - dont use any special characters maybe quotations are allowed " ",' '
   - Keep lines under 80 characters
   - Use simple text formatting only

Create a unique, motivational quote about exercise and fitness.
Make it inspiring and specific to physical training.
Keep it under 120 characters.
Avoid overused phrases like "no pain, no gain."
Tone: Motivational and human-like.
Examples:
- "Progress is made one step at a time, even if that step feels small."
- "Every drop of sweat is a step toward becoming unstoppable."
""";

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? _getFallbackQuote();
    } catch (e) {
      print('Error generating quote: $e');
      return _getFallbackQuote();
    }
  }

  String _getFallbackQuote() {
    // Fallback quotes in case AI fails
    final fallbackQuotes = [
      "Every rep brings you closer to your goals.",
      "Strength isn't just physical—it's mental resilience.",
      "The only bad workout is the one that didn't happen.",
      "Push beyond your limits; that's where growth begins.",
      "Success isn't always big leaps—it's consistent effort.",
      "Train hard, stay humble, and let results speak for themselves.",
      "Sweat today, shine tomorrow.",
    ];
    return fallbackQuotes[Random().nextInt(fallbackQuotes.length)];
  }
}