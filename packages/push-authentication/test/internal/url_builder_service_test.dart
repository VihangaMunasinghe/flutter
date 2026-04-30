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

import 'package:asgardeo_push_auth/src/internal/url_builder_service.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const host = 'https://api.asgardeo.io';
  const tenant = 'myorg.com';
  const org = 'org-123';
  const device = 'device-001';
  const relPath = '/t/myorg.com/o/org-123';

  group('UrlBuilderService', () {
    // ── buildRegistrationUrl ───────────────────────────────

    group('buildRegistrationUrl', () {
      test('tenant only', () {
        expect(
          UrlBuilderService.buildRegistrationUrl(
            host: host,
            tenantDomain: tenant,
          ),
          '$host/t/$tenant/api/users/v1/me/push/devices',
        );
      });

      test('organization only', () {
        expect(
          UrlBuilderService.buildRegistrationUrl(
            host: host,
            organizationId: org,
          ),
          '$host/o/$org/api/users/v1/me/push/devices',
        );
      });

      test('both tenant and organization', () {
        expect(
          UrlBuilderService.buildRegistrationUrl(
            host: host,
            tenantDomain: tenant,
            organizationId: org,
          ),
          '$host/t/$tenant/o/$org/api/users/v1/me/push/devices',
        );
      });

      test('neither throws ASGPA-2009', () {
        expect(
          () => UrlBuilderService.buildRegistrationUrl(host: host),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2009'),
          ),
        );
      });
    });

    // ── buildAuthenticateUrl ───────────────────────────────

    group('buildAuthenticateUrl', () {
      test('relativePath takes precedence over tenant/org', () {
        expect(
          UrlBuilderService.buildAuthenticateUrl(
            host: host,
            relativePath: relPath,
            tenantDomain: tenant,
            organizationId: org,
          ),
          '$host$relPath/push-auth/authenticate',
        );
      });

      test('tenant only', () {
        expect(
          UrlBuilderService.buildAuthenticateUrl(
            host: host,
            tenantDomain: tenant,
          ),
          '$host/t/$tenant/push-auth/authenticate',
        );
      });

      test('organization only', () {
        expect(
          UrlBuilderService.buildAuthenticateUrl(
            host: host,
            organizationId: org,
          ),
          '$host/o/$org/push-auth/authenticate',
        );
      });

      test('both tenant and organization', () {
        expect(
          UrlBuilderService.buildAuthenticateUrl(
            host: host,
            tenantDomain: tenant,
            organizationId: org,
          ),
          '$host/t/$tenant/o/$org/push-auth/authenticate',
        );
      });

      test('neither throws ASGPA-2009', () {
        expect(
          () => UrlBuilderService.buildAuthenticateUrl(host: host),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2009'),
          ),
        );
      });
    });

    // ── buildUnregistrationUrl ─────────────────────────────

    group('buildUnregistrationUrl', () {
      test('substitutes deviceId placeholder with tenant', () {
        expect(
          UrlBuilderService.buildUnregistrationUrl(
            host: host,
            deviceId: device,
            tenantDomain: tenant,
          ),
          '$host/t/$tenant'
          '/api/users/v1/me/push/devices/$device/remove',
        );
      });

      test('substitutes deviceId placeholder with org', () {
        expect(
          UrlBuilderService.buildUnregistrationUrl(
            host: host,
            deviceId: device,
            organizationId: org,
          ),
          '$host/o/$org'
          '/api/users/v1/me/push/devices/$device/remove',
        );
      });
    });

    // ── buildEditUrl ───────────────────────────────────────

    group('buildEditUrl', () {
      test('substitutes deviceId placeholder with tenant', () {
        expect(
          UrlBuilderService.buildEditUrl(
            host: host,
            deviceId: device,
            tenantDomain: tenant,
          ),
          '$host/t/$tenant'
          '/api/users/v1/me/push/devices/$device/update',
        );
      });

      test('substitutes deviceId placeholder with both', () {
        expect(
          UrlBuilderService.buildEditUrl(
            host: host,
            deviceId: device,
            tenantDomain: tenant,
            organizationId: org,
          ),
          '$host/t/$tenant/o/$org'
          '/api/users/v1/me/push/devices/$device/update',
        );
      });
    });

    // ── buildDiscoveryDataUrl ──────────────────────────────

    group('buildDiscoveryDataUrl', () {
      test('appends the discovery-data path to baseUrl', () {
        expect(
          UrlBuilderService.buildDiscoveryDataUrl(baseUrl: host),
          '$host/api/users/v1/me/push/discovery-data',
        );
      });
    });
  });
}
