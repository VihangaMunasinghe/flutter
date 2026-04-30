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
import 'package:asgardeo_push_authenticator/constants/screens/push_auth.dart';
import 'package:asgardeo_push_authenticator/utils/time_from_now.dart';
import 'package:flutter/material.dart';

/// Card header: title, subtitle, and received-time text.
class RequestHeader extends StatelessWidget {
  const RequestHeader({required this.sentTime, super.key});

  final int? sentTime;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PushAuthConstants.cardTitle,
            style: TextStyle(
              color: hexToColor(colors.primaryText),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            PushAuthConstants.cardSubtitle,
            style: TextStyle(
              color: hexToColor(colors.secondaryText),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Received ${timeFromNow(sentTime ?? 0)}',
            style: TextStyle(
              color: hexToColor(colors.secondaryText),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
