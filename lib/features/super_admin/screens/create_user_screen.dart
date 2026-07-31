import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/super_admin/controllers/super_admin_controller.dart';

class CreateUserScreen extends StatelessWidget {
  CreateUserScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _selectedRole = 'MEMBER'.obs;

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
          'Create Roommate Account',
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
                        color: AppColor.refundGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: AppColor.refundGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Super Admin Tool',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          Text(
                            'Register new roommate into mess database',
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
                  'Full Name',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Tanvir Ahmed',
                    hintStyle: const TextStyle(color: AppColor.textSecondary),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColor.refundGreen,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter name'
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Email Address',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. tanvir@mess.com',
                    hintStyle: const TextStyle(color: AppColor.textSecondary),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColor.refundGreen,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter email'
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Initial Password',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    hintStyle: const TextStyle(color: AppColor.textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.refundGreen,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be >= 6 chars'
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Assign System Role',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: _selectedRole.value,
                    dropdownColor: AppColor.surface,
                    style: const TextStyle(color: AppColor.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColor.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'MEMBER',
                        child: Text('MEMBER (General Roommate)'),
                      ),
                      DropdownMenuItem(
                        value: 'MANAGER',
                        child: Text('MANAGER (Mess Manager)'),
                      ),
                      DropdownMenuItem(
                        value: 'SUPER_ADMIN',
                        child: Text('SUPER_ADMIN (System Owner)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _selectedRole.value = val;
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: adminController.isLoading.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await adminController
                                    .createUser(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      role: _selectedRole.value,
                                    );
                                if (success) Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.refundGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: adminController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'CREATE ACCOUNT',
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
            ),
          ),
        ),
      ),
    );
  }
}
