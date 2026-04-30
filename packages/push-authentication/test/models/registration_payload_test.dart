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

import 'package:asgardeo_push_auth/src/models/registration_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('RegistrationPayload', () {
    // ── fromJson ───────────────────────────────────────────

    group('fromJson', () {
      test('maps all required fields correctly', () {
        final json = {
          'deviceId': kDeviceId,
          'challenge': kChallenge,
          'username': kUsername,
          'host': kHost,
        };
        final payload = RegistrationPayload.fromJson(json);
        expect(payload.deviceId, kDeviceId);
        expect(payload.challenge, kChallenge);
        expect(payload.username, kUsername);
        expect(payload.host, kHost);
      });

      test('optional fields are null when absent', () {
        final json = {
          'deviceId': kDeviceId,
          'challenge': kChallenge,
          'username': kUsername,
          'host': kHost,
        };
        final payload = RegistrationPayload.fromJson(json);
        expect(payload.tenantDomain, isNull);
        expect(payload.organizationId, isNull);
        expect(payload.organizationName, isNull);
        expect(payload.userStoreDomain, isNull);
      });

      test('optional fields are populated when present', () {
        final json = {
          'deviceId': kDeviceId,
          'challenge': kChallenge,
          'username': kUsername,
          'host': kHost,
          'tenantDomain': kTenantDomain,
          'organizationId': kOrgId,
          'organizationName': 'My Org',
          'userStoreDomain': 'PRIMARY',
        };
        final payload = RegistrationPayload.fromJson(json);
        expect(payload.tenantDomain, kTenantDomain);
        expect(payload.organizationId, kOrgId);
        expect(payload.organizationName, 'My Org');
        expect(payload.userStoreDomain, 'PRIMARY');
      });
    });
  });
}
