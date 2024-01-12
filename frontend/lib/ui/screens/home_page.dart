import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/plants.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/signin_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/plant_widget.dart';
import 'package:flutter_onboarding/util/ip_address.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../util/ip_address.dart';

var emaila;

class WidgetB {
  static late Function(String) setEmail = (String email) {};

  // Other WidgetB code...

  // Example function that uses the email received from SignIn
  static void someFunction(String email) {
    print("Email received in WidgetB: $email");
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    Size size = MediaQuery.of(context).size;

    // Create an async function to fetch and populate _plantList
    List<Food> _plantList = [];

    void fetchData() async {
      String userEmail = 'dummy';
      _plantList = await Food.fetchFoods(userEmail);
    }

    // Call the fetchData function
    fetchData();

    //Plants category
    List<String> _plantTypes = [
      'Recommended',
      'Indoor',
      'Outdoor',
      'Garden',
      'Supplement',
    ];

    Future<void> fetchUserAllergy(String email) async {
      String apiUrl = "http://${Globals.ipAddress}:8000/api/user_info/";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email}),
      );

      if (response.statusCode == 201) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        print("Response Object: $responseData");
      } else {
        print("Failed to register user. Status code: ${response.statusCode}");
        // Handle registration failure as needed
      }
    }

    fetchUserAllergy("niajh.edd@gmail.com");

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
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
                          hintText: 'Search Food',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      )),
                      // Icon(
                      //   Icons.mic,
                      //   color: Colors.black54.withOpacity(.6),
                      // ),
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
          //allergens avatar
          SizedBox(
            height: size.height * .1,
            child: ListView.builder(
              itemCount: _plantList.length, // Change this to your list count
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                // Your data model will be used here instead of _plantList
                return GestureDetector(
                  onTap: () {
                    // Handle the tap event
                  },
                  child: Container(
                    width: 50, // Define the size of the circle
                    height: 50, // Match the width to create a perfect circle
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape:
                          BoxShape.circle, // This makes the container circular
                      image: DecorationImage(
                        image: AssetImage(_plantList[index]
                            .imageURL), // Replace with the URL of your image
                        fit: BoxFit.cover,
                      ),
                    ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: size.height * .5,
            child: ListView.builder(
                itemCount: _plantList.length,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child:
                                    DetailPage(plantId: _plantList[index].id),
                                type: PageTransitionType.bottomToTop));
                      },
                      child: PlantWidget(index: index, plantList: _plantList));
                }),
          ),
        ],
      ),
    ));
  }
}
