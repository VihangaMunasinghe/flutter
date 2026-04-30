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

import 'dart:io';

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/providers/account_provider.dart';
import 'package:asgardeo_push_authenticator/services/messaging_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory cache of in-flight push authentication requests, keyed by pushId.
///
/// All persistent operations (registration, history, key management) are
/// delegated to [AsgardeoPushAuth.instance].
class PushAuthNotifier extends Notifier<Map<String, PushAuthRequest>> {
  @override
  Map<String, PushAuthRequest> build() => {};

  // ─── Cache management ─────────────────────────────────────────────

  /// Adds a [request] to the in-memory cache.
  void addToCache(PushAuthRequest request) {
    state = {...state, request.pushId: request};
  }

  /// Removes the request identified by [pushId] from the cache.
  void removeFromCache(String pushId) {
    final updated = Map<String, PushAuthRequest>.from(state)..remove(pushId);
    state = updated;
  }

  // ─── Device registration ──────────────────────────────────────────

  /// Registers a push device using a raw QR code JSON [qrCodeJson].
  ///
  /// Returns the local account ID of the registered account.
  /// Throws [Exception] if the device token cannot be obtained.
  Future<String> registerDevice(String qrCodeJson) async {
    final deviceToken = await MessagingService.instance.getDeviceToken();
    if (deviceToken == null) {
      throw Exception('Failed to get device push token.');
    }

    // Choose the appropriate Amazon SNS platform based on config when
    // using Amazon SNS as the push notification service provider.
    final platform =
        (AppConfig.instance.feature.push.useApnsOnIos && Platform.isIOS)
            ? AmazonSNSPlatform.apns
            : AmazonSNSPlatform.fcm;

    // Choose the appropriate push provider based on config and platform.
    final provider =
        (AppConfig.instance.feature.push.useApnsOnIos && Platform.isIOS)
            ? AmazonSNSPushProvider(platform)
            : FCMPushProvider();

    final accountId = await AsgardeoPushAuth.instance
        .registerDevice(qrCodeJson, deviceToken, provider);

    await ref.read(accountNotifierProvider.notifier).refresh();
    return accountId;
  }

  // ─── Auth response ────────────────────────────────────────────────

  /// Sends an approve or deny [status] for the given push auth [request].
  ///
  /// Delegates JWT creation, signing, and HTTP POST to the SDK.
  Future<void> sendResponse(
    PushAuthRequest request,
    PushAuthResponseStatus status, {
    int? selectedNumber,
  }) async {
    await AsgardeoPushAuth.instance
        .sendAuthResponse(request, status, selectedNumber: selectedNumber);
    removeFromCache(request.pushId);
  }

  // ─── Device unregistration ────────────────────────────────────────

  /// Unregisters the push device for [accountId].
  ///
  /// The SDK sends the unregistration JWT, removes the account, and
  /// deletes stored keys.
  Future<void> unregisterDevice(String accountId) async {
    await AsgardeoPushAuth.instance.unregisterDevice(accountId);
    await ref.read(accountNotifierProvider.notifier).refresh();
  }

  /// Removes the local account and associated data for [accountId].
  Future<void> removeLocalAccount(String accountId) async {
    await AsgardeoPushAuth.instance.removeLocalAccount(accountId);
    await ref.read(accountNotifierProvider.notifier).refresh();
  }

  // ─── Device edit ──────────────────────────────────────────────────

  /// Updates the device [name] and/or push [deviceToken] for [accountId].
  Future<void> editDevice(
    String accountId, {
    String? name,
    String? deviceToken,
  }) async {
    await AsgardeoPushAuth.instance
        .updateDevice(accountId, name: name, pushToken: deviceToken);
  }
}

/// Provider for [PushAuthNotifier].
final pushAuthNotifierProvider =
    NotifierProvider<PushAuthNotifier, Map<String, PushAuthRequest>>(
  PushAuthNotifier.new,
);
