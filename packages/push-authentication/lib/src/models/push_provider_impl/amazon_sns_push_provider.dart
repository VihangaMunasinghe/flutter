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

import 'package:asgardeo_push_auth/src/models/push_provider.dart';

/// The underlying push platform used by the [AmazonSNSPushProvider].
enum AmazonSNSPlatform {
  /// Apple Push Notification Service.
  apns('APNS'),

  /// Firebase Cloud Messaging.
  fcm('FCM');

  const AmazonSNSPlatform(this.value);

  /// The platform identifier sent to the server.
  final String value;
}

/// Amazon SNS push provider.
class AmazonSNSPushProvider extends AsgardeoPushNotificationProvider {

  /// Creates an [AmazonSNSPushProvider] with the specified [AmazonSNSPlatform].
  AmazonSNSPushProvider(this._platform);

  final AmazonSNSPlatform _platform;

  @override
  final String name = 'AmazonSNS';

  @override
  Map<String, dynamic> get metadata => {'platform': _platform.value};

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'metadata': metadata,
      };
}
