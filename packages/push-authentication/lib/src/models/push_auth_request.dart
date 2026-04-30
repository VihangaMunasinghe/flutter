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

/// Data received in a push authentication notification.
class PushAuthRequest {

  /// Creates a [PushAuthRequest].
  const PushAuthRequest({
    required this.pushId,
    required this.challenge,
    required this.deviceId,
    required this.username,
    required this.tenantDomain,
    required this.userStoreDomain,
    required this.applicationName,
    required this.notificationScenario,
    required this.ipAddress,
    required this.deviceOS,
    required this.browser,
    required this.sentTime,
    this.numberChallenge,
    this.organizationId,
    this.organizationName,
    this.relativePath,
  });

  /// Creates a [PushAuthRequest] from a push notification data payload.
  factory PushAuthRequest.fromJson(
    Map<String, dynamic> data, {
    int? sentTime,
  }) =>
      PushAuthRequest(
        pushId: data['pushId'] as String? ?? '',
        challenge: data['challenge'] as String? ?? '',
        numberChallenge: data['numberChallenge'] as String?,
        relativePath: data['relativePath'] as String?,
        deviceId: data['deviceId'] as String? ?? '',
        username: data['username'] as String? ?? '',
        tenantDomain: data['tenantDomain'] as String? ?? '',
        organizationId: data['organizationId'] as String?,
        organizationName: data['organizationName'] as String?,
        userStoreDomain: data['userStoreDomain'] as String? ?? '',
        applicationName: data['applicationName'] as String? ?? '',
        notificationScenario: data['notificationScenario'] as String? ?? '',
        ipAddress: data['ipAddress'] as String? ?? '',
        deviceOS: data['deviceOS'] as String? ?? '',
        browser: data['browser'] as String? ?? '',
        sentTime: sentTime ??
            (data['sentTime'] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      );

  /// Unique identifier for this push authentication request.
  final String pushId;

  /// Server-issued challenge string to be signed in the response.
  final String challenge;

  /// Optional number challenge for number-matching flows.
  final String? numberChallenge;

  /// Optional relative path for the authentication endpoint.
  final String? relativePath;

  /// Device identifier this notification is targeted at.
  final String deviceId;

  /// Username of the authenticating user.
  final String username;

  /// Tenant domain of the user's organization.
  final String tenantDomain;

  /// Sub-organization identifier, if applicable.
  final String? organizationId;

  /// Human-readable organization name, if applicable.
  final String? organizationName;

  /// User store domain where the user account resides.
  final String userStoreDomain;

  /// Name of the application requesting authentication.
  final String applicationName;

  /// Scenario type of the notification.
  final String notificationScenario;

  /// IP address from which the request originated.
  final String ipAddress;

  /// Operating system of the requesting device.
  final String deviceOS;

  /// Browser or client that initiated the request.
  final String browser;

  /// Timestamp (milliseconds since epoch) when the notification was sent.
  final int sentTime;

  /// Serializes this request to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'pushId': pushId,
        'challenge': challenge,
        if (numberChallenge != null) 'numberChallenge': numberChallenge,
        if (relativePath != null) 'relativePath': relativePath,
        'deviceId': deviceId,
        'username': username,
        'tenantDomain': tenantDomain,
        if (organizationId != null) 'organizationId': organizationId,
        if (organizationName != null) 'organizationName': organizationName,
        'userStoreDomain': userStoreDomain,
        'applicationName': applicationName,
        'notificationScenario': notificationScenario,
        'ipAddress': ipAddress,
        'deviceOS': deviceOS,
        'browser': browser,
        'sentTime': sentTime,
      };
}
