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
  });

  factory Transactionsmodel.fromJson(Map<String, dynamic> json) {
    return Transactionsmodel(
      transactionId: json['transaction_id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: json['amount'],
      transactionDate: json['transaction_date'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryType: json['category_type'],
    );
  }
}
