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
import 'package:asgardeo_push_authenticator/constants/screens/home.dart';
import 'package:flutter/material.dart';

/// Search input styled as a card row.
class SearchBox extends StatelessWidget {
  const SearchBox({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: hexToColor(colors.cardBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hexToColor(colors.cardBorder)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: hexToColor(colors.primaryText)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: hexToColor(colors.primaryText)),
              decoration: InputDecoration.collapsed(
                hintText: HomeConstants.searchHint,
                hintStyle: TextStyle(color: hexToColor(colors.primaryText)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
