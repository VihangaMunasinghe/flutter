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

/// Circular number button used for number-challenge push auth.
class NumberButton extends StatelessWidget {
  const NumberButton({
    required this.number,
    required this.onTap,
    this.numberChallenge,
    super.key,
  });

  final int number;
  final String? numberChallenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;

    // Pad single-digit challenge numbers with a leading zero.
    final displayText = (numberChallenge?.length == 1 &&
            number == int.tryParse(numberChallenge ?? ''))
        ? '0$number'
        : '$number';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: hexToColor(colors.button.primary.background),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: hexToColor(colors.button.primary.text),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
