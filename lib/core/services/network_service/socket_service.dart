import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/local_service/preference_helper.dart';
import 'package:meal_calculation_app/features/notification/controllers/notification_controller.dart';

class SocketService extends GetxService {
  WebSocket? _webSocket;
  Timer? _reconnectTimer;
  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    connectSocket();
  }

  Future<void> connectSocket() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final token = await PreferenceHelper.getToken();
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      final url = ApiEndpoint.wsNotificationsUrl(token);
      _webSocket?.close();
      _webSocket = await WebSocket.connect(url);

      _isConnecting = false;
      _cancelReconnectTimer();

      _webSocket?.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data is Map<String, dynamic> && data['event'] == 'NOTIFICATION') {
              if (Get.isRegistered<NotificationController>()) {
                Get.find<NotificationController>().handleRealtimeEvent(data);
              }
            }
          } catch (e) {
            // Silently ignore parse errors
          }
        },
        onError: (error) {
          _scheduleReconnect();
        },
        onDone: () {
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      connectSocket();
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void disconnect() {
    _cancelReconnectTimer();
    _webSocket?.close();
    _webSocket = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
