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

import 'package:asgardeo_push_auth/src/internal/qr_parser_service.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('QrParserService', () {
    // ── Valid JSON ─────────────────────────────────────────

    test('parses valid JSON and returns RegistrationPayload', () {
      final payload = QrParserService.parse(kValidQrJson);
      expect(payload.deviceId, kDeviceId);
      expect(payload.challenge, kChallenge);
      expect(payload.username, kUsername);
      expect(payload.host, kHost);
      expect(payload.tenantDomain, kTenantDomain);
    });

    test('optional fields are null when absent', () {
      final payload = QrParserService.parse(kValidQrJson);
      expect(payload.organizationId, isNull);
      expect(payload.organizationName, isNull);
      expect(payload.userStoreDomain, isNull);
    });

    test('optional fields are populated when present', () {
      const json =
          '{"deviceId":"device-001","challenge":"challenge-abc",'
          '"username":"alice@example.com",'
          '"host":"https://api.asgardeo.io",'
          '"tenantDomain":"myorg.com","organizationId":"org-123",'
          '"organizationName":"My Org","userStoreDomain":"PRIMARY"}';
      final payload = QrParserService.parse(json);
      expect(payload.organizationId, 'org-123');
      expect(payload.organizationName, 'My Org');
      expect(payload.userStoreDomain, 'PRIMARY');
    });

    // ── Malformed JSON ─────────────────────────────────────

    test('throws ASGPA-2008 for malformed JSON', () {
      expect(
        () => QrParserService.parse('not-valid-json'),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2008'),
        ),
      );
    });

    // ── Missing required fields ────────────────────────────

    test('throws ASGPA-2001 when deviceId is missing', () {
      const json =
          '{"challenge":"challenge-abc","username":"alice@example.com",'
          '"host":"https://api.asgardeo.io","tenantDomain":"myorg.com"}';
      expect(
        () => QrParserService.parse(json),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2001'),
        ),
      );
    });

    test('throws ASGPA-2001 when challenge is missing', () {
      const json =
          '{"deviceId":"device-001","username":"alice@example.com",'
          '"host":"https://api.asgardeo.io","tenantDomain":"myorg.com"}';
      expect(
        () => QrParserService.parse(json),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2001'),
        ),
      );
    });

    test('throws ASGPA-2001 when username is missing', () {
      const json =
          '{"deviceId":"device-001","challenge":"challenge-abc",'
          '"host":"https://api.asgardeo.io","tenantDomain":"myorg.com"}';
      expect(
        () => QrParserService.parse(json),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2001'),
        ),
      );
    });

    test('throws ASGPA-2001 when host is missing', () {
      const json =
          '{"deviceId":"device-001","challenge":"challenge-abc",'
          '"username":"alice@example.com","tenantDomain":"myorg.com"}';
      expect(
        () => QrParserService.parse(json),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2001'),
        ),
      );
    });
  });
}
