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

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/constants/screens/account_detail.dart';
import 'package:asgardeo_push_authenticator/utils/get_username.dart';
import 'package:asgardeo_push_authenticator/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// Avatar, username, and organisation row for an account.
class AccountHeader extends StatelessWidget {
  const AccountHeader({required this.account, super.key});

  final PushAuthAccount account;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final username = getUsername(account.username);

    return Column(
      children: [
        AvatarWidget(
          name: username,
          size: AccountDetailConstants.avatarSize,
        ),
        const SizedBox(height: 8),
        Text(
          username,
          style: TextStyle(
            color: hexToColor(colors.primaryText),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(
              Icons.business_outlined,
              size: AccountDetailConstants.orgIconSize,
              color: hexToColor(colors.secondaryText),
            ),
            const SizedBox(width: 5),
            Text(
              account.displayName,
              style: TextStyle(
                color: hexToColor(colors.secondaryText),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
