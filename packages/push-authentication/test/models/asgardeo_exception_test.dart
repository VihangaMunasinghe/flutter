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

import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsgardeoException hierarchy', () {
    // ── Subtype relationships ──────────────────────────────

    test('AsgardeoNotInitializedException is an AsgardeoException', () {
      const e = AsgardeoNotInitializedException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoAlreadyInitializedException is an AsgardeoException', () {
      const e = AsgardeoAlreadyInitializedException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoValidationException is an AsgardeoException', () {
      const e = AsgardeoValidationException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoRegistrationException is an AsgardeoException', () {
      const e = AsgardeoRegistrationException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoAuthResponseException is an AsgardeoException', () {
      const e = AsgardeoAuthResponseException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoAccountNotFoundException is an AsgardeoException', () {
      const e = AsgardeoAccountNotFoundException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoDeviceNotFoundException is an AsgardeoException', () {
      const e = AsgardeoDeviceNotFoundException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoDeviceUpdateException is an AsgardeoException', () {
      const e = AsgardeoDeviceUpdateException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoUnregistrationException is an AsgardeoException', () {
      const e = AsgardeoUnregistrationException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoCryptoException is an AsgardeoException', () {
      const e = AsgardeoCryptoException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoNetworkException is an AsgardeoException', () {
      const e = AsgardeoNetworkException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoStorageException is an AsgardeoException', () {
      const e = AsgardeoStorageException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoBiometricUnavailableException is an AsgardeoException', () {
      const e = AsgardeoBiometricUnavailableException('msg');
      expect(e, isA<AsgardeoException>());
    });

    test('AsgardeoBiometricAuthFailedException is an AsgardeoException', () {
      const e = AsgardeoBiometricAuthFailedException('msg');
      expect(e, isA<AsgardeoException>());
    });
  });

  // ── Field preservation ─────────────────────────────────

  group('field preservation', () {
    test('message is preserved', () {
      const e = AsgardeoNetworkException('network error');
      expect(e.message, 'network error');
    });

    test('code is preserved', () {
      const e = AsgardeoValidationException('msg', code: 'ASGPA-2001');
      expect(e.code, 'ASGPA-2001');
    });

    test('traceId is preserved', () {
      const e = AsgardeoRegistrationException('msg', traceId: 'trace-123');
      expect(e.traceId, 'trace-123');
    });

    test('cause is preserved', () {
      final inner = Exception('inner');
      final e = AsgardeoNetworkException('msg', cause: inner);
      expect(e.cause, inner);
    });

    test('AsgardeoNetworkException.statusCode is preserved', () {
      const e = AsgardeoNetworkException('msg', statusCode: 503);
      expect(e.statusCode, 503);
    });
  });

  // ── toString format ────────────────────────────────────

  group('toString', () {
    test('includes [code] when code is set', () {
      const e = AsgardeoValidationException('msg', code: 'ASGPA-2001');
      expect(e.toString(), contains('[ASGPA-2001]'));
    });

    test('includes (traceId: ...) when traceId is set', () {
      const e = AsgardeoRegistrationException(
        'msg',
        traceId: 'trace-abc',
      );
      expect(e.toString(), contains('traceId: trace-abc'));
    });

    test('includes (cause: ...) when cause is set', () {
      final inner = Exception('root cause');
      final e = AsgardeoNetworkException('msg', cause: inner);
      expect(e.toString(), contains('cause:'));
    });

    test('contains only message when all optional fields are null', () {
      const e = AsgardeoValidationException('just a message');
      final s = e.toString();
      expect(s, contains('just a message'));
      expect(s, isNot(contains('traceId')));
      expect(s, isNot(contains('cause')));
    });
  });
}
