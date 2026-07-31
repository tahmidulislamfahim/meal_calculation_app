import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/manager/controllers/manager_controller.dart';

class AddDepositScreen extends StatelessWidget {
  AddDepositScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _selectedUserId = RxnInt();

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
          'Log Roommate Deposit',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.cardBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColor.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Deposit',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          Text(
                            'Record money paid by roommate into mess pool',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Roommate',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedUserId.value,
                    dropdownColor: AppColor.surface,
                    style: const TextStyle(color: AppColor.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Choose member',
                      hintStyle: const TextStyle(color: AppColor.textSecondary),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColor.secondary,
                      ),
                      filled: true,
                      fillColor: AppColor.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: managerController.usersList.map((user) {
                      return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      _selectedUserId.value = val;
                    },
                    validator: (val) =>
                        val == null ? 'Please select a roommate' : null,
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'Deposit Amount (৳)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. 2000.00',
                    hintStyle: const TextStyle(color: AppColor.textSecondary),
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: AppColor.secondary,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter deposit amount';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Enter a valid decimal number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: managerController.isLoading.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedUserId.value != null) {
                                final amt = double.parse(
                                  _amountController.text.trim(),
                                );
                                final success = await managerController
                                    .addDeposit(_selectedUserId.value!, amt);
                                if (success) {
                                  Get.back();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: managerController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'RECORD DEPOSIT',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
