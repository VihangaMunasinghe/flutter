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

/// A historical record of a push authentication event.
class PushAuthRecord {

  /// Creates a [PushAuthRecord].
  const PushAuthRecord({
    required this.pushAuthId,
    required this.applicationName,
    required this.status,
    required this.respondedTime,
    required this.ipAddress,
    required this.deviceOS,
    required this.browser,
    required this.accountId,
  });

  /// Deserializes from a JSON-compatible map.
  factory PushAuthRecord.fromJson(Map<String, dynamic> json) =>
      PushAuthRecord(
        pushAuthId: json['pushAuthId'] as String,
        applicationName: json['applicationName'] as String? ?? '',
        status: json['status'] as String,
        respondedTime: json['respondedTime'] as int,
        ipAddress: json['ipAddress'] as String? ?? '',
        deviceOS: json['deviceOS'] as String? ?? '',
        browser: json['browser'] as String? ?? '',
        accountId: json['accountId'] as String? ?? '',
      );

  /// Unique identifier for the push authentication request.
  final String pushAuthId;

  /// Name of the application that requested authentication.
  final String applicationName;

  /// Response status string ('APPROVED' or 'DENIED').
  final String status;

  /// Timestamp (milliseconds since epoch) when the response was sent.
  final int respondedTime;

  /// IP address from which the request originated.
  final String ipAddress;

  /// Operating system of the requesting device.
  final String deviceOS;

  /// Browser or client that initiated the request.
  final String browser;

  /// Identifier of the account that handled this request.
  final String accountId;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'pushAuthId': pushAuthId,
        'applicationName': applicationName,
        'status': status,
        'respondedTime': respondedTime,
        'ipAddress': ipAddress,
        'deviceOS': deviceOS,
        'browser': browser,
        'accountId': accountId,
      };
}
