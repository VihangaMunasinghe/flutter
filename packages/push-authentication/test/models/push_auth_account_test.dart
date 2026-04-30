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

import 'package:asgardeo_push_auth/src/models/push_auth_account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('PushAuthAccount', () {
    // ── fromJson ───────────────────────────────────────────

    group('fromJson', () {
      test('maps all required fields correctly', () {
        final json = {
          'id': kAccountId,
          'username': kUsername,
          'displayName': kUsername,
          'deviceId': kDeviceId,
          'host': kHost,
        };
        final account = PushAuthAccount.fromJson(json);
        expect(account.id, kAccountId);
        expect(account.username, kUsername);
        expect(account.displayName, kUsername);
        expect(account.deviceId, kDeviceId);
        expect(account.host, kHost);
      });

      test('optional fields are null when absent', () {
        final json = {
          'id': kAccountId,
          'username': kUsername,
          'displayName': kUsername,
          'deviceId': kDeviceId,
          'host': kHost,
        };
        final account = PushAuthAccount.fromJson(json);
        expect(account.tenantDomain, isNull);
        expect(account.organizationId, isNull);
        expect(account.organizationName, isNull);
        expect(account.userStoreDomain, isNull);
      });

      test('optional fields are populated when present', () {
        final json = {
          'id': kAccountId,
          'username': kUsername,
          'displayName': kUsername,
          'deviceId': kDeviceId,
          'host': kHost,
          'tenantDomain': kTenantDomain,
          'organizationId': kOrgId,
          'organizationName': 'My Org',
          'userStoreDomain': 'PRIMARY',
        };
        final account = PushAuthAccount.fromJson(json);
        expect(account.tenantDomain, kTenantDomain);
        expect(account.organizationId, kOrgId);
        expect(account.organizationName, 'My Org');
        expect(account.userStoreDomain, 'PRIMARY');
      });
    });

    // ── toJson ─────────────────────────────────────────────

    group('toJson', () {
      test('omits null optional fields', () {
        final json = kValidAccount.toJson();
        expect(json.containsKey('organizationId'), isFalse);
        expect(json.containsKey('organizationName'), isFalse);
        expect(json.containsKey('userStoreDomain'), isFalse);
      });

      test('round-trip fromJson → toJson preserves all fields', () {
        final original = PushAuthAccount.fromJson(kValidAccount.toJson());
        expect(original.id, kValidAccount.id);
        expect(original.username, kValidAccount.username);
        expect(original.deviceId, kValidAccount.deviceId);
        expect(original.host, kValidAccount.host);
        expect(original.tenantDomain, kValidAccount.tenantDomain);
      });
    });

    // ── copyWith ───────────────────────────────────────────

    group('copyWith', () {
      test('with no overrides returns identical values', () {
        final copy = kValidAccount.copyWith();
        expect(copy.id, kValidAccount.id);
        expect(copy.username, kValidAccount.username);
        expect(copy.displayName, kValidAccount.displayName);
        expect(copy.deviceId, kValidAccount.deviceId);
        expect(copy.host, kValidAccount.host);
        expect(copy.tenantDomain, kValidAccount.tenantDomain);
      });

      test('with one override replaces only that field', () {
        final copy = kValidAccount.copyWith(displayName: 'New Name');
        expect(copy.displayName, 'New Name');
        expect(copy.id, kValidAccount.id);
        expect(copy.deviceId, kValidAccount.deviceId);
      });
    });
  });
}
