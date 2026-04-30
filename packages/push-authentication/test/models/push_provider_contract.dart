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

import 'package:asgardeo_push_auth/src/models/push_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared contract tests for [AsgardeoPushNotificationProvider]
/// implementations.
void runPushProviderContractTests({
  required String implementationName,
  required AsgardeoPushNotificationProvider Function() subjectFactory,
  required String expectedName,
  required Map<String, dynamic> expectedMetadata,
}) {
  group(
    'AsgardeoPushNotificationProvider contract → $implementationName',
    () {
      test('name matches expected value', () {
        final subject = subjectFactory();
        expect(subject.name, expectedName);
      });

      test('metadata matches expected map', () {
        final subject = subjectFactory();
        expect(subject.metadata, expectedMetadata);
      });

      test('toJson contains name and metadata keys', () {
        final subject = subjectFactory();
        final json = subject.toJson();
        expect(json, containsPair('name', expectedName));
        expect(json, containsPair('metadata', expectedMetadata));
      });
    },
  );
}
