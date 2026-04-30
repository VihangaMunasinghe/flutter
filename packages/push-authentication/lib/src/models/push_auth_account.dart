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

/// Represents a registered push authentication account.
///
/// Contains only push-auth-specific fields. Consumer apps should
/// maintain their own richer account model if needed.
class PushAuthAccount {

  /// Creates a [PushAuthAccount].
  const PushAuthAccount({
    required this.id,
    required this.username,
    required this.displayName,
    required this.deviceId,
    required this.host,
    this.tenantDomain,
    this.organizationId,
    this.organizationName,
    this.userStoreDomain,
  });

  /// Deserializes from a JSON-compatible map.
  factory PushAuthAccount.fromJson(Map<String, dynamic> json) =>
      PushAuthAccount(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        deviceId: json['deviceId'] as String,
        host: json['host'] as String,
        tenantDomain: json['tenantDomain'] as String?,
        organizationId: json['organizationId'] as String?,
        organizationName: json['organizationName'] as String?,
        userStoreDomain: json['userStoreDomain'] as String?,
      );

  /// Unique identifier for this account.
  final String id;

  /// Username associated with this account.
  final String username;

  /// Display name for the account.
  final String displayName;

  /// Device identifier assigned during registration.
  final String deviceId;

  /// Asgardeo server host URL.
  final String host;

  /// Tenant domain of the account's organization.
  final String? tenantDomain;

  /// Sub-organization identifier, if applicable.
  final String? organizationId;

  /// Sub-organization name, if applicable.
  final String? organizationName;

  /// User store domain where the account resides.
  final String? userStoreDomain;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'deviceId': deviceId,
        'host': host,
        if (tenantDomain != null) 'tenantDomain': tenantDomain,
        if (organizationId != null) 'organizationId': organizationId,
        if (organizationName != null) 'organizationName': organizationName,
        if (userStoreDomain != null) 'userStoreDomain': userStoreDomain,
      };

  /// Returns a copy with the given fields replaced.
  PushAuthAccount copyWith({
    String? id,
    String? username,
    String? displayName,
    String? deviceId,
    String? host,
    String? tenantDomain,
    String? organizationId,
    String? organizationName,
    String? userStoreDomain,
  }) =>
      PushAuthAccount(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        deviceId: deviceId ?? this.deviceId,
        host: host ?? this.host,
        tenantDomain: tenantDomain ?? this.tenantDomain,
        organizationId: organizationId ?? this.organizationId,
        organizationName: organizationName ?? this.organizationName,
        userStoreDomain: userStoreDomain ?? this.userStoreDomain,
      );
}
