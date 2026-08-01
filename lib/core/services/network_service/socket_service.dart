import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:meal_calculation_app/core/api_endpoint/api_endpoint.dart';
import 'package:meal_calculation_app/core/services/local_service/preference_helper.dart';
import 'package:meal_calculation_app/features/notification/controllers/notification_controller.dart';

class SocketService extends GetxService {
  socket_io.Socket? _socket;

  @override
  void onInit() {
    super.onInit();
    connectSocket();
  }

  Future<void> connectSocket() async {
    try {
      final token = await PreferenceHelper.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[Socket.IO Client] Cannot connect: No token in SharedPreferences');
        return;
      }

      if (_socket != null && _socket!.connected) {
        debugPrint('[Socket.IO Client] Socket is already connected!');
        return;
      }

      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      final url = ApiEndpoint.socketIoBaseUrl;
      debugPrint('[Socket.IO Client] Connecting Socket.IO client to: $url');

      _socket = socket_io.io(
        url,
        socket_io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setQuery({'token': token})
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket!.onConnect((_) {
        debugPrint('[Socket.IO Client] Connected to server successfully!');
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }
      });

      _socket!.on('new_notification', (data) {
        debugPrint('[Socket.IO Client] Event new_notification: $data');
        if (data is Map && Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().handleRealtimeEvent(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('unread_count_updated', (data) {
        debugPrint('[Socket.IO Client] Event unread_count_updated: $data');
        if (data is Map && data.containsKey('unread_count')) {
          final count = data['unread_count'] as int?;
          if (count != null && Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().updateUnreadCount(count);
          }
        }
      });

      _socket!.onDisconnect((reason) {
        debugPrint('[Socket.IO Client] Disconnected from server. Reason: $reason');
      });

      _socket!.onError((err) {
        debugPrint('[Socket.IO Client] Socket error: $err');
      });

      _socket!.onConnectError((err) {
        debugPrint('[Socket.IO Client] Connect error: $err');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('[Socket.IO Client] Exception during connectSocket: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
