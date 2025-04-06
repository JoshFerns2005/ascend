import 'package:ascend/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({Key? key}) : super(key: key);

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  List<Map<String, dynamic>> nutritionPlans = [];
  String? currentPlan;
  bool isLoading = false;
  String error = '';
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final plans = await aiNutritionService.getUserNutritionPlans(userId);
      final current = await aiNutritionService.getCurrentNutritionPlan(userId);

      setState(() {
        nutritionPlans = plans;
        currentPlan = current;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load plans: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generatePlan() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final details = await aiNutritionService.getUserDetails(userId);
      final planContent =
          await aiNutritionService.generateNutritionPlan(details);

      // Save the generated plan
      final planTitle =
          '${details['ideal_physique']} Plan - ${DateTime.now().toString().substring(0, 10)}';
      await aiNutritionService.saveNutritionPlan(
          userId, planTitle, planContent);

      // Refresh the plans list
      await _loadPlans();
    } catch (e) {
      setState(() {
        error = 'Failed to generate plan: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: MediaQuery.of(context).size.width * 0.01, // Responsive stroke width
              ),
            )
          : Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Responsive padding
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: generatePlan,
                    child: Text(
                      'Generate New Plan',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                      ),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                      ),
                    ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing

                  // Current plan
                  if (currentPlan != null) ...[
                    Text(
                      'Current Plan',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Color.fromARGB(255, 0, 43, 79),
                        child: Padding(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.04, // Responsive padding
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              currentPlan!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Plan history
                  if (nutritionPlans.length > 1) ...[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing
                    Text(
                      'Previous Plans',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: nutritionPlans.length,
                        itemBuilder: (context, index) {
                          final plan = nutritionPlans[index];
                          if (plan['is_current'] == true) return Container();

                          return ListTile(
                            title: Text(
                              plan['plan_title'],
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                              ),
                            ),
                            subtitle: Text(
                              plan['created_at'].toString().substring(0, 10),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.035, // Responsive font size
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                currentPlan = plan['plan_content'];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}