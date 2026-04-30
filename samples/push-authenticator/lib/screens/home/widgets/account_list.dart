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
import 'package:asgardeo_push_authenticator/constants/screens/home.dart';
import 'package:asgardeo_push_authenticator/screens/home/widgets/account_list_item.dart';
import 'package:asgardeo_push_authenticator/screens/home/widgets/search_box.dart';
import 'package:flutter/material.dart';

/// Scrollable account list with an integrated search box.
class AccountList extends StatelessWidget {
  const AccountList({
    required this.accounts,
    required this.controller,
    required this.onSearchChanged,
    required this.onAccountTap,
    super.key,
  });

  final List<PushAuthAccount> accounts;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final void Function(String accountId) onAccountTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HomeConstants.listPadding),
      children: [
        SearchBox(controller: controller, onChanged: onSearchChanged),
        for (int i = 0; i < accounts.length; i++) ...[
          if (i > 0) const SizedBox(height: HomeConstants.itemGap),
          AccountListItem(
            account: accounts[i],
            onTap: () => onAccountTap(accounts[i].id),
          ),
        ],
      ],
    );
  }
}
