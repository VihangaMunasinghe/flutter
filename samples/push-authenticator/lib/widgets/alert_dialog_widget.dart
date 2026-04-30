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

import 'dart:async';

import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/providers/app_provider.dart';
import 'package:flutter/material.dart';

/// Full-screen overlay alert widget.
class AlertDialogWidget extends StatefulWidget {
  const AlertDialogWidget({
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPress,
    this.onSecondaryPress,
    this.autoDismissTimeout,
    super.key,
  });

  final AlertType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPress;
  final VoidCallback? onSecondaryPress;
  final int? autoDismissTimeout;

  @override
  State<AlertDialogWidget> createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<AlertDialogWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoDismissTimeout != null) {
      _timer = Timer(
        Duration(milliseconds: widget.autoDismissTimeout!),
        () => widget.onPrimaryPress?.call(),
      );
    }
  }

  @override
  void didUpdateWidget(AlertDialogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoDismissTimeout != widget.autoDismissTimeout) {
      _timer?.cancel();
      if (widget.autoDismissTimeout != null) {
        _timer = Timer(
          Duration(milliseconds: widget.autoDismissTimeout!),
          () => widget.onPrimaryPress?.call(),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final alertColors = _getAlertColors(colors);

    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 340),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: hexToColor(alertColors.background),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(alertColors.text),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: hexToColor(colors.primaryText),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  style: TextStyle(
                    color: hexToColor(colors.secondaryText),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.autoDismissTimeout != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Redirecting...',
                    style: TextStyle(
                      color: hexToColor(colors.secondaryText),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.primaryButtonText != null ||
                    widget.secondaryButtonText != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.secondaryButtonText != null)
                        TextButton(
                          onPressed: widget.onSecondaryPress,
                          child: Text(
                            widget.secondaryButtonText!,
                            style: TextStyle(
                                color: hexToColor(alertColors.text)),
                          ),
                        ),
                      if (widget.primaryButtonText != null)
                        ElevatedButton(
                          onPressed: widget.onPrimaryPress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hexToColor(alertColors.text),
                            foregroundColor:
                                hexToColor(alertColors.background),
                          ),
                          child: Text(widget.primaryButtonText!),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String colorHex) {
    if (widget.type == AlertType.loading) {
      return CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(hexToColor(colorHex)),
      );
    }
    return Icon(
      _iconData(),
      color: hexToColor(colorHex),
      size: 40,
    );
  }

  IconData _iconData() {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning_amber;
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.message:
        return Icons.message_outlined;
      case AlertType.loading:
        return Icons.hourglass_empty;
    }
  }

  AlertTypeColors _getAlertColors(ThemeColors colors) {
    switch (widget.type) {
      case AlertType.success:
        return colors.alert.success;
      case AlertType.error:
        return colors.alert.error;
      case AlertType.warning:
        return colors.alert.warning;
      case AlertType.info:
        return colors.alert.info;
      case AlertType.loading:
        return colors.alert.loading;
      case AlertType.message:
        return colors.alert.message;
    }
  }
}
