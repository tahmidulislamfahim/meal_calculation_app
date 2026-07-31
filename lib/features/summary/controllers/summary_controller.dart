import 'package:get/get.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/auth/controllers/auth_controller.dart';
import 'package:meal_calculation_app/features/summary/models/summary_model.dart';

class SummaryController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final Rxn<MonthSummaryModel> summaryData = Rxn<MonthSummaryModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading.value = true;
      final res = await _apiClient.get(ApiEndpoint.summary);
      summaryData.value = MonthSummaryModel.fromJson(res);
    } catch (e) {
      // Error is displayed via ApiClient snackbar
    } finally {
      isLoading.value = false;
    }
  }

  MemberSummaryModel? get currentMemberSummary {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.id;
    if (userId == null || summaryData.value == null) return null;

    try {
      return summaryData.value!.memberSummaries.firstWhere((m) => m.userId == userId);
    } catch (_) {
      return null;
    }
  }
}
