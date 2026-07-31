import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/auth/models/user_model.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';

import 'package:meal_calculation_app/features/manager/models/expense_model.dart';
import 'package:meal_calculation_app/features/manager/models/deposit_model.dart';

class UserMealEntry {
  final int userId;
  final String userName;
  RxInt lunchCount;
  RxInt dinnerCount;

  UserMealEntry({
    required this.userId,
    required this.userName,
    int lunch = 0,
    int dinner = 0,
  })  : lunchCount = lunch.obs,
        dinnerCount = dinner.obs;
}

class ManagerController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<UserModel> usersList = <UserModel>[].obs;
  final RxList<UserMealEntry> mealEntries = <UserMealEntry>[].obs;
  final RxList<ExpenseModel> expensesList = <ExpenseModel>[].obs;
  final RxList<DepositModel> depositsList = <DepositModel>[].obs;
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
          'lunch': m['lunch_count'] ?? 0,
          'dinner': m['dinner_count'] ?? 0,
        };
      }

      final entries = list.map((user) {
        final existing = mealMap[user.id];
        return UserMealEntry(
          userId: user.id,
          userName: user.name,
          lunch: existing != null ? existing['lunch']! : 0,
          dinner: existing != null ? existing['dinner']! : 0,
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

  Future<bool> addExpense(double amount, String description, {DateTime? date}) async {
    try {
      isLoading.value = true;
      final expDate = date ?? selectedDate.value;
      await _apiClient.post(ApiEndpoint.expenses, {
        'amount': amount,
        'description': description.trim(),
        'date': DateFormat('yyyy-MM-dd').format(expDate),
      });

      Get.snackbar('Success', 'Grocery expense added successfully', backgroundColor: Colors.green, colorText: Colors.white);
      
      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      final res = await _apiClient.get(ApiEndpoint.expenses);
      final list = (res as List).map((e) => ExpenseModel.fromJson(e)).toList();
      expensesList.assignAll(list);
    } catch (e) {
      // Handled in ApiClient
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExpense(int expenseId, double amount, String description) async {
    try {
      isLoading.value = true;
      await _apiClient.put("${ApiEndpoint.expenses}/$expenseId", {
        'amount': amount,
        'description': description.trim(),
      });
      Get.snackbar('Success', 'Expense updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    try {
      isLoading.value = true;
      await _apiClient.delete("${ApiEndpoint.expenses}/$expenseId");
      Get.snackbar('Deleted', 'Expense removed', backgroundColor: Colors.orange, colorText: Colors.white);
      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      await fetchExpenses();
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
      await fetchDeposits();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDeposits() async {
    try {
      isLoading.value = true;
      final res = await _apiClient.get(ApiEndpoint.deposits);
      final list = (res as List).map((e) => DepositModel.fromJson(e)).toList();
      depositsList.assignAll(list);
    } catch (e) {
      // Handled in ApiClient
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDeposit(int depositId, int userId, double amount) async {
    try {
      isLoading.value = true;
      await _apiClient.put("${ApiEndpoint.deposits}/$depositId", {
        'user_id': userId,
        'amount': amount,
      });
      Get.snackbar('Success', 'Deposit updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      await fetchDeposits();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteDeposit(int depositId) async {
    try {
      isLoading.value = true;
      await _apiClient.delete("${ApiEndpoint.deposits}/$depositId");
      Get.snackbar('Deleted', 'Deposit removed', backgroundColor: Colors.orange, colorText: Colors.white);
      if (Get.isRegistered<SummaryController>()) {
        Get.find<SummaryController>().fetchSummary();
      }
      await fetchDeposits();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
