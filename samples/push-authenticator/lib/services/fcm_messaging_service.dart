// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import 'dart:convert';

import 'package:asgardeo_push_authenticator/constants/storage_keys.dart';
import 'package:asgardeo_push_authenticator/services/push_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level FCM background handler.
///
/// Runs in a separate Dart isolate when a notification arrives while the app
/// is terminated or in the background. Stores the payload in
/// [SharedPreferences] for pickup when the app next launches.
///
/// Must be a top-level function annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    StorageKeys.pendingPushNotification,
    jsonEncode(message.data),
  );
}

/// Firebase Cloud Messaging implementation of [PushMessagingService].
class FcmMessagingService implements PushMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  @override
  Future<String?> getDeviceToken() => _messaging.getToken();

  @override
  Future<String?> refreshDeviceToken() async {
    await _messaging.deleteToken();
    return _messaging.getToken();
  }

  @override
  void Function() listenForeground(
    void Function(Map<String, dynamic>) callback,
  ) {
    final sub = FirebaseMessaging.onMessage.listen((message) {
      callback({
        ...message.data,
        if (message.sentTime != null)
          'sentTime': message.sentTime!.millisecondsSinceEpoch,
      });
    });
    return sub.cancel;
  }

  @override
  void Function() listenBackgroundTap(
    void Function(Map<String, dynamic>) callback,
  ) {
    final sub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      callback({
        ...message.data,
        if (message.sentTime != null)
          'sentTime': message.sentTime!.millisecondsSinceEpoch,
      });
    });
    return sub.cancel;
  }

  @override
  Future<void> checkInitialMessage(
    void Function(Map<String, dynamic>) callback,
  ) async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      callback({
        ...message.data,
        if (message.sentTime != null)
          'sentTime': message.sentTime!.millisecondsSinceEpoch,
      });
    }
  }

  @override
  Future<Map<String, dynamic>?> pickupPendingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(StorageKeys.pendingPushNotification);
    if (pending != null) {
      await prefs.remove(StorageKeys.pendingPushNotification);
      return jsonDecode(pending) as Map<String, dynamic>;
    }
    return null;
  }
}
