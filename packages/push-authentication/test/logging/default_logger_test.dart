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

import 'package:asgardeo_push_auth/src/logging/asgardeo_logger.dart';
import 'package:asgardeo_push_auth/src/logging/default_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultLogger', () {
    test('default level is LogLevel.none', () {
      const logger = DefaultLogger();
      expect(logger.level, LogLevel.none);
    });

    // ── LogLevel.none ────────────────────────────────────

    group('LogLevel.none', () {
      const logger = DefaultLogger();

      test('error() does not throw', () {
        expect(
          () => logger.error('msg', Exception('e'), StackTrace.empty),
          returnsNormally,
        );
      });

      test('info() does not throw', () {
        expect(() => logger.info('msg'), returnsNormally);
      });

      test('debug() does not throw', () {
        expect(() => logger.debug('msg'), returnsNormally);
      });
    });

    // ── LogLevel.error ───────────────────────────────────

    group('LogLevel.error', () {
      const logger = DefaultLogger(level: LogLevel.error);

      test('error() does not throw', () {
        expect(
          () => logger.error('error msg'),
          returnsNormally,
        );
      });

      test('info() does not throw', () {
        expect(() => logger.info('info msg'), returnsNormally);
      });

      test('debug() does not throw', () {
        expect(() => logger.debug('debug msg'), returnsNormally);
      });
    });

    // ── LogLevel.info ────────────────────────────────────

    group('LogLevel.info', () {
      const logger = DefaultLogger(level: LogLevel.info);

      test('error() does not throw', () {
        expect(() => logger.error('err'), returnsNormally);
      });

      test('info() does not throw', () {
        expect(() => logger.info('info'), returnsNormally);
      });

      test('debug() does not throw', () {
        expect(() => logger.debug('debug'), returnsNormally);
      });
    });

    // ── LogLevel.debug ───────────────────────────────────

    group('LogLevel.debug', () {
      const logger = DefaultLogger(level: LogLevel.debug);

      test('error() does not throw', () {
        expect(() => logger.error('err'), returnsNormally);
      });

      test('info() does not throw', () {
        expect(() => logger.info('info'), returnsNormally);
      });

      test('debug() does not throw', () {
        expect(() => logger.debug('debug'), returnsNormally);
      });
    });

    // ── Level filtering logic ──────────────────────────────

    group('level filtering', () {
      test('LogLevel.debug passes all levels', () {
        expect(LogLevel.debug.index >= LogLevel.error.index, isTrue);
        expect(LogLevel.debug.index >= LogLevel.info.index, isTrue);
        expect(LogLevel.debug.index >= LogLevel.debug.index, isTrue);
      });

      test('LogLevel.none blocks all levels', () {
        expect(LogLevel.none.index >= LogLevel.error.index, isFalse);
        expect(LogLevel.none.index >= LogLevel.info.index, isFalse);
        expect(LogLevel.none.index >= LogLevel.debug.index, isFalse);
      });

      test('LogLevel.error only passes error level', () {
        expect(LogLevel.error.index >= LogLevel.error.index, isTrue);
        expect(LogLevel.error.index >= LogLevel.info.index, isFalse);
        expect(
          LogLevel.error.index >= LogLevel.debug.index,
          isFalse,
        );
      });

      test('LogLevel.info passes error and info', () {
        expect(LogLevel.info.index >= LogLevel.error.index, isTrue);
        expect(LogLevel.info.index >= LogLevel.info.index, isTrue);
        expect(LogLevel.info.index >= LogLevel.debug.index, isFalse);
      });
    });
  });
}
