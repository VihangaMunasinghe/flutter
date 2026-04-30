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

import 'dart:io';

import 'package:asgardeo_push_auth/src/device_info/platform_device_info_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'device_info_provider_contract.dart';

class _MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {}

void main() {
  late _MockDeviceInfoPlugin mockPlugin;

  setUp(() {
    mockPlugin = _MockDeviceInfoPlugin();
  });

  // The contract test uses platform-specific stubs based on the
  // current test runner platform.

  if (Platform.isAndroid) {
    _runAndroidTests(mockPlugin);
  } else if (Platform.isIOS) {
    _runIosTests(mockPlugin);
  } else {
    // Desktop / CI — Platform.isAndroid and Platform.isIOS are both
    // false, so PlatformDeviceInfoProvider returns 'Unknown'.
    runDeviceInfoProviderContractTests(
      implementationName: 'PlatformDeviceInfoProvider (fallback)',
      subjectFactory: () =>
          PlatformDeviceInfoProvider(deviceInfo: mockPlugin),
      arrangeDeviceInfo: () {
        // No stubs needed — the fallback path doesn't call the plugin.
      },
      expectedName: 'Unknown',
      expectedModel: 'Unknown',
    );
  }
}

void _runAndroidTests(_MockDeviceInfoPlugin mockPlugin) {
  runDeviceInfoProviderContractTests(
    implementationName: 'PlatformDeviceInfoProvider (Android)',
    subjectFactory: () =>
        PlatformDeviceInfoProvider(deviceInfo: mockPlugin),
    arrangeDeviceInfo: () {
      when(() => mockPlugin.androidInfo).thenAnswer(
        (_) async => AndroidDeviceInfo.fromMap({
          'model': 'Pixel 8',
          'brand': 'Google',
          'device': 'shiba',
          'display': 'AP2A',
          'fingerprint': 'google/shiba',
          'hardware': 'shiba',
          'host': 'build',
          'id': 'AP2A',
          'manufacturer': 'Google',
          'product': 'shiba',
          'tags': 'release-keys',
          'type': 'user',
          'isPhysicalDevice': true,
          'supported32BitAbis': <String>[],
          'supported64BitAbis': <String>['arm64-v8a'],
          'supportedAbis': <String>['arm64-v8a'],
          'systemFeatures': <String>[],
          'serialNumber': 'unknown',
          'board': 'shiba',
          'bootloader': 'unknown',
        }),
      );
    },
    expectedName: 'Pixel 8',
    expectedModel: 'Pixel 8',
  );
}

void _runIosTests(_MockDeviceInfoPlugin mockPlugin) {
  runDeviceInfoProviderContractTests(
    implementationName: 'PlatformDeviceInfoProvider (iOS)',
    subjectFactory: () =>
        PlatformDeviceInfoProvider(deviceInfo: mockPlugin),
    arrangeDeviceInfo: () {
      when(() => mockPlugin.iosInfo).thenAnswer(
        (_) async => IosDeviceInfo.fromMap({
          'name': 'iPhone 15 Pro',
          'systemName': 'iOS',
          'systemVersion': '17.0',
          'model': 'iPhone',
          'localizedModel': 'iPhone',
          'identifierForVendor': 'id-123',
          'isPhysicalDevice': true,
          'utsname': {
            'sysname': 'Darwin',
            'nodename': 'iPhone',
            'release': '23.0.0',
            'version': 'Darwin Kernel',
            'machine': 'iPhone16,1',
          },
        }),
      );
    },
    expectedName: 'iPhone 15 Pro',
    expectedModel: 'iPhone16,1',
  );
}
