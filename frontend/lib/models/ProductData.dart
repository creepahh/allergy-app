class ProductData {
  final String barcode;
  final String brands;
  final List<Map<String, dynamic>> ingredients;
  final List<String> allergens;
  final bool hasAllergen;

  ProductData({
    required this.barcode,
    required this.brands,
    required this.ingredients,
    required this.allergens,
    required this.hasAllergen,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      barcode: json['barcode'] ?? '',
      brands: json['brands'] ?? '',
      ingredients: List<Map<String, dynamic>>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      hasAllergen: json['hasAllergen'] ?? false,
    );
  }
}
