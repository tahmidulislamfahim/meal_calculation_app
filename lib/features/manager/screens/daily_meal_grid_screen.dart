import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/auth/controllers/auth_controller.dart';
import 'package:meal_calculation_app/features/manager/controllers/manager_controller.dart';

class DailyMealGridScreen extends StatelessWidget {
  const DailyMealGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final managerController = Get.put(ManagerController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          authController.isManager ? 'Daily Meal Grid' : 'Daily Meal Logs',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.secondary),
            onPressed: () => managerController.loadUsersAndMeals(),
          ),
        ],
      ),
      body: Obx(() {
        if (managerController.isLoading.value &&
            managerController.mealEntries.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          );
        }

        return Column(
          children: [
            // Date Selection Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColor.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColor.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'EEEE, MMM d, yyyy',
                        ).format(managerController.selectedDate.value),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

                      DateTime initialDate = managerController.selectedDate.value;
                      if (initialDate.isBefore(firstDayOfMonth)) {
                        initialDate = firstDayOfMonth;
                      } else if (initialDate.isAfter(lastDayOfMonth)) {
                        initialDate = lastDayOfMonth;
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDayOfMonth,
                        lastDate: lastDayOfMonth,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColor.primary,
                                surface: AppColor.surface,
                                onSurface: AppColor.textPrimary,
                              ),
                              dialogTheme: const DialogThemeData(backgroundColor: AppColor.surface),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        managerController.setDate(picked);
                      }
                    },
                    icon: const Icon(
                      Icons.edit_calendar_rounded,
                      size: 18,
                      color: AppColor.secondary,
                    ),
                    label: Text(
                      'Change Date',
                      style: GoogleFonts.outfit(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Note on guest meals
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColor.surfaceLight.withValues(alpha: 0.5),
              child: Text(
                'Tip: Include brother/guest meals directly into member count (e.g. Member 2 + Guest 1 = 3)',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Meal Entries List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: managerController.mealEntries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = managerController.mealEntries[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColor.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColor.primary.withValues(alpha: 0.15),
                          child: Text(
                            entry.userName.isNotEmpty
                                ? entry.userName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.userName,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),

                        // Lunch Counter
                        Column(
                          children: [
                            Text(
                              'Lunch',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => _buildCounter(
                                value: entry.lunchCount.value,
                                isEditable: authController.isManager,
                                onIncrement: () => entry.lunchCount.value++,
                                onDecrement: () {
                                  if (entry.lunchCount.value > 0) {
                                    entry.lunchCount.value--;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Dinner Counter
                        Column(
                          children: [
                            Text(
                              'Dinner',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => _buildCounter(
                                value: entry.dinnerCount.value,
                                isEditable: authController.isManager,
                                onIncrement: () => entry.dinnerCount.value++,
                                onDecrement: () {
                                  if (entry.dinnerCount.value > 0) {
                                    entry.dinnerCount.value--;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Save Button (Manager Only)
            if (authController.isManager)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColor.surface,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: managerController.isLoading.value
                        ? null
                        : () => managerController.saveDailyMeals(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      'SAVE ALL DAILY MEALS',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCounter({
    required int value,
    bool isEditable = true,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditable)
            InkWell(
              onTap: onDecrement,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.remove, size: 16, color: AppColor.textPrimary),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isEditable ? 8.0 : 12.0,
              vertical: isEditable ? 0.0 : 6.0,
            ),
            child: Text(
              '$value',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
          ),
          if (isEditable)
            InkWell(
              onTap: onIncrement,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.add, size: 16, color: AppColor.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
