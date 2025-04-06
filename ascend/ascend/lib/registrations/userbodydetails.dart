import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ascend/main-screens/home-screen.dart'; // Import the HomeScreen

class UserDetailsForm extends StatefulWidget {
  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  String weight = '';
  String height = '';
  String age = '';
  String gender = '';
  List<String> genderOptions = ['male', 'female', 'other'];
  String currentPhysique = '';
  String idealPhysique = '';
  List<String> physiqueOptions = ['Lean', 'Muscular', 'Bulk'];

  Future<void> submitForm() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('No user logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    try {
      // Calculate BMI
      double weightValue = double.parse(weight);
      double heightValue =
          double.parse(height) / 100; // Convert height to meters
      double bmi = weightValue / (heightValue * heightValue);

      // Determine BMI category
      String bmiCategory = '';
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi < 24.9) {
        bmiCategory = 'Normal weight';
      } else {
        bmiCategory = 'Overweight';
      }

      // Check if a user record already exists
      final response = await supabase
          .from('userdetails')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        // If the user record exists, update it
        await supabase.from('userdetails').update({
          'weight': weight,
          'height': height,
          'age': age,
          'gender': gender,
          'current_physique': currentPhysique,
          'ideal_physique': idealPhysique,
          'bmi': bmi.toStringAsFixed(2), // Store BMI with 2 decimal points
          'bmi_category': bmiCategory,
        }).eq('user_id', user.id);

        print('User details updated successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details updated successfully!')),
        );
      } else {
        // If the user record doesn't exist, insert a new one
        await supabase.from('userdetails').insert({
          'user_id': user.id,
          'weight': weight,
          'height': height,
          'age': age,
          'gender': gender,

          'current_physique': currentPhysique,
          'ideal_physique': idealPhysique,
          'bmi': bmi.toStringAsFixed(2), // Store BMI with 2 decimal points
          'bmi_category': bmiCategory,
        });

        print('User details saved successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details saved successfully!')),
        );
      }

      // Navigate to the HomeScreen after submission
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: user.userMetadata?['full_name'] ?? 'User',
          ),
        ),
      );
    } catch (error) {
      print('Error saving user details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/loginGym.jpg'), // Add your image to the assets folder
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Translucent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Form container
          Center(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width *
                  0.04), // Responsive padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width *
                        0.03), // Responsive border radius
              ),
              width:
                  MediaQuery.of(context).size.width * 0.9, // Responsive width
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.05, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      // Weight input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // Responsive font size
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width *
                                0.03, // Responsive padding
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width *
                                    0.02), // Responsive border radius
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => weight = value ?? '',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your weight'
                            : null,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing
// Height input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // Responsive font size
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width *
                                0.03, // Responsive padding
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width *
                                    0.02), // Responsive border radius
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => height = value ?? '',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your height'
                            : null,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing
// Age input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age',
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // Responsive font size
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width *
                                0.03, // Responsive padding
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width *
                                    0.02), // Responsive border radius
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => age = value ?? '',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your age'
                            : null,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing
// Current physique
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width *
                              0.045, // Responsive font size
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.01), // Responsive spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: genderOptions.map((option) {
                          final isSelected = option == gender;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : Colors.grey, // Highlight selected button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width *
                                        0.02), // Responsive border radius
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width *
                                    0.06, // Responsive padding
                                vertical: MediaQuery.of(context).size.height *
                                    0.015, // Responsive padding
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                gender = option;
                              });
                            },
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.04, // Responsive font size
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                       SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02),
                      Text(
                        'Current Physique',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width *
                              0.045, // Responsive font size
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: physiqueOptions.map((option) {
                          final isSelected = option == currentPhysique;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : Colors.grey, // Highlight selected button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width *
                                        0.02), // Responsive border radius
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width *
                                    0.06, // Responsive padding
                                vertical: MediaQuery.of(context).size.height *
                                    0.015, // Responsive padding
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                currentPhysique = option;
                              });
                            },
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.04, // Responsive font size
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing
// Ideal physique
                      Text(
                        'Ideal Physique',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width *
                              0.045, // Responsive font size
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.01), // Responsive spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: physiqueOptions.map((option) {
                          final isSelected = option == idealPhysique;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.green
                                  : Colors.grey, // Highlight selected button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width *
                                        0.02), // Responsive border radius
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width *
                                    0.06, // Responsive padding
                                vertical: MediaQuery.of(context).size.height *
                                    0.015, // Responsive padding
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                idealPhysique = option;
                              });
                            },
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.04, // Responsive font size
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Responsive spacing
// Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              submitForm();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  0.08, // Responsive padding
                              vertical: MediaQuery.of(context).size.height *
                                  0.02, // Responsive padding
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width *
                                  0.045, // Responsive font size
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
