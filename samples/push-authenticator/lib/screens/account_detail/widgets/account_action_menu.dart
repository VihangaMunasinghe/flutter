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
import 'package:asgardeo_push_authenticator/constants/screens/account_detail.dart';
import 'package:flutter/material.dart';

/// Three-item popup menu (update token, update name, delete push device).
class AccountActionMenu extends StatelessWidget {
  const AccountActionMenu({
    required this.onUpdateToken,
    required this.onUpdateName,
    required this.onDelete,
    super.key,
  });

  final VoidCallback onUpdateToken;
  final VoidCallback onUpdateName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: hexToColor(colors.headerText)),
      onSelected: (val) {
        if (val == AccountDetailConstants.menuUpdateToken) onUpdateToken();
        if (val == AccountDetailConstants.menuUpdateName) onUpdateName();
        if (val == AccountDetailConstants.menuDeletePush) onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: AccountDetailConstants.menuUpdateToken,
          child: Row(
            children: [
              Icon(
                Icons.refresh,
                size: 20,
                color: hexToColor(colors.primaryText),
              ),
              const SizedBox(width: 8),
              Text(
                AccountDetailConstants.labelUpdateToken,
                style: TextStyle(
                  color: hexToColor(colors.primaryText),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: AccountDetailConstants.menuUpdateName,
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: hexToColor(colors.primaryText),
              ),
              const SizedBox(width: 8),
              Text(
                AccountDetailConstants.labelUpdateName,
                style: TextStyle(
                  color: hexToColor(colors.primaryText),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: AccountDetailConstants.menuDeletePush,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: hexToColor(colors.alert.error.text),
              ),
              const SizedBox(width: 8),
              Text(
                AccountDetailConstants.labelDeletePush,
                style: TextStyle(
                  color: hexToColor(colors.alert.error.text),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
