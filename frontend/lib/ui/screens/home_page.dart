import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/dummy.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/plant_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../util/ip_address.dart';

// Mapping of allergen names to image paths
Map<String, String> allergenToImagePath = {
  'milk': 'assets/images/fish.png',
  'soy': 'assets/images/fish.png',
  // Add more mappings here
};

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<String>> fetchAllergens(String email) async {
    String apiUrl = "http://${Globals.ipAddress}:8000/api/user_info/";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('allergens')) {
          List<dynamic> allergens = responseData['allergens'];
          List<String> allergenNames =
              allergens.map((a) => a['allergens_name'].toString()).toList();

          // Print the allergen names
          print('Allergen names: $allergenNames');

          return allergenNames;
        } else {
          print('Allergens key not found in response');
          return [];
        }
      } else {
        print('Failed to fetch allergens. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching allergens: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String userEmail = 'niajh.edd@gmail.com'; // Example email
    List<Plant> _plantList = Plant.plantList;

    bool toggleIsFavorated(bool isFavorited) {
      return !isFavorited;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: fetchAllergens(userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No allergens found'));
            }

            List<String> allergenNames = snapshot.data!;
            List<Widget> allergenImages = allergenNames.map((name) {
              String imagePath =
                  allergenToImagePath[name] ?? 'assets/images/default.png';
              return Image.asset(imagePath,
                  height: 100, width: 100); // Adjust size as needed
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.black54.withOpacity(.6),
                            ),
                            const Expanded(
                                child: TextField(
                              showCursor: false,
                              decoration: InputDecoration(
                                hintText: 'Search food',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            )),
                            Icon(
                              Icons.mic,
                              color: Colors.black54.withOpacity(.6),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * .3,
                  child: ListView.builder(
                    itemCount: allergenNames.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      String name = allergenNames[index];
                      String imagePath = allergenToImagePath[name] ??
                          'assets/images/default.png';
                      return Container(
                        width: 100, // Adjusted size
                        height: 100, // Adjusted size
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: CircleAvatar(
                          radius: 75, // Adjusted radius
                          backgroundImage: AssetImage(imagePath),
                          backgroundColor: Colors
                              .transparent, // To remove any default background color
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
                  child: const Text(
                    'Scan History',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12),
                //   height: size.height * .5,
                //   child: ListView.builder(
                //       itemCount: _plantList.length,
                //       scrollDirection: Axis.vertical,
                //       physics: const BouncingScrollPhysics(),
                //       itemBuilder: (BuildContext context, int index) {
                //         return GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //                 context,
                //                 PageTransition(
                //                     child: DetailPage(
                //                         plantId: _plantList[index].plantId),
                //                     type: PageTransitionType.bottomToTop));
                //           },
                //           child:
                //               PlantWidget(index: index, plantList: _plantList),
                //         );
                //       }),
                // ),

                // ... other widgets ...
              ],
            );
          },
        ),
      ),
    );
  }
}
