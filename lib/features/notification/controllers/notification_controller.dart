import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/notification/models/notification_model.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';
import 'package:meal_calculation_app/features/manager/controllers/manager_controller.dart';

class NotificationController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<NotificationModel> notificationsList = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final res = await _apiClient.get(ApiEndpoint.notifications);
      if (res is List) {
        final list = res.map((e) => NotificationModel.fromJson(e)).toList();
        notificationsList.assignAll(list);
      }
      await fetchUnreadCount();
    } catch (e) {
      // Handled silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await _apiClient.get(ApiEndpoint.notificationsUnreadCount);
      if (res is Map && res.containsKey('unread_count')) {
        unreadCount.value = res['unread_count'] ?? 0;
      }
    } catch (e) {
      // Handled silently
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final item = notificationsList.firstWhereOrNull((e) => e.id == id);
      if (item != null && !item.isRead) {
        item.isRead = true;
        notificationsList.refresh();
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        await _apiClient.patch("${ApiEndpoint.notifications}/$id/read");
      }
    } catch (e) {
      // Handled silently
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var item in notificationsList) {
        item.isRead = true;
      }
      notificationsList.refresh();
      unreadCount.value = 0;
      await _apiClient.patch("${ApiEndpoint.notifications}/read-all");
    } catch (e) {
      // Handled silently
    }
  }

  void handleRealtimeEvent(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final type = data['type'] ?? 'SYSTEM';

    // 1. Refresh active data controllers so UI updates instantly!
    if (Get.isRegistered<SummaryController>()) {
      Get.find<SummaryController>().fetchSummary();
    }
    if (Get.isRegistered<ManagerController>()) {
      Get.find<ManagerController>().loadUsersAndMeals();
      Get.find<ManagerController>().fetchExpenses();
      Get.find<ManagerController>().fetchDeposits();
    }

    // 2. Fetch fresh notifications from server
    fetchNotifications();

    // 3. Show instant, vibrant in-app banner/snackbar to alert the user
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.surface,
      colorText: AppColor.textPrimary,
      icon: Icon(
        type == 'EXPENSE'
            ? Icons.shopping_bag_rounded
            : type == 'DEPOSIT'
                ? Icons.account_balance_wallet_rounded
                : type == 'MEALS'
                    ? Icons.restaurant_rounded
                    : Icons.notifications_active_rounded,
        color: AppColor.primary,
      ),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      borderRadius: 14,
    );
  }
}
