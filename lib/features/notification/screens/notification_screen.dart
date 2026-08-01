import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_calculation_app/core/constants/app_color.dart';
import 'package:meal_calculation_app/features/notification/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'EXPENSE':
        return Icons.shopping_bag_rounded;
      case 'DEPOSIT':
        return Icons.account_balance_wallet_rounded;
      case 'MEALS':
        return Icons.restaurant_rounded;
      case 'MANAGER':
        return Icons.supervisor_account_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'EXPENSE':
        return AppColor.warningOrange;
      case 'DEPOSIT':
        return AppColor.secondary;
      case 'MEALS':
        return AppColor.primary;
      case 'MANAGER':
        return Colors.purpleAccent;
      default:
        return AppColor.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          Obx(() {
            if (notifController.notificationsList.any((e) => !e.isRead)) {
              return TextButton.icon(
                onPressed: () => notifController.markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColor.secondary),
                label: Text(
                  'Mark all read',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifController.fetchNotifications(),
        color: AppColor.primary,
        backgroundColor: AppColor.surface,
        child: Obx(() {
          if (notifController.isLoading.value && notifController.notificationsList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            );
          }

          if (notifController.notificationsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications Yet',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time updates on expenses, deposits & meals will appear here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifController.notificationsList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = notifController.notificationsList[index];
              final typeColor = _getColorForType(notif.type);

              return InkWell(
                onTap: () {
                  if (!notif.isRead) {
                    notifController.markAsRead(notif.id);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead ? AppColor.surface : AppColor.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notif.isRead ? AppColor.cardBorder : typeColor.withValues(alpha: 0.4),
                      width: notif.isRead ? 1.0 : 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForType(notif.type),
                          color: typeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColor.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('MMM d, h:mm a').format(notif.createdAt),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColor.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
