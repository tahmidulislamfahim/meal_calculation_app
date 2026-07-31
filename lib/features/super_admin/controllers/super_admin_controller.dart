import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/auth/models/user_model.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';

class SuperAdminController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<UserModel> usersList = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final res = await _apiClient.get(ApiEndpoint.users);
      final list = (res as List).map((e) => UserModel.fromJson(e)).toList();
      usersList.assignAll(list);
    } catch (e) {
      // Error in ApiClient
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      await _apiClient.post(ApiEndpoint.users, {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      });

      Get.snackbar(
        'Success',
        'Roommate user created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchUsers();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> assignManager(int userId, {int? year, int? month}) async {
    try {
      isLoading.value = true;
      await _apiClient.post(ApiEndpoint.assignManager, {
        'user_id': userId,
        'year': ?year,
        'month': ?month,
      });

      Get.snackbar(
        'Success',
        'Mess Manager assigned successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchUsers();

      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
