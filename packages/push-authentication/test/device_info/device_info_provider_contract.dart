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

import 'package:asgardeo_push_auth/src/device_info/asgardeo_device_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared contract tests for [AsgardeoDeviceInfoProvider] implementations.
void runDeviceInfoProviderContractTests({
  required String implementationName,
  required AsgardeoDeviceInfoProvider Function() subjectFactory,
  required void Function() arrangeDeviceInfo,
  required String expectedName,
  required String expectedModel,
}) {
  group(
    'AsgardeoDeviceInfoProvider contract → $implementationName',
    () {
      test('returns a record with expected name and model', () async {
        arrangeDeviceInfo();
        final subject = subjectFactory();
        final info = await subject.getDeviceInfo();
        expect(info.name, expectedName);
        expect(info.model, expectedModel);
      });

      test('name is non-empty', () async {
        arrangeDeviceInfo();
        final subject = subjectFactory();
        final info = await subject.getDeviceInfo();
        expect(info.name, isNotEmpty);
      });

      test('model is non-empty', () async {
        arrangeDeviceInfo();
        final subject = subjectFactory();
        final info = await subject.getDeviceInfo();
        expect(info.model, isNotEmpty);
      });
    },
  );
}
