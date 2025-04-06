import 'package:ascend/start-screen/account.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // User Details
  String? weight;
  String? height;
  String? age;
  String? gender;
  String? currentPhysique;
  String? idealPhysique;
  String? bmi;
  String? bmi_category;

  bool isEditing = false;

  // Fetch user details from the database
  Future<void> fetchUserDetails() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('userdetails')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (response != null && response is Map<String, dynamic>) {
          setState(() {
            weight = response['weight']?.toString();
            height = response['height']?.toString();
            age = response['age']?.toString();
            gender = response['gender']?.toString();

            currentPhysique = response['current_physique']?.toString();
            idealPhysique = response['ideal_physique']?.toString();
            bmi = response['bmi']?.toString();
            bmi_category = response['bmi_category']?.toString();
          });
        } else {
          setState(() {
            weight = null;
            height = null;
            age = null;
            gender = null;
            currentPhysique = null;
            idealPhysique = null;
            bmi = null;
            bmi_category = null;
          });
        }
      } catch (error) {
        print('Error fetching user details: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details.')),
        );
      }
    } else {
      print('No user logged in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in.')),
      );
    }
  }

  // Update user details in the database
  // Update user details in the database
  Future<void> updateUserDetails() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Delete existing data for the user
        await supabase.from('userdetails').delete().eq('user_id', user.id);

        // Insert new data
        await supabase.from('userdetails').insert({
          'user_id': user.id,
          'weight': weight,
          'height': height,
          'age': age,
          'gender': gender,
          'current_physique': currentPhysique,
          'ideal_physique': idealPhysique,
          'bmi': bmi,
          'bmi_category': bmi_category,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details updated successfully!')),
        );

        setState(() {
          isEditing = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating details: $error')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final email = user?.email;

    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      body: user == null
          ? Center(
              child: Text(
                'No user data available. Please log in.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width *
                      0.045, // Responsive font size
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width *
                  0.04), // Responsive padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.05), // Responsive spacing
                  // Profile Picture
                  if (profileImageUrl != null)
                    ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        width: MediaQuery.of(context).size.width *
                            0.3, // Responsive width
                        height: MediaQuery.of(context).size.width *
                            0.3, // Responsive height
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // Responsive spacing
                  // Full Name
                  Text(
                    fullName ?? 'Unknown Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width *
                          0.08, // Responsive font size
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.01), // Responsive spacing
                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width *
                            0.06, // Responsive icon size
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.02), // Responsive spacing
                      Text(
                        email ?? 'Unknown Email',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.04, // Responsive font size
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.04), // User Details
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Responsive width
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width *
                        0.04), // Responsive padding
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 43, 79),
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width *
                              0.03), // Responsive border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: MediaQuery.of(context).size.width *
                              0.02, // Responsive blur radius
                        ),
                      ],
                    ),
                    child: isEditing
                        ? Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Edit Your Details',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.055, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02), // Responsive spacing
                                // Weight input
                                TextFormField(
                                  initialValue: weight,
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02), // Responsive border radius
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03, // Responsive padding
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => weight = value,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your weight'
                                          : null,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02), // Responsive spacing
                                // Height input
                                TextFormField(
                                  initialValue: height,
                                  decoration: InputDecoration(
                                    labelText: 'Height (cm)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02), // Responsive border radius
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03, // Responsive padding
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => height = value,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your height'
                                          : null,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02), // Responsive spacing
                                // Age input
                                TextFormField(
                                  initialValue: age,
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02), // Responsive border radius
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03, // Responsive padding
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => age = value,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your age'
                                          : null,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02), // Current Physique Dropdown
                                DropdownButtonFormField<String>(
                                  value: currentPhysique,
                                  decoration: InputDecoration(
                                    labelText: 'Current Physique',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02), // Responsive border radius
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03, // Responsive padding
                                    ),
                                  ),
                                  items: ['Lean', 'Muscular', 'Bulk']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04, // Responsive font size
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      currentPhysique = value ?? '',
                                  validator: (value) => value == null ||
                                          value.isEmpty
                                      ? 'Please select your current physique'
                                      : null,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02), // Responsive spacing
// Ideal Physique Dropdown
                                DropdownButtonFormField<String>(
                                  value: idealPhysique,
                                  decoration: InputDecoration(
                                    labelText: 'Ideal Physique',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02), // Responsive border radius
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03, // Responsive padding
                                    ),
                                  ),
                                  items: ['Lean', 'Muscular', 'Bulk']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04, // Responsive font size
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      idealPhysique = value ?? '',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please select your ideal physique'
                                          : null,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03), // Responsive spacing
// Save and Cancel Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          updateUserDetails();
                                        }
                                      },
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04, // Responsive font size
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.08, // Responsive padding
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.015, // Responsive padding
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing = false;
                                        });
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04, // Responsive font size
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.08, // Responsive padding
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.015, // Responsive padding
                                        ),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weight: $weight kg',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Height: $height cm',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Age: $age',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Gender: $gender',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Current Physique: $currentPhysique',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Ideal Physique: $idealPhysique',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'BMI: $bmi',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                'Category: $bmi_category',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                  child: Text('Edit Details'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 32),
                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      await supabase.auth.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(),
                        ),
                      );
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
