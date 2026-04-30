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

import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';

/// Tenant URL segment prefix.
const String kTenantSegment = '/t/';

/// Organization URL segment prefix.
const String kOrganizationSegment = '/o/';

/// Device registration API path.
const String kRegistrationPath = '/api/users/v1/me/push/devices';

/// Push authentication response API path.
const String kAuthenticatePath = '/push-auth/authenticate';

/// Device unregistration API path template.
const String kUnregistrationPathTemplate =
    '/api/users/v1/me/push/devices/{deviceId}/remove';

/// Device update API path template.
const String kEditPathTemplate =
    '/api/users/v1/me/push/devices/{deviceId}/update';

/// Push discovery data API path.
const String kDiscoveryDataPath = '/api/users/v1/me/push/discovery-data';

/// Internal service for constructing Asgardeo API endpoint URLs.
///
/// URL routing follows the Asgardeo multi-tenant and sub-organization
/// conventions:
/// - Organization takes precedence: `/o/{organizationId}/...`
/// - Tenant fallback: `/t/{tenantDomain}/...`
/// - For authentication, both may be combined:
///   `/t/{tenantDomain}/o/{organizationId}/...`
class UrlBuilderService {

  /// Builds the device registration endpoint URL.
  static String buildRegistrationUrl({
    required String host,
    String? tenantDomain,
    String? organizationId,
  }) {

    final prefix = _resolveRelativePath(
      tenantDomain: tenantDomain,
      organizationId: organizationId,
    );
    return '$host$prefix$kRegistrationPath';
  }

  /// Builds the push authentication response endpoint URL.
  static String buildAuthenticateUrl({
    required String host,
    String? relativePath,
    String? tenantDomain,
    String? organizationId,
  }) {

    final prefix = _resolveRelativePath(
      relativePath: relativePath,
      tenantDomain: tenantDomain,
      organizationId: organizationId,
    );
    return '$host$prefix$kAuthenticatePath';
  }

  /// Builds the device unregistration endpoint URL.
  static String buildUnregistrationUrl({
    required String host,
    required String deviceId,
    String? tenantDomain,
    String? organizationId,
  }) {

    final prefix = _resolveRelativePath(
      tenantDomain: tenantDomain,
      organizationId: organizationId,
    );
    final path = kUnregistrationPathTemplate.replaceAll('{deviceId}', deviceId);
    return '$host$prefix$path';
  }

  /// Builds the push discovery data endpoint URL.
  static String buildDiscoveryDataUrl({required String baseUrl}) =>
      '$baseUrl$kDiscoveryDataPath';

  /// Builds the device edit (update) endpoint URL.
  static String buildEditUrl({
    required String host,
    required String deviceId,
    String? tenantDomain,
    String? organizationId,
  }) {

    final prefix = _resolveRelativePath(
      tenantDomain: tenantDomain,
      organizationId: organizationId,
    );
    final path = kEditPathTemplate.replaceAll('{deviceId}', deviceId);
    return '$host$prefix$path';
  }

  /// Resolves the relative path segment used in URL construction.
  ///
  /// - Returns [relativePath] when present.
  /// - Returns `/t/{tenantDomain}/o/{organizationId}` when both are present.
  /// - Returns `/o/{organizationId}` when only [organizationId] is present.
  /// - Returns `/t/{tenantDomain}` when only [tenantDomain] is present.
  /// - Throws [AsgardeoValidationException] when none are present.
  static String _resolveRelativePath({
    String? relativePath,
    String? tenantDomain,
    String? organizationId,
  }) {

    if (_isPresent(relativePath)) return relativePath!;
    if (_isPresent(organizationId) && _isPresent(tenantDomain)) {
      return '$kTenantSegment$tenantDomain$kOrganizationSegment$organizationId';
    }
    if (_isPresent(organizationId)) {
      return '$kOrganizationSegment$organizationId';
    }
    if (_isPresent(tenantDomain)) {
      return '$kTenantSegment$tenantDomain';
    }
    throw AsgardeoValidationException(
      AsgardeoPushAuthErrorCode.unresolvableUrlPath.message,
      code: AsgardeoPushAuthErrorCode.unresolvableUrlPath.code,
    );
  }

  static bool _isPresent(String? value) => value != null && value.isNotEmpty;
}
