class Category {
  final int category_id; // Ensure this matches the JSON key
  final String category_name; // Ensure this matches the JSON key
  final String type;

  Category({
    required this.category_id,
    required this.category_name,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category_id: json['category_id'],
      category_name: json['category_name'],
      type: json['type'],
    );
  }
}
