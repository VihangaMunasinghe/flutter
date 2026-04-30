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

/// Abstracts platform-specific push notification delivery.
///
/// Implementations deliver raw notification payloads as
/// `Map<String, dynamic>`. Callers are responsible for parsing these payloads
/// using the SDK's `AsgardeoPushAuth.instance.parsePushNotification`.
abstract class PushMessagingService {
  /// Requests notification permissions from the OS.
  Future<void> requestPermission();

  /// Returns the current device push token, or `null` if unavailable.
  Future<String?> getDeviceToken();

  /// Deletes the current token and returns a freshly issued one.
  Future<String?> refreshDeviceToken();

  /// Registers a foreground message listener.
  ///
  /// Returns a cancel function that removes the listener when called.
  void Function() listenForeground(
    void Function(Map<String, dynamic>) callback,
  );

  /// Registers a listener for notification taps when the app was backgrounded.
  ///
  /// Returns a cancel function that removes the listener when called.
  void Function() listenBackgroundTap(
    void Function(Map<String, dynamic>) callback,
  );

  /// Checks whether the app was launched from a notification tap.
  ///
  /// Invokes [callback] with the notification payload if one is found.
  Future<void> checkInitialMessage(
    void Function(Map<String, dynamic>) callback,
  );

  /// Returns and clears any pending notification stored by the background
  /// isolate handler, or `null` if none exists.
  Future<Map<String, dynamic>?> pickupPendingNotification();
}
