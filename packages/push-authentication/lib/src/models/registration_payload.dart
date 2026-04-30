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

/// Registration payload received from the Asgardeo server, either parsed
/// from a QR code or fetched via the discovery-data endpoint.
class RegistrationPayload {

  /// Creates a [RegistrationPayload].
  const RegistrationPayload({
    required this.deviceId,
    required this.challenge,
    required this.username,
    required this.host,
    this.tenantDomain,
    this.organizationId,
    this.organizationName,
    this.userStoreDomain,
  });

  /// Deserializes from a JSON-compatible map.
  factory RegistrationPayload.fromJson(Map<String, dynamic> json) =>
      RegistrationPayload(
        deviceId: json['deviceId'] as String,
        challenge: json['challenge'] as String,
        username: json['username'] as String,
        host: json['host'] as String,
        tenantDomain: json['tenantDomain'] as String?,
        organizationId: json['organizationId'] as String?,
        organizationName: json['organizationName'] as String?,
        userStoreDomain: json['userStoreDomain'] as String?,
      );

  /// Device identifier assigned by the server.
  final String deviceId;

  /// One-time challenge to be signed during registration.
  final String challenge;

  /// Username of the account being registered.
  final String username;

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
}
