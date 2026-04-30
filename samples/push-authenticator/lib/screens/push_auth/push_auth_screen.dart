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

import 'dart:math';

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/constants/screens/push_auth.dart';
import 'package:asgardeo_push_authenticator/providers/app_provider.dart';
import 'package:asgardeo_push_authenticator/providers/push_auth_provider.dart';
import 'package:asgardeo_push_authenticator/screens/push_auth/widgets/action_buttons.dart';
import 'package:asgardeo_push_authenticator/screens/push_auth/widgets/info_section.dart';
import 'package:asgardeo_push_authenticator/screens/push_auth/widgets/request_header.dart';
import 'package:asgardeo_push_authenticator/screens/push_auth/widgets/security_notice.dart';
import 'package:asgardeo_push_authenticator/widgets/alert_dialog_widget.dart';
import 'package:asgardeo_push_authenticator/widgets/app_bar_title_widget.dart';
import 'package:asgardeo_push_authenticator/widgets/info_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Push authentication screen — shows login request details and approve/deny actions.
class PushAuthScreen extends ConsumerStatefulWidget {
  const PushAuthScreen({required this.pushId, super.key});

  final String pushId;

  @override
  ConsumerState<PushAuthScreen> createState() => _PushAuthScreenState();
}

class _PushAuthScreenState extends ConsumerState<PushAuthScreen> {
  PushAuthRequest? _pushData;
  List<int>? _numberOptions;
  bool _isAlertVisible = false;
  AlertType _alertType = AlertType.loading;
  String _alertTitle = '';
  String _alertMessage = '';

  @override
  void initState() {
    super.initState();
    _pushData = ref.read(pushAuthNotifierProvider)[widget.pushId];
    _buildNumberOptions();
  }

  void _buildNumberOptions() {
    final pushData = _pushData;
    if (pushData?.numberChallenge == null) return;

    final correct = int.tryParse(pushData!.numberChallenge!);
    if (correct == null) return;

    final rng = Random();
    final options = <int>{correct};
    while (options.length < 3) {
      options.add(rng.nextInt(90) + 10);
    }
    setState(() => _numberOptions = options.toList()..shuffle(rng));
  }

  void _showAlert(AlertType type, String title, String message) {
    setState(() {
      _isAlertVisible = true;
      _alertType = type;
      _alertTitle = title;
      _alertMessage = message;
    });
  }

  Future<void> _respond(
    PushAuthResponseStatus status, {
    int? selectedNumber,
  }) async {
    final pushData = _pushData;
    if (pushData == null || !mounted) return;

    _showAlert(
      AlertType.loading,
      PushAuthConstants.sendingTitle,
      PushAuthConstants.sendingMsg,
    );

    try {
      await ref.read(pushAuthNotifierProvider.notifier).sendResponse(
            pushData,
            status,
            selectedNumber: selectedNumber,
          );
      if (mounted) {
        _showAlert(
          AlertType.success,
          status == PushAuthResponseStatus.approved
              ? PushAuthConstants.approvedTitle
              : PushAuthConstants.deniedTitle,
          PushAuthConstants.responseSuccessMsg,
        );
      }
    } on AsgardeoAccountNotFoundException {
      if (mounted) {
        _showAlert(
          AlertType.error,
          PushAuthConstants.responseErrorTitle,
          PushAuthConstants.accountNotFoundMsg,
        );
      }
    } on AsgardeoNetworkException {
      if (mounted) {
        _showAlert(
          AlertType.error,
          PushAuthConstants.responseErrorTitle,
          PushAuthConstants.networkErrorMsg,
        );
      }
    } on AsgardeoException {
      if (mounted) {
        _showAlert(
          AlertType.error,
          PushAuthConstants.responseErrorTitle,
          PushAuthConstants.responseErrorMsg,
        );
      }
    }
  }

  Future<void> _onNumberTap(int number) async {
    final pushData = _pushData;
    final correct = int.tryParse(pushData?.numberChallenge ?? '');

    if (number == correct) {
      await _respond(PushAuthResponseStatus.approved, selectedNumber: number);
    } else {
      await _respond(PushAuthResponseStatus.denied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pushData = _pushData;
    final colors = AppConfig.instance.theme;

    if (pushData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(PushAuthConstants.notFoundTitle)),
        body: const Center(child: Text(PushAuthConstants.notFoundMsg)),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: hexToColor(colors.screenBackground),
          appBar: AppBar(
            title: const AppBarTitleWidget(),
            centerTitle: false,
            backgroundColor: hexToColor(colors.headerBackground),
            leading: BackButton(color: hexToColor(colors.headerText)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(PushAuthConstants.bodyPadding),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PushAuthConstants.cardPadding),
              decoration: BoxDecoration(
                color: hexToColor(colors.cardBackground),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hexToColor(colors.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequestHeader(sentTime: pushData.sentTime),
                  Divider(height: 1, color: hexToColor(colors.cardBorder)),

                  const SizedBox(height: 16),

                  InfoSection(
                    title: PushAuthConstants.sectionApp,
                    children: [
                      InfoRowWidget(
                        label: PushAuthConstants.labelOrg,
                        value: pushData.organizationName ??
                            pushData.tenantDomain,
                      ),
                      InfoRowWidget(
                        label: PushAuthConstants.labelApp,
                        value: pushData.applicationName,
                      ),
                      InfoRowWidget(
                        label: PushAuthConstants.labelUsername,
                        value: pushData.username,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  InfoSection(
                    title: PushAuthConstants.sectionDevice,
                    children: [
                      InfoRowWidget(
                        label: PushAuthConstants.labelIp,
                        value: pushData.ipAddress,
                      ),
                      InfoRowWidget(
                        label: PushAuthConstants.labelBrowser,
                        value: pushData.browser,
                      ),
                      InfoRowWidget(
                        label: PushAuthConstants.labelOs,
                        value: pushData.deviceOS,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Divider(height: 1, color: hexToColor(colors.cardBorder)),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        InfoSection(
                          title: PushAuthConstants.sectionSecurity,
                          children: [
                            SecurityNotice(
                              hasNumberChallenge:
                                  pushData.numberChallenge != null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ActionButtons(
                    onApprove: () => _respond(PushAuthResponseStatus.approved),
                    onDeny: () => _respond(PushAuthResponseStatus.denied),
                    numberOptions: _numberOptions,
                    numberChallenge: pushData.numberChallenge,
                    onNumberTap: _onNumberTap,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isAlertVisible)
          Positioned.fill(
            child: AlertDialogWidget(
              key: ValueKey(_alertType),
              type: _alertType,
              title: _alertTitle,
              message: _alertMessage,
              primaryButtonText:
                  _alertType == AlertType.error ? 'OK' : null,
              onPrimaryPress: () {
                setState(() => _isAlertVisible = false);
                if (_alertType == AlertType.success) context.pop();
              },
              autoDismissTimeout:
                  _alertType == AlertType.success ? 2000 : null,
            ),
          ),
      ],
    );
  }
}
