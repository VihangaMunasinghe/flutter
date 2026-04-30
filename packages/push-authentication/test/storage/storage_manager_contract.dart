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

import 'package:asgardeo_push_auth/src/storage/asgardeo_storage_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared contract tests for [AsgardeoStorageManager] implementations.
void runStorageManagerContractTests({
  required String implementationName,
  required AsgardeoStorageManager Function() subjectFactory,
}) {
  group('AsgardeoStorageManager contract → $implementationName', () {
    late AsgardeoStorageManager subject;

    setUp(() {
      subject = subjectFactory();
    });

    test('getString returns null for non-existent key', () async {
      expect(await subject.getString('absent'), isNull);
    });

    test('setString + getString stores and retrieves a value', () async {
      await subject.setString('key1', 'value1');
      expect(await subject.getString('key1'), 'value1');
    });

    test('setString overwrites existing value for same key', () async {
      await subject.setString('key1', 'first');
      await subject.setString('key1', 'second');
      expect(await subject.getString('key1'), 'second');
    });

    test('different keys are independent', () async {
      await subject.setString('a', '1');
      await subject.setString('b', '2');
      expect(await subject.getString('a'), '1');
      expect(await subject.getString('b'), '2');
    });

    test('remove makes key return null', () async {
      await subject.setString('key1', 'value1');
      await subject.remove('key1');
      expect(await subject.getString('key1'), isNull);
    });

    test('remove does not error for non-existent key', () async {
      await expectLater(subject.remove('absent'), completes);
    });
  });
}
