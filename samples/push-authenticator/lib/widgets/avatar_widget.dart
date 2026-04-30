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
import 'package:asgardeo_push_authenticator/utils/avatar_colors.dart';
import 'package:asgardeo_push_authenticator/utils/get_initials.dart';
import 'package:flutter/material.dart';

/// 48×48 rounded-square avatar displaying initials with a deterministic color.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    required this.name,
    this.size = 48.0,
    super.key,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = getAvatarColors(name);
    final bgColor = hexToColor(colors.bg);
    final textColor = hexToColor(colors.text);
    final initials = getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
