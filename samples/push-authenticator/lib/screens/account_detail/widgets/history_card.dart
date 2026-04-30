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
import 'package:asgardeo_push_authenticator/widgets/info_row_widget.dart';
import 'package:flutter/material.dart';

const _successColor = Color(0xFF10b981);
const _errorColor = Color(0xFFef4444);

/// A single push authentication history entry card.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    required this.record,
    required this.timeAgo,
    super.key,
  });

  final PushAuthRecord record;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final isApproved = record.status == 'APPROVED';
    final statusColor = isApproved ? _successColor : _errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hexToColor(colors.cardBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hexToColor(colors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + status icon
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isApproved ? 'Successful Login' : 'Denied Login',
                        style: TextStyle(
                          color: isApproved
                              ? hexToColor(colors.alert.success.text)
                              : hexToColor(colors.alert.error.text),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: hexToColor(colors.secondaryText),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isApproved ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 38,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: hexToColor(colors.cardBorder)),

          const SizedBox(height: 16),

          // Detail rows
          InfoRowWidget(label: 'Application:', value: record.applicationName),
          const SizedBox(height: 6),
          InfoRowWidget(
            label: 'IP Address:',
            value: record.ipAddress.isNotEmpty ? record.ipAddress : '—',
          ),
          const SizedBox(height: 6),
          InfoRowWidget(
            label: 'Browser:',
            value: record.browser.isNotEmpty ? record.browser : '—',
          ),
          const SizedBox(height: 6),
          InfoRowWidget(
            label: 'Operating System:',
            value: record.deviceOS.isNotEmpty ? record.deviceOS : '—',
          ),
        ],
      ),
    );
  }
}
