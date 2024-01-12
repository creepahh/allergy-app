import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../root_page.dart';

class Allergy {
  String name;
  String imageAsset;
  bool isSelected;

  Allergy({
    required this.name,
    required this.imageAsset,
    this.isSelected = false,
  });
}

class AllergySelectionPage extends StatefulWidget {
  @override
  _AllergySelectionPageState createState() => _AllergySelectionPageState();
}

class _AllergySelectionPageState extends State<AllergySelectionPage> {
  // Your list of allergies
  List<Allergy> allergies = [
    Allergy(name: 'Eggs', imageAsset: 'assets/images/egg.png'),
    Allergy(name: 'Fish', imageAsset: 'assets/images/fish.png'),
    Allergy(name: 'Gluten', imageAsset: 'assets/images/gluten.png'),
    // Add other allergies here...
  ];
  List<Allergy> selectedAllergies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      // Include other widgets if necessary
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Set allergy profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose allergies restrictions',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: allergies.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              allergies[index].isSelected =
                                  !allergies[index].isSelected;
                              if (allergies[index].isSelected) {
                                selectedAllergies.add(allergies[index]);
                              } else {
                                selectedAllergies.remove(allergies[index]);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: allergies[index].isSelected
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ClipOval(
                                  child: Image.asset(
                                    allergies[index].imageAsset,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(allergies[index].name),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: const Text('Apply'),
                        onPressed: () async {
                          const apiUrl =
                              "http://192.168.1.9:8000/api/user_allergens/";

                          final response = await http.post(
                            Uri.parse(apiUrl),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(selectedAllergies
                                .map((allergy) => allergy.name)
                                .toList()),
                          );

                          if (response.statusCode == 201) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RootPage(), // Replace with the actual new page
                              ),
                            );
                          } else {
                            print(
                                "Failed to apply allergies. Status code: ${response.statusCode}");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
