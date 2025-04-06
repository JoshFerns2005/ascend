import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AINutritionService {
  final SupabaseClient supabaseClient;
  final String geminiApiKey;

  AINutritionService(
      {required this.supabaseClient, required this.geminiApiKey});

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await supabaseClient
        .from('userdetails')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  Future<void> saveNutritionPlan(
      String userId, String title, String content) async {
    // Mark all previous plans as not current
    await supabaseClient
        .from('nutrition_plans')
        .update({'is_current': false}).eq('user_id', userId);

    // Save new plan
    await supabaseClient.from('nutrition_plans').insert({
      'user_id': userId,
      'plan_title': title,
      'plan_content': content,
      'is_current': true,
    });
  }

  Future<List<Map<String, dynamic>>> getUserNutritionPlans(
      String userId) async {
    final response = await supabaseClient
        .from('nutrition_plans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response;
  }

  Future<String?> getCurrentNutritionPlan(String userId) async {
    final response = await supabaseClient
        .from('nutrition_plans')
        .select('plan_content')
        .eq('user_id', userId)
        .eq('is_current', true)
        .maybeSingle();

    return response?['plan_content'];
  }

  Future<String> generateNutritionPlan(Map<String, dynamic> userDetails) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest', // Updated model name
        apiKey: geminiApiKey,
      );

      final prompt = """
You are creating a nutrition plan that will be displayed in a Flutter app. 
Please format your response using these Flutter-specific rules:

1. FOR HEADINGS: 
   - Put heading text in ALL CAPS
   - Add a blank line before each heading
   - Example: 
     \nBREAKFAST\n

2. FOR BOLD TEXT:
   - Place text between double asterisks **like this**
   - Example: **Important note:** Drink water

3. FOR LISTS:
   - Use regular bullet points with dashes
   - Example:
     - 1 cup oatmeal
     - 1/2 cup berries

4. FOR EMPHASIS:
   - Use single asterisks *for subtle emphasis*
   
5. GENERAL RULES:
   - Avoid markdown symbols (#, __)
   - Keep lines under 80 characters
   - Use simple text formatting only
   - Put blank lines between sections
      Act as a professional nutritionist. Create a personalized 7-day nutrition plan based on:
      
      - Age: ${userDetails['age']}
      - Gender: ${userDetails['gender']}
      - Weight: ${userDetails['weight']} kg
      - Height: ${userDetails['height']} cm
      - Current Physique: ${userDetails['current_physique']}
      - Goal Physique: ${userDetails['ideal_physique']}
      
      Provide detailed meals for each day including:
      1. Breakfast, lunch, dinner, and snacks
      2. Portion sizes and nutritional info
      3. Meal timing suggestions
      4. Hydration guidance
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      print('Error generating plan: $e');
      throw Exception('Failed to generate plan: ${e.toString()}');
    }
  }
}
