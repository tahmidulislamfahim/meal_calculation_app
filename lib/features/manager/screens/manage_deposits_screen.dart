import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/manager/controllers/manager_controller.dart';
import 'package:meal_calculation_app/features/manager/models/deposit_model.dart';
import 'package:meal_calculation_app/routes/app_routes.dart';

class ManageDepositsScreen extends StatelessWidget {
  const ManageDepositsScreen({super.key});

  void _showEditDialog(DepositModel dep, ManagerController managerController) {
    final amountController = TextEditingController(text: dep.amount.toStringAsFixed(2));
    final selectedUserId = dep.userId.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.surface,
        title: Text(
          'Edit Deposit',
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
              Obx(
                () => DropdownButtonFormField<int>(
                  initialValue: selectedUserId.value,
                  dropdownColor: AppColor.surface,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Roommate',
                    labelStyle: const TextStyle(color: AppColor.textSecondary),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: managerController.usersList.map((user) {
                    return DropdownMenuItem<int>(
                      value: user.id,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      selectedUserId.value = val;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColor.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Deposit Amount (৳)',
                  labelStyle: const TextStyle(color: AppColor.textSecondary),
                  filled: true,
                  fillColor: AppColor.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => (val == null || double.tryParse(val.trim()) == null)
                    ? 'Enter valid amount'
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.secondary),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amt = double.parse(amountController.text.trim());
                Get.back();
                await managerController.updateDeposit(dep.id, selectedUserId.value, amt);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(DepositModel dep, ManagerController managerController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.surface,
        title: Text(
          'Delete Deposit?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColor.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete deposit of ৳${dep.amount.toStringAsFixed(2)} for ${dep.userName}?',
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
              await managerController.deleteDeposit(dep.id);
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
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          'Manage Member Deposits',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.secondary),
            onPressed: () => managerController.fetchDeposits(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addDeposit),
        backgroundColor: AppColor.secondary,
        icon: const Icon(Icons.account_balance_wallet, color: Colors.black87),
        label: Text(
          'Add Deposit',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Obx(() {
        if (managerController.isLoading.value && managerController.depositsList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColor.secondary));
        }

        if (managerController.depositsList.isEmpty) {
          return Center(
            child: Text(
              'No deposits recorded for active month.',
              style: GoogleFonts.outfit(color: AppColor.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: managerController.depositsList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final dep = managerController.depositsList[index];
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
                      color: AppColor.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_outlined, color: AppColor.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dep.userName,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dep.date,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${dep.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColor.secondary, size: 20),
                    onPressed: () => _showEditDialog(dep, managerController),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColor.dueRed, size: 20),
                    onPressed: () => _confirmDelete(dep, managerController),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
