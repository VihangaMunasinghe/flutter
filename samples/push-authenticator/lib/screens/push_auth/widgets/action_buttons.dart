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
import 'package:asgardeo_push_authenticator/screens/push_auth/widgets/number_button.dart';
import 'package:flutter/material.dart';

/// Approve/deny buttons, or a row of number-challenge buttons.
class ActionButtons extends StatelessWidget {
  const ActionButtons({
    required this.onApprove,
    required this.onDeny,
    this.numberOptions,
    this.numberChallenge,
    this.onNumberTap,
    super.key,
  });

  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final List<int>? numberOptions;
  final String? numberChallenge;
  final void Function(int)? onNumberTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    return Column(
      children: [
        if (numberOptions != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: numberOptions!
                .map(
                  (n) => NumberButton(
                    number: n,
                    numberChallenge: numberChallenge,
                    onTap: () => onNumberTap?.call(n),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onApprove,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: hexToColor(colors.button.primary.background),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  PushAuthConstants.approveLabel,
                  style: TextStyle(
                    color: hexToColor(colors.button.primary.text),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onDeny,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: hexToColor(colors.button.secondary.background),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                PushAuthConstants.denyLabel,
                style: TextStyle(
                  color: hexToColor(colors.button.secondary.text),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
