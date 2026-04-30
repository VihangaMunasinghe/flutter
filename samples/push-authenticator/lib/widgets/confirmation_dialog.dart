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

/// Reusable confirmation dialog styled with app theme colors.
///
/// Supports two variants:
/// - **Confirm**: shows [message] text with Cancel / Confirm buttons.
/// - **Input**: shows a [TextField] with Cancel / Confirm buttons.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    this.message,
    this.textFieldHint,
    this.textFieldController,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    super.key,
  });

  final String title;
  final String? message;
  final String? textFieldHint;
  final TextEditingController? textFieldController;
  final String cancelText;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final primaryColor = hexToColor(colors.button.primary.background);

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: hexToColor(colors.primaryText),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: message != null
          ? Text(
              message!,
              style: TextStyle(
                color: hexToColor(colors.secondaryText),
                fontSize: 14,
              ),
            )
          : TextField(
              controller: textFieldController,
              autofocus: true,
              cursorColor: primaryColor,
              decoration: InputDecoration(
                hintText: textFieldHint,
                hintStyle: TextStyle(
                  color: hexToColor(colors.secondaryText),
                  fontSize: 14,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: hexToColor(colors.secondaryText),
          ),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            if (textFieldController != null) {
              Navigator.of(context).pop(textFieldController!.text);
            } else {
              Navigator.of(context).pop(true);
            }
          },
          style: TextButton.styleFrom(foregroundColor: primaryColor),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
