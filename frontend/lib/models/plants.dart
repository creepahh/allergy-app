import 'dart:convert';
import 'package:http/http.dart' as http;

class Food {
  final String name;
  final List categories;
  final bool status;
  final String imageURL;
  final String userEmail;
  final int id;

  Food(
      {required this.name,
      required this.categories,
      required this.status,
      required this.imageURL,
      required this.userEmail,
      required this.id});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
        name: json['name'],
        categories: json['categories'],
        status: json['status'],
        imageURL: json['imageURL'],
        userEmail: json['userEmail'],
        id: json['id']);
  }

  static Future<List<Food>> fetchFoods(String userEmail) async {
    final url = 'http://192.168.1.9:8000/products/user/email/$userEmail';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      // Map the JSON data to the Food class
      List<Food> foods = jsonResponse.map((foodJson) {
        return Food.fromJson(foodJson);
      }).toList();

      return foods;
    } else {
      throw Exception('Failed to load foods');
    }
  }
}
