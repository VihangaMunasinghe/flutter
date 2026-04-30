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

import 'package:asgardeo_push_auth/src/device_info/asgardeo_device_info_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// [AsgardeoDeviceInfoProvider] implementation using `device_info_plus`.
class PlatformDeviceInfoProvider implements AsgardeoDeviceInfoProvider {

  /// Creates a [PlatformDeviceInfoProvider].
  ///
  /// An optional [deviceInfo] plugin can be provided for testing.
  PlatformDeviceInfoProvider({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  @override
  Future<({String name, String model})> getDeviceInfo() async {

    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return (name: info.model, model: info.model);
    }

    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return (name: info.name, model: info.utsname.machine);
    }

    return (name: 'Unknown', model: 'Unknown');
  }
}
