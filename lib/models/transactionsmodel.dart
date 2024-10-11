class Transactionsmodel {
  final int transactionId;
  final int userId;
  final int categoryId;
  final String amount;
  final String transactionDate;
  final String description;
  final String createdAt;
  final String updatedAt;
  final String categoryType;
  final String category;

  Transactionsmodel({
    required this.transactionId,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryType,
    required this.category,
  });

  factory Transactionsmodel.fromJson(Map<String, dynamic> json) {
    return Transactionsmodel(
      transactionId: json['transaction_id'] ?? 0, // Default value if null
      userId: json['user_id'] ?? 0, // Default value if null
      categoryId: json['category_id'] ?? 0, // Default value if null
      amount: json['amount'] ?? '', // Default to empty string if null
      transactionDate: json['transaction_date'] ?? '', // Default to empty string if null
      description: json['description'] ?? '', // Default to empty string if null
      createdAt: json['created_at'] ?? '', // Default to empty string if null
      updatedAt: json['updated_at'] ?? '', // Default to empty string if null
      categoryType: json['category_type'] ?? '', // Default to empty string if null
      category: json['category'] ?? '', // Default to empty string if null
    );
  }
}
