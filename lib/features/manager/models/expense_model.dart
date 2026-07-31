class ExpenseModel {
  final int id;
  final int monthId;
  final double amount;
  final String description;
  final String date;

  ExpenseModel({
    required this.id,
    required this.monthId,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      monthId: json['month_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}
