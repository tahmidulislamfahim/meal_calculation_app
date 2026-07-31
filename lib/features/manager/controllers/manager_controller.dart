import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/auth/models/user_model.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';

class UserMealEntry {
  final int userId;
  final String userName;
  RxInt lunchCount;
  RxInt dinnerCount;

  UserMealEntry({
    required this.userId,
    required this.userName,
    int lunch = 1,
    int dinner = 1,
  })  : lunchCount = lunch.obs,
        dinnerCount = dinner.obs;
}

class ManagerController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<UserModel> usersList = <UserModel>[].obs;
  final RxList<UserMealEntry> mealEntries = <UserMealEntry>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsersAndMeals();
  }

  Future<void> loadUsersAndMeals() async {
    try {
      isLoading.value = true;
      // 1. Fetch active users
      final usersRes = await _apiClient.get(ApiEndpoint.users);
      final list = (usersRes as List).map((e) => UserModel.fromJson(e)).toList();
      usersList.assignAll(list);

      // 2. Fetch meals for selected date
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final mealsRes = await _apiClient.get("${ApiEndpoint.meals}?target_date=$dateStr");

      final Map<int, Map<String, int>> mealMap = {};
      for (var m in (mealsRes as List)) {
        mealMap[m['user_id']] = {
          'lunch': m['lunch_count'] ?? 1,
          'dinner': m['dinner_count'] ?? 1,
        };
      }

      final entries = list.map((user) {
        final existing = mealMap[user.id];
        return UserMealEntry(
          userId: user.id,
          userName: user.name,
          lunch: existing != null ? existing['lunch']! : 1,
          dinner: existing != null ? existing['dinner']! : 1,
        );
      }).toList();

      mealEntries.assignAll(entries);
    } catch (e) {
      // Error handled in ApiClient
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDate(DateTime date) async {
    selectedDate.value = date;
    await loadUsersAndMeals();
  }

  Future<bool> saveDailyMeals() async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final payload = {
        'date': dateStr,
        'meals': mealEntries.map((e) => {
          'user_id': e.userId,
          'lunch_count': e.lunchCount.value,
          'dinner_count': e.dinnerCount.value,
        }).toList(),
      };

      await _apiClient.post(ApiEndpoint.mealsBatch, payload);
      Get.snackbar('Success', 'Daily meals updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      
      // Refresh summary
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

  Future<bool> addExpense(double amount, String description) async {
    try {
      isLoading.value = true;
      await _apiClient.post(ApiEndpoint.expenses, {
        'amount': amount,
        'description': description.trim(),
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
      });

      Get.snackbar('Success', 'Grocery expense added successfully', backgroundColor: Colors.green, colorText: Colors.white);
      
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

  Future<bool> addDeposit(int userId, double amount) async {
    try {
      isLoading.value = true;
      await _apiClient.post(ApiEndpoint.deposits, {
        'user_id': userId,
        'amount': amount,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
      });

      Get.snackbar('Success', 'Deposit added successfully', backgroundColor: Colors.green, colorText: Colors.white);

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
