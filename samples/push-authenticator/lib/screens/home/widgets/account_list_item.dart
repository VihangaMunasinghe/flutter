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
import 'package:asgardeo_push_authenticator/utils/get_username.dart';
import 'package:asgardeo_push_authenticator/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A single row in the registered account list.
class AccountListItem extends StatelessWidget {
  const AccountListItem({
    required this.account,
    required this.onTap,
    super.key,
  });

  final PushAuthAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final username = getUsername(account.username);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hexToColor(colors.cardBackground),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hexToColor(colors.cardBorder)),
        ),
        child: Row(
          children: [
            AvatarWidget(name: username),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hexToColor(colors.primaryText),
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Icon(Icons.business_outlined,
                          size: 14,
                          color: hexToColor(colors.secondaryText)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          account.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hexToColor(colors.secondaryText),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Icon(
              Icons.chevron_right,
              size: 26,
              color: hexToColor(colors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
