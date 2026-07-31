import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/auth/models/user_model.dart';
import 'package:meal_calculation_app/features/super_admin/controllers/super_admin_controller.dart';
import 'package:meal_calculation_app/routes/app_routes.dart';

class ManageRoommatesScreen extends StatelessWidget {
  const ManageRoommatesScreen({super.key});

  void _confirmDeleteUser(UserModel user, SuperAdminController adminController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.surface,
        title: Text(
          'Delete Roommate?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${user.name}"? This will permanently remove their account, meals, and deposit records.',
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
              await adminController.deleteUser(user.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Get.isRegistered<SuperAdminController>()
        ? Get.find<SuperAdminController>()
        : Get.put(SuperAdminController());
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          'Manage Roommates',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.refundGreen),
            onPressed: () => adminController.fetchUsers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createUser),
        backgroundColor: AppColor.refundGreen,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          'Create Roommate',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (adminController.isLoading.value && adminController.usersList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColor.refundGreen));
        }

        if (adminController.usersList.isEmpty) {
          return Center(
            child: Text(
              'No roommates registered yet.',
              style: GoogleFonts.outfit(color: AppColor.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: adminController.usersList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final user = adminController.usersList[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColor.surfaceLight,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
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
                          user.name,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.email}  •  ${user.role}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColor.dueRed, size: 22),
                    onPressed: () => _confirmDeleteUser(user, adminController),
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
