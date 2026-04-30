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
import 'package:flutter/material.dart';

/// Empty state card shown when there is no push auth history.
class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return Container(
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: hexToColor(colors.cardBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hexToColor(colors.cardBorder)),
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: hexToColor(colors.primaryText),
            ),
            const SizedBox(height: 16),
            Text(
              'No Push Login History',
              style: TextStyle(
                color: hexToColor(colors.primaryText),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "You haven't received any push login requests yet. "
              'When you receive login requests that require push '
              'login, they will appear here with details about the '
              'application, device, and your response.',
              style: TextStyle(
                color: hexToColor(colors.secondaryText),
                fontSize: 14,
                height: 1.43,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
