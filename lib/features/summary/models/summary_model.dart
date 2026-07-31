class MemberSummaryModel {
  final int userId;
  final String name;
  final int totalMeals;
  final double totalCost;
  final double totalDeposits;
  final double netBalance;

  MemberSummaryModel({
    required this.userId,
    required this.name,
    required this.totalMeals,
    required this.totalCost,
    required this.totalDeposits,
    required this.netBalance,
  });

  factory MemberSummaryModel.fromJson(Map<String, dynamic> json) {
    return MemberSummaryModel(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      totalMeals: json['total_meals'] as int,
      totalCost: (json['total_cost'] as num).toDouble(),
      totalDeposits: (json['total_deposits'] as num).toDouble(),
      netBalance: (json['net_balance'] as num).toDouble(),
    );
  }
}

class MonthSummaryModel {
  final int year;
  final int month;
  final String managerName;
  final double totalExpenses;
  final int totalMeals;
  final double mealRate;
  final List<MemberSummaryModel> memberSummaries;

  MonthSummaryModel({
    required this.year,
    required this.month,
    required this.managerName,
    required this.totalExpenses,
    required this.totalMeals,
    required this.mealRate,
    required this.memberSummaries,
  });

  factory MonthSummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthSummaryModel(
      year: json['year'] as int,
      month: json['month'] as int,
      managerName: json['manager_name'] as String? ?? 'N/A',
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      totalMeals: json['total_meals'] as int,
      mealRate: (json['meal_rate'] as num).toDouble(),
      memberSummaries: (json['member_summaries'] as List<dynamic>?)
              ?.map((e) => MemberSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
