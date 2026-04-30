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

import 'dart:async';

import 'package:asgardeo_push_authenticator/services/push_messaging_service.dart';
import 'package:flutter/services.dart';

/// Native APNS implementation of [PushMessagingService] for iOS.
///
/// Communicates with native Swift code via a [MethodChannel] and an
/// [EventChannel]. The MethodChannel (`com.wso2.authenticator/apns`) handles
/// permission requests, token retrieval, and initial notification checks. The
/// EventChannel (`com.wso2.authenticator/apns_notifications`) delivers
/// incoming notification payloads as a broadcast stream, covering both
/// foreground messages and background notification taps (via
/// `UNUserNotificationCenterDelegate.didReceive`).
class ApnsMessagingService implements PushMessagingService {
  static const _channel = MethodChannel('com.wso2.authenticator/apns');
  static const _notificationChannel =
      EventChannel('com.wso2.authenticator/apns_notifications');

  Completer<String?>? _tokenCompleter;

  /// Initialises the method call handler for token callbacks from the native
  /// side. Call once at startup before any token requests.
  void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTokenReceived') {
        final token = call.arguments as String?;
        if (token != null &&
            _tokenCompleter != null &&
            !_tokenCompleter!.isCompleted) {
          _tokenCompleter!.complete(token);
        }
      }
    });
  }

  @override
  Future<void> requestPermission() =>
      _channel.invokeMethod('requestPermission');

  @override
  Future<String?> getDeviceToken() async {
    final cached = await _channel.invokeMethod<String>('getApnsToken');
    if (cached != null) return cached;

    _tokenCompleter = Completer<String?>();
    return _tokenCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }

  @override
  Future<String?> refreshDeviceToken() => getDeviceToken();

  Stream<Map<String, dynamic>> get _notificationStream =>
      _notificationChannel.receiveBroadcastStream().map((event) {
        if (event is Map) return Map<String, dynamic>.from(event);
        return <String, dynamic>{};
      });

  @override
  void Function() listenForeground(
    void Function(Map<String, dynamic>) callback,
  ) {
    final sub = _notificationStream.listen(callback);
    return sub.cancel;
  }

  /// APNS foreground and background-tap notifications arrive on the same
  /// EventChannel stream via `UNUserNotificationCenterDelegate.didReceive`.
  /// Returns a no-op cancel to avoid registering a duplicate listener.
  @override
  void Function() listenBackgroundTap(
    void Function(Map<String, dynamic>) callback,
  ) =>
      () {};

  @override
  Future<void> checkInitialMessage(
    void Function(Map<String, dynamic>) callback,
  ) async {
    final result = await _channel
        .invokeMethod<Map<Object?, Object?>>('getInitialNotification');
    if (result != null) {
      callback(Map<String, dynamic>.from(result));
    }
  }

  /// APNS does not use a background isolate handler; always returns `null`.
  @override
  Future<Map<String, dynamic>?> pickupPendingNotification() async => null;
}
