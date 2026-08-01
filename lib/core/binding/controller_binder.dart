import 'package:get/get.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/core/services/network_service/socket_service.dart';
import 'package:meal_calculation_app/features/auth/controllers/auth_controller.dart';
import 'package:meal_calculation_app/features/notification/controllers/notification_controller.dart';
import 'package:meal_calculation_app/features/summary/controllers/summary_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SummaryController>(SummaryController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
  }
}
