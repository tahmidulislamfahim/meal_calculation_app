class DepositModel {
  final int id;
  final int monthId;
  final int userId;
  final String userName;
  final double amount;
  final String date;

  DepositModel({
    required this.id,
    required this.monthId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.date,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as int,
      monthId: json['month_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String? ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String? ?? '',
    );
  }
}
