import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/auth/controllers/auth_controller.dart';
import 'package:meal_calculation_app/features/manager/controllers/manager_controller.dart';
import 'package:meal_calculation_app/features/manager/models/expense_model.dart';
import 'package:meal_calculation_app/routes/app_routes.dart';

class ManageExpensesScreen extends StatelessWidget {
  const ManageExpensesScreen({super.key});

  void _showEditDialog(ExpenseModel exp, ManagerController managerController) {
    final amountController = TextEditingController(text: exp.amount.toStringAsFixed(2));
    final descController = TextEditingController(text: exp.description);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.surface,
        title: Text(
          'Edit Expense',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColor.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Amount (৳)',
                  labelStyle: const TextStyle(color: AppColor.textSecondary),
                  filled: true,
                  fillColor: AppColor.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => (val == null || double.tryParse(val.trim()) == null)
                    ? 'Enter valid amount'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                style: const TextStyle(color: AppColor.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: AppColor.textSecondary),
                  filled: true,
                  fillColor: AppColor.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Enter description'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColor.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.warningOrange),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amt = double.parse(amountController.text.trim());
                final desc = descController.text.trim();
                Get.back();
                await managerController.updateExpense(exp.id, amt, desc);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ExpenseModel exp, ManagerController managerController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.surface,
        title: Text(
          'Delete Expense?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColor.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${exp.description}" (৳${exp.amount.toStringAsFixed(2)})?',
          style: GoogleFonts.outfit(color: AppColor.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColor.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.dueRed),
            onPressed: () async {
              Get.back();
              await managerController.deleteExpense(exp.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final managerController = Get.isRegistered<ManagerController>()
        ? Get.find<ManagerController>()
        : Get.put(ManagerController());
    final authController = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      managerController.fetchExpenses();
    });

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          authController.isManager ? 'Manage Grocery Expenses' : 'Grocery Expenses Log',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.warningOrange),
            onPressed: () => managerController.fetchExpenses(),
          ),
        ],
      ),
      floatingActionButton: authController.isManager
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(AppRoutes.addExpense),
              backgroundColor: AppColor.warningOrange,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.black87),
              label: Text(
                'Add Expense',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            )
          : null,
      body: Obx(() {
        if (managerController.isLoading.value && managerController.expensesList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColor.warningOrange));
        }

        if (managerController.expensesList.isEmpty) {
          return Center(
            child: Text(
              'No grocery expenses recorded for active month.',
              style: GoogleFonts.outfit(color: AppColor.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: managerController.expensesList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final exp = managerController.expensesList[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.warningOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColor.warningOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.description,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exp.date,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${exp.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.warningOrange,
                    ),
                  ),
                  if (authController.isManager) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColor.secondary, size: 20),
                      onPressed: () => _showEditDialog(exp, managerController),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColor.dueRed, size: 20),
                      onPressed: () => _confirmDelete(exp, managerController),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
