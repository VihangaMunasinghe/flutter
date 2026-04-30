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
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsgardeoPushAuthErrorCode', () {
    test('every code string starts with ASGPA-', () {
      for (final code in AsgardeoPushAuthErrorCode.values) {
        expect(
          code.code,
          startsWith('ASGPA-'),
          reason: '${code.name} should start with ASGPA-',
        );
      }
    });

    test('all code strings are unique', () {
      final codes =
          AsgardeoPushAuthErrorCode.values.map((e) => e.code).toList();
      expect(codes.toSet(), hasLength(codes.length));
    });

    test('format with no placeholders returns the message unchanged', () {
      expect(
        AsgardeoPushAuthErrorCode.notInitialized.format([]),
        AsgardeoPushAuthErrorCode.notInitialized.message,
      );
    });

    test('format substitutes a single %s placeholder', () {
      final result =
          AsgardeoPushAuthErrorCode.missingQrField.format(['deviceId']);
      expect(result, contains('deviceId'));
      expect(result, isNot(contains('%s')));
    });

    test('format substitutes both %s placeholders', () {
      final result = AsgardeoPushAuthErrorCode.requestFailed
          .format(['Registration', '400']);
      expect(result, contains('Registration'));
      expect(result, contains('400'));
      expect(result, isNot(contains('%s')));
    });

    test('toString returns "code - message" format', () {
      const code = AsgardeoPushAuthErrorCode.notInitialized;
      expect(code.toString(), '${code.code} - ${code.message}');
    });
  });
}
