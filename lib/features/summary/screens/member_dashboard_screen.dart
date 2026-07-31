import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/auth/controllers/auth_controller.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';
import 'package:meal_calculation_app/features/summary/models/summary_model.dart';
import 'package:meal_calculation_app/routes/app_routes.dart';

class MemberDashboardScreen extends StatelessWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final summaryController = Get.find<SummaryController>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Obx(() {
          final user = authController.currentUser.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Roommate',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      authController.userRole.value,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.secondary),
            onPressed: () => summaryController.fetchSummary(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColor.dueRed),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => summaryController.fetchSummary(),
        color: AppColor.primary,
        backgroundColor: AppColor.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (summaryController.isLoading.value &&
                summaryController.summaryData.value == null) {
              return const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: CircularProgressIndicator(color: AppColor.primary),
                ),
              );
            }

            final summary = summaryController.summaryData.value;
            final personal = summaryController.currentMemberSummary;

            final nowStr = DateFormat('MMMM yyyy').format(DateTime.now());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month & Manager Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColor.primaryDark, AppColor.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Month Context',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nowStr,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Mess Manager',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              summary?.managerName ?? 'N/A',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Live Metrics Banner
                Text(
                  'Live Mess Metrics',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Meal Rate',
                        value:
                            '৳${(summary?.mealRate ?? 0.0).toStringAsFixed(2)}',
                        icon: Icons.calculate_outlined,
                        accentColor: AppColor.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Expense',
                        value:
                            '৳${(summary?.totalExpenses ?? 0.0).toStringAsFixed(0)}',
                        icon: Icons.shopping_bag_outlined,
                        accentColor: AppColor.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Meals',
                        value: '${summary?.totalMeals ?? 0}',
                        icon: Icons.flatware_outlined,
                        accentColor: AppColor.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Personal Status Card
                Text(
                  'Your Personal Status',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (personal != null)
                  _buildPersonalStatusCard(personal, summary?.mealRate ?? 0.0)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        'No personal record for active month yet',
                        style: GoogleFonts.outfit(
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Quick Action Bar (Manager / Admin options)
                if (authController.isManager ||
                    authController.isSuperAdmin) ...[
                  Text(
                    'Management Actions',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (authController.isManager) ...[
                        _buildActionButton(
                          label: 'Daily Meal Grid',
                          icon: Icons.grid_on_rounded,
                          color: AppColor.primary,
                          onTap: () => Get.toNamed(AppRoutes.dailyMealGrid),
                        ),
                        _buildActionButton(
                          label: 'Add Expense',
                          icon: Icons.add_shopping_cart_rounded,
                          color: AppColor.warningOrange,
                          onTap: () => Get.toNamed(AppRoutes.addExpense),
                        ),
                        _buildActionButton(
                          label: 'Add Deposit',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColor.secondary,
                          onTap: () => Get.toNamed(AppRoutes.addDeposit),
                        ),
                      ],
                      if (authController.isSuperAdmin) ...[
                        _buildActionButton(
                          label: 'Create Roommate',
                          icon: Icons.person_add_alt_1_rounded,
                          color: AppColor.refundGreen,
                          onTap: () => Get.toNamed(AppRoutes.createUser),
                        ),
                        _buildActionButton(
                          label: 'Assign Manager',
                          icon: Icons.admin_panel_settings_rounded,
                          color: Colors.purpleAccent,
                          onTap: () => Get.toNamed(AppRoutes.assignManager),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Roommates Summary Table / List Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Roommates Net Balance',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Text(
                      '${summary?.memberSummaries.length ?? 0} Members',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (summary == null || summary.memberSummaries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        'No member records found',
                        style: GoogleFonts.outfit(
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: summary.memberSummaries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = summary.memberSummaries[index];
                      final isPositive = item.netBalance >= 0;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                item.userId ==
                                    authController.currentUser.value?.id
                                ? AppColor.primary.withValues(alpha: 0.5)
                                : AppColor.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColor.surfaceLight,
                              child: Text(
                                item.name.isNotEmpty
                                    ? item.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Meals: ${item.totalMeals}  •  Cost: ৳${item.totalCost.toStringAsFixed(0)}  •  Dep: ৳${item.totalDeposits.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColor.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPositive ? '+' : ''}৳${item.netBalance.toStringAsFixed(1)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isPositive
                                        ? AppColor.refundGreen
                                        : AppColor.dueRed,
                                  ),
                                ),
                                Text(
                                  isPositive ? 'Refund' : 'Due',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isPositive
                                        ? AppColor.refundGreen
                                        : AppColor.dueRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStatusCard(
    MemberSummaryModel personal,
    double mealRate,
  ) {
    final isPositive = personal.netBalance >= 0;
    final statusColor = isPositive ? AppColor.refundGreen : AppColor.dueRed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Balance Status',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}৳${personal.netBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? 'Refundable' : 'Due to Mess',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColor.cardBorder, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusDetailItem(
                label: 'Consumed Meals',
                value: '${personal.totalMeals}',
                subValue: '(incl. Guests)',
              ),
              Container(width: 1, height: 30, color: AppColor.cardBorder),
              _buildStatusDetailItem(
                label: 'Calculated Cost',
                value: '৳${personal.totalCost.toStringAsFixed(0)}',
                subValue: '@ ৳${mealRate.toStringAsFixed(1)}/m',
              ),
              Container(width: 1, height: 30, color: AppColor.cardBorder),
              _buildStatusDetailItem(
                label: 'Your Deposits',
                value: '৳${personal.totalDeposits.toStringAsFixed(0)}',
                subValue: 'Total Paid',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetailItem({
    required String label,
    required String value,
    required String subValue,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        Text(
          subValue,
          style: GoogleFonts.outfit(fontSize: 9, color: AppColor.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
