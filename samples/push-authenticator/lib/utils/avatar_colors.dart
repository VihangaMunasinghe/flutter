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

import 'package:asgardeo_push_authenticator/config/app_config.dart';

/// Returns the avatar [AvatarColorPair] for [name] using a deterministic hash.
AvatarColorPair getAvatarColors(String name) {
  final colors = AppConfig.instance.theme.avatar;
  if (colors.isEmpty) {
    return const AvatarColorPair(bg: '#6B7280', text: '#FFFFFF');
  }

  // Port of the JS hash: hash = charCode + ((hash << 5) - hash)
  var hash = 0;
  for (var i = 0; i < name.length; i++) {
    // JavaScript uses 32-bit signed integers; Dart uses 64-bit.
    // We replicate JS behavior by masking to 32 bits after each operation.
    hash = _toInt32(name.codeUnitAt(i) + _toInt32(_toInt32(hash << 5) - hash));
  }

  final index = hash.abs() % colors.length;
  return colors[index];
}

/// Truncates [value] to a 32-bit signed integer,
/// matching JavaScript's bitwise behavior.
int _toInt32(int value) => value.toSigned(32);
