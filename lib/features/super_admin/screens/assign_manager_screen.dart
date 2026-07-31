import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/super_admin/controllers/super_admin_controller.dart';

class AssignManagerScreen extends StatelessWidget {
  AssignManagerScreen({super.key});

  final RxnInt selectedUserId = RxnInt();

  @override
  Widget build(BuildContext context) {
    final adminController = Get.isRegistered<SuperAdminController>()
        ? Get.find<SuperAdminController>()
        : Get.put(SuperAdminController());

    final currentMonthStr = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          'Assign Mess Manager',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manager Assignment',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        Text(
                          'Select roommate to manage $currentMonthStr',
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
                'Select Active Manager',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (adminController.isLoading.value &&
                    adminController.usersList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  );
                }

                return DropdownButtonFormField<int>(
                  initialValue: selectedUserId.value,
                  dropdownColor: AppColor.surface,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Choose roommate',
                    hintStyle: const TextStyle(color: AppColor.textSecondary),
                    prefixIcon: const Icon(
                      Icons.person_pin_rounded,
                      color: Colors.purpleAccent,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: adminController.usersList.map((u) {
                    return DropdownMenuItem<int>(
                      value: u.id,
                      child: Text('${u.name} (${u.role})'),
                    );
                  }).toList(),
                  onChanged: (val) => selectedUserId.value = val,
                );
              }),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        (adminController.isLoading.value ||
                            selectedUserId.value == null)
                        ? null
                        : () async {
                            final success = await adminController.assignManager(
                              selectedUserId.value!,
                            );
                            if (success) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: adminController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'CONFIRM MANAGER ASSIGNMENT',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
