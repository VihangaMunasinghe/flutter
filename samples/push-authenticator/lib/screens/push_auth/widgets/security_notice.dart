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
import 'package:flutter/material.dart';

/// Warning box shown below the security verification section title.
class SecurityNotice extends StatelessWidget {
  const SecurityNotice({required this.hasNumberChallenge, super.key});

  final bool hasNumberChallenge;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: hexToColor(colors.alert.warning.background),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hexToColor(colors.alert.warning.text)),
      ),
      child: Text(
        hasNumberChallenge
            ? PushAuthConstants.noticeNumberChallenge
            : PushAuthConstants.noticeApprove,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: hexToColor(colors.alert.warning.text),
          fontSize: 13,
        ),
      ),
    );
  }
}
