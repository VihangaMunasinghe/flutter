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

import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/services/apns_messaging_service.dart';
import 'package:asgardeo_push_authenticator/services/fcm_messaging_service.dart';
import 'package:asgardeo_push_authenticator/services/push_messaging_service.dart';

/// Resolves and initialises the correct [PushMessagingService] for the current
/// platform.
///
/// Call [MessagingService.initialize] once at app startup before any messaging
/// operations. Respects [AppConfig.instance.feature.push.useApnsOnIos].
class MessagingService {
  static late final PushMessagingService _notificationService;

  /// Initialises the platform-appropriate [PushMessagingService].
  ///
  /// On iOS with `useApnsOnIos` enabled, uses [ApnsMessagingService].
  /// On all other platforms, uses [FcmMessagingService].
  static void initialize() {
    if (AppConfig.instance.feature.push.useApnsOnIos && Platform.isIOS) {
      _notificationService = ApnsMessagingService()..initialize();
    } else {
      _notificationService = FcmMessagingService();
    }
  }

  /// The active [PushMessagingService] for the current platform.
  static PushMessagingService get instance => _notificationService;
}
