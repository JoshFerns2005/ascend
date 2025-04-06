import 'package:ascend/game-screens/lobby_world.dart';
import 'package:ascend/main-screens/AiNutrition.dart';
import 'package:ascend/main-screens/nutrition.dart';
import 'package:ascend/start-screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set default orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

final aiNutritionService = AINutritionService(
  supabaseClient: Supabase.instance.client,
  geminiApiKey: 'AIzaSyBmScpYT1HKfP1cuGu9l3xEj693OKZ9w04',
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
