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

import 'package:asgardeo_push_auth/src/models/push_auth_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('PushAuthRequest', () {
    // ── fromJson ───────────────────────────────────────────

    group('fromJson', () {
      test('parses all fields from a flat FCM-style map', () {
        final data = <String, dynamic>{
          'pushId': kPushId,
          'challenge': kChallenge,
          'deviceId': kDeviceId,
          'username': kUsername,
          'tenantDomain': kTenantDomain,
          'userStoreDomain': 'PRIMARY',
          'applicationName': 'TestApp',
          'notificationScenario': 'AUTHENTICATION',
          'ipAddress': '192.168.1.1',
          'deviceOS': 'iOS',
          'browser': 'Safari',
          'sentTime': 1000000,
        };
        final request = PushAuthRequest.fromJson(data);
        expect(request.pushId, kPushId);
        expect(request.challenge, kChallenge);
        expect(request.deviceId, kDeviceId);
        expect(request.username, kUsername);
        expect(request.tenantDomain, kTenantDomain);
        expect(request.userStoreDomain, 'PRIMARY');
        expect(request.applicationName, 'TestApp');
        expect(request.sentTime, 1000000);
      });

      test('optional fields are null when absent', () {
        final data = <String, dynamic>{
          'pushId': kPushId,
          'challenge': kChallenge,
          'deviceId': kDeviceId,
          'username': kUsername,
          'tenantDomain': kTenantDomain,
          'userStoreDomain': 'PRIMARY',
          'applicationName': 'TestApp',
          'notificationScenario': 'AUTHENTICATION',
          'ipAddress': '',
          'deviceOS': '',
          'browser': '',
        };
        final request = PushAuthRequest.fromJson(data);
        expect(request.numberChallenge, isNull);
        expect(request.relativePath, isNull);
        expect(request.organizationId, isNull);
        expect(request.organizationName, isNull);
      });

      test('sentTime comes from the explicit parameter first', () {
        final data = <String, dynamic>{
          'pushId': kPushId,
          'challenge': kChallenge,
          'deviceId': kDeviceId,
          'username': kUsername,
          'tenantDomain': kTenantDomain,
          'userStoreDomain': 'PRIMARY',
          'applicationName': 'App',
          'notificationScenario': 'AUTHENTICATION',
          'ipAddress': '',
          'deviceOS': '',
          'browser': '',
          'sentTime': 111,
        };
        final request = PushAuthRequest.fromJson(data, sentTime: 999);
        expect(request.sentTime, 999);
      });

      test('sentTime falls back to data field when param is null', () {
        final data = <String, dynamic>{
          'pushId': kPushId,
          'challenge': kChallenge,
          'deviceId': kDeviceId,
          'username': kUsername,
          'tenantDomain': kTenantDomain,
          'userStoreDomain': 'PRIMARY',
          'applicationName': 'App',
          'notificationScenario': 'AUTHENTICATION',
          'ipAddress': '',
          'deviceOS': '',
          'browser': '',
          'sentTime': 555,
        };
        final request = PushAuthRequest.fromJson(data);
        expect(request.sentTime, 555);
      });
    });

    // ── toJson ─────────────────────────────────────────────

    group('toJson', () {
      test('omits null optional fields', () {
        final json = kValidRequest.toJson();
        expect(json.containsKey('numberChallenge'), isFalse);
        expect(json.containsKey('relativePath'), isFalse);
        expect(json.containsKey('organizationId'), isFalse);
        expect(json.containsKey('organizationName'), isFalse);
      });

      test('includes optional fields when present', () {
        const request = PushAuthRequest(
          pushId: kPushId,
          challenge: kChallenge,
          deviceId: kDeviceId,
          username: kUsername,
          tenantDomain: kTenantDomain,
          userStoreDomain: 'PRIMARY',
          applicationName: 'App',
          notificationScenario: 'AUTHENTICATION',
          ipAddress: '',
          deviceOS: '',
          browser: '',
          sentTime: 0,
          numberChallenge: '42',
          organizationId: kOrgId,
        );
        final json = request.toJson();
        expect(json['numberChallenge'], '42');
        expect(json['organizationId'], kOrgId);
      });
    });
  });
}
