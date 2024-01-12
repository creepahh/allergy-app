import 'package:flutter/material.dart';

import '../models/ProductData.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductData productData;
  final String productCategory = "Cookies, Snacks & Candy";
  final String productImage = "assets/images/profile.jpg";

  // This will come from ProductData - list of allergens present in the product

  // List of all possible allergens for display purposes
  final List<String> displayAllergens = [
    "Milk",
    "nuts",
    "Lemon",
    "soybeans",
    "Shellfish",
    "Wheat"
  ];
  ProductDetailPage({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          productData.barcode, //editiable
          style: TextStyle(color: theme.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    productImage, //editable
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productData.brands, //editable
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          productCategory, //editable
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: productData.hasAllergen
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            productData.hasAllergen
                                ? 'This product has allergen'
                                : 'This product is safe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(text: "Allergens"),
                      Tab(text: "Nutrition"),
                    ],
                  ),
                  Container(
                    height: 200, // Adjust height as needed
                    child: TabBarView(
                      children: [
                        // Allergens Tab
                        GridView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: displayAllergens.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5, // Aspect ratio for the chips
                          ),
                          itemBuilder: (context, index) {
                            String allergen = displayAllergens[index];
                            bool isPresent = productData.allergens
                                .contains(allergen); //edatable
                            return Chip(
                              avatar: CircleAvatar(
                                backgroundColor:
                                    isPresent ? Colors.red : Colors.green,
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                ),
                              ),
                              label: Text(
                                allergen,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  isPresent ? Colors.red : Colors.green,
                            );
                          },
                        ),
                        // Nutrition Tab
                        Center(child: Text('Nutrition content here')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
