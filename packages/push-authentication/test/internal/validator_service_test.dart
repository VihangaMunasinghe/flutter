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

import 'package:asgardeo_push_auth/src/internal/validator_service.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_request.dart';
import 'package:asgardeo_push_auth/src/models/push_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('ValidatorService', () {
    // ── validateQrPayload ──────────────────────────────────

    group('validateQrPayload', () {
      test('passes with all required fields present', () {
        expect(
          () => ValidatorService.validateQrPayload({
            'deviceId': kDeviceId,
            'challenge': kChallenge,
            'username': kUsername,
            'host': kHost,
          }),
          returnsNormally,
        );
      });

      for (final field in ['deviceId', 'challenge', 'username', 'host']) {
        test('throws ASGPA-2001 when $field is null', () {
          final json = {
            'deviceId': kDeviceId,
            'challenge': kChallenge,
            'username': kUsername,
            'host': kHost,
            field: null,
          };
          expect(
            () => ValidatorService.validateQrPayload(json),
            throwsA(
              isA<AsgardeoValidationException>()
                  .having((e) => e.code, 'code', 'ASGPA-2001'),
            ),
          );
        });

        test('throws ASGPA-2001 when $field is empty string', () {
          final json = {
            'deviceId': kDeviceId,
            'challenge': kChallenge,
            'username': kUsername,
            'host': kHost,
            field: '',
          };
          expect(
            () => ValidatorService.validateQrPayload(json),
            throwsA(
              isA<AsgardeoValidationException>()
                  .having((e) => e.code, 'code', 'ASGPA-2001'),
            ),
          );
        });
      }
    });

    // ── validatePushNotificationData ──────────────────────

    group('validatePushNotificationData', () {
      const validData = <String, dynamic>{
        'pushId': kPushId,
        'challenge': kChallenge,
        'deviceId': kDeviceId,
        'username': kUsername,
        'userStoreDomain': 'PRIMARY',
        'applicationName': 'TestApp',
        'notificationScenario': 'AUTHENTICATION',
        'ipAddress': '1.2.3.4',
        'deviceOS': 'iOS',
        'browser': 'Safari',
      };

      test('passes when all required fields are present', () {
        expect(
          () => ValidatorService.validatePushNotificationData(validData),
          returnsNormally,
        );
      });

      test('passes when optional fields are absent', () {
        // tenantDomain, organizationId, numberChallenge, relativePath absent.
        expect(
          () => ValidatorService.validatePushNotificationData(validData),
          returnsNormally,
        );
      });

      test('passes when extra unknown fields are present', () {
        expect(
          () => ValidatorService.validatePushNotificationData({
            ...validData,
            'unknownField': 'value',
          }),
          returnsNormally,
        );
      });

      for (final field in [
        'pushId',
        'challenge',
        'deviceId',
        'username',
        'userStoreDomain',
        'applicationName',
        'notificationScenario',
        'ipAddress',
        'deviceOS',
        'browser',
      ]) {
        test('throws ASGPA-2010 when $field is null', () {
          final data = Map<String, dynamic>.from(validData)..[field] = null;
          expect(
            () => ValidatorService.validatePushNotificationData(data),
            throwsA(
              isA<AsgardeoValidationException>()
                  .having((e) => e.code, 'code', 'ASGPA-2010'),
            ),
          );
        });

        test('throws ASGPA-2010 when $field is empty string', () {
          final data = Map<String, dynamic>.from(validData)..[field] = '';
          expect(
            () => ValidatorService.validatePushNotificationData(data),
            throwsA(
              isA<AsgardeoValidationException>()
                  .having((e) => e.code, 'code', 'ASGPA-2010'),
            ),
          );
        });
      }
    });

    // ── validateAuthRequest ────────────────────────────────

    group('validateAuthRequest', () {
      test('passes with non-empty pushId, challenge, deviceId', () {
        expect(
          () => ValidatorService.validateAuthRequest(kValidRequest),
          returnsNormally,
        );
      });

      test('throws ASGPA-2002 when pushId is empty', () {
        const request = PushAuthRequest(
          pushId: '',
          challenge: kChallenge,
          deviceId: kDeviceId,
          username: kUsername,
          tenantDomain: kTenantDomain,
          userStoreDomain: 'PRIMARY',
          applicationName: 'App',
          notificationScenario: 'AUTHENTICATION',
          ipAddress: '1.2.3.4',
          deviceOS: 'iOS',
          browser: 'Safari',
          sentTime: 0,
        );
        expect(
          () => ValidatorService.validateAuthRequest(request),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2002'),
          ),
        );
      });

      test('throws ASGPA-2003 when challenge is empty', () {
        const request = PushAuthRequest(
          pushId: kPushId,
          challenge: '',
          deviceId: kDeviceId,
          username: kUsername,
          tenantDomain: kTenantDomain,
          userStoreDomain: 'PRIMARY',
          applicationName: 'App',
          notificationScenario: 'AUTHENTICATION',
          ipAddress: '1.2.3.4',
          deviceOS: 'iOS',
          browser: 'Safari',
          sentTime: 0,
        );
        expect(
          () => ValidatorService.validateAuthRequest(request),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2003'),
          ),
        );
      });

      test('throws ASGPA-2004 when deviceId is empty', () {
        const request = PushAuthRequest(
          pushId: kPushId,
          challenge: kChallenge,
          deviceId: '',
          username: kUsername,
          tenantDomain: kTenantDomain,
          userStoreDomain: 'PRIMARY',
          applicationName: 'App',
          notificationScenario: 'AUTHENTICATION',
          ipAddress: '1.2.3.4',
          deviceOS: 'iOS',
          browser: 'Safari',
          sentTime: 0,
        );
        expect(
          () => ValidatorService.validateAuthRequest(request),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2004'),
          ),
        );
      });
    });

    // ── validatePushProvider ───────────────────────────────

    group('validatePushProvider', () {
      test('passes for provider with non-empty name', () {
        final provider = CustomPushProvider(name: 'FCM');
        expect(
          () => ValidatorService.validatePushProvider(provider),
          returnsNormally,
        );
      });

      test('throws ASGPA-2005 when provider name is empty', () {
        final provider = CustomPushProvider(name: '');
        expect(
          () => ValidatorService.validatePushProvider(provider),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2005'),
          ),
        );
      });
    });

    // ── validateAccountId ──────────────────────────────────

    group('validateAccountId', () {
      test('passes for non-empty account ID', () {
        expect(
          () => ValidatorService.validateAccountId(kAccountId),
          returnsNormally,
        );
      });

      test('throws ASGPA-2006 when account ID is empty', () {
        expect(
          () => ValidatorService.validateAccountId(''),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2006'),
          ),
        );
      });
    });

    // ── validateEditParams ─────────────────────────────────

    group('validateEditParams', () {
      test('passes when name is provided', () {
        expect(
          () => ValidatorService.validateEditParams(name: 'My Phone'),
          returnsNormally,
        );
      });

      test('passes when pushToken is provided', () {
        expect(
          () => ValidatorService.validateEditParams(
            pushToken: kDeviceToken,
          ),
          returnsNormally,
        );
      });

      test('passes when both name and pushToken are provided', () {
        expect(
          () => ValidatorService.validateEditParams(
            name: 'My Phone',
            pushToken: kDeviceToken,
          ),
          returnsNormally,
        );
      });

      test('throws ASGPA-2007 when both params are null', () {
        expect(
          ValidatorService.validateEditParams,
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2007'),
          ),
        );
      });

      test('throws ASGPA-2007 when both params are empty strings', () {
        expect(
          () => ValidatorService.validateEditParams(
            name: '',
            pushToken: '',
          ),
          throwsA(
            isA<AsgardeoValidationException>()
                .having((e) => e.code, 'code', 'ASGPA-2007'),
          ),
        );
      });
    });
  });
}
