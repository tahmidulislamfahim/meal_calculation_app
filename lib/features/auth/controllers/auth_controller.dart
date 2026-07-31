import 'package:get/get.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/local_service/preference_helper.dart';
import 'package:meal_calculation_app/core/services/network_service/api_client.dart';
import 'package:meal_calculation_app/features/auth/models/user_model.dart';
import 'package:meal_calculation_app/routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = Get.put(ApiClient());

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  Future<void> checkSession() async {
    final token = await PreferenceHelper.getToken();
    final role = await PreferenceHelper.getUserRole();
    if (token != null && token.isNotEmpty) {
      userRole.value = role ?? 'MEMBER';
      try {
        final res = await _apiClient.get("${ApiEndpoint.users}/me");

        currentUser.value = UserModel.fromJson(res);
        userRole.value = currentUser.value?.role ?? 'MEMBER';
        Get.offAllNamed(AppRoutes.dashboard);
      } catch (e) {
        await PreferenceHelper.clearSession();
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(ApiEndpoint.login, {
        'email': email.trim(),
        'password': password,
      });

      final token = response['access_token'] as String;
      final user = UserModel.fromJson(response['user']);

      await PreferenceHelper.saveSession(
        token: token,
        userId: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      );

      currentUser.value = user;
      userRole.value = user.role;

      Get.offAllNamed(AppRoutes.dashboard);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await PreferenceHelper.clearSession();
    currentUser.value = null;
    userRole.value = '';
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isSuperAdmin => userRole.value == 'SUPER_ADMIN';
  bool get isManager => userRole.value == 'MANAGER' || isSuperAdmin;
}
