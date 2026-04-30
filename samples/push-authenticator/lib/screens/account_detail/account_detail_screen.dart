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

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/constants/screens/account_detail.dart';
import 'package:asgardeo_push_authenticator/providers/account_provider.dart';
import 'package:asgardeo_push_authenticator/providers/app_provider.dart';
import 'package:asgardeo_push_authenticator/providers/push_auth_provider.dart';
import 'package:asgardeo_push_authenticator/screens/account_detail/widgets/account_action_menu.dart';
import 'package:asgardeo_push_authenticator/screens/account_detail/widgets/account_header.dart';
import 'package:asgardeo_push_authenticator/screens/account_detail/widgets/push_auth_history_list.dart';
import 'package:asgardeo_push_authenticator/services/messaging_service.dart';
import 'package:asgardeo_push_authenticator/widgets/alert_dialog_widget.dart';
import 'package:asgardeo_push_authenticator/widgets/app_bar_title_widget.dart';
import 'package:asgardeo_push_authenticator/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Account detail screen — shows account info and inline push auth history.
class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({required this.accountId, super.key});

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  PushAuthAccount? _account;
  bool _isAlertVisible = false;
  AlertType _alertType = AlertType.loading;
  String _alertTitle = '';
  String _alertMessage = '';

  @override
  void initState() {
    super.initState();
    _account = ref
        .read(accountNotifierProvider)
        .value
        ?.where((a) => a.id == widget.accountId)
        .firstOrNull;
  }

  void _showAlert(AlertType type, String title, String message) {
    setState(() {
      _isAlertVisible = true;
      _alertType = type;
      _alertTitle = title;
      _alertMessage = message;
    });
  }

  void _hideAlert() => setState(() => _isAlertVisible = false);

  void _handleSdkException(
    AsgardeoException e, {
    required String fallbackTitle,
    required String fallbackMsg,
  }) {
    if (!mounted) return;
    if (e is AsgardeoDeviceNotFoundException) {
      _showAlert(
        AlertType.error,
        AccountDetailConstants.deviceNotFoundTitle,
        AccountDetailConstants.deviceNotFoundInfoMsg,
      );
    } else if (e is AsgardeoNetworkException) {
      _showAlert(
        AlertType.error,
        AccountDetailConstants.networkErrorTitle,
        AccountDetailConstants.networkErrorMsg,
      );
    } else {
      _showAlert(AlertType.error, fallbackTitle, fallbackMsg);
    }
  }

  Future<void> _deletePushDevice(PushAuthAccount account) async {
    _showAlert(
      AlertType.loading,
      AccountDetailConstants.deleteLoadingTitle,
      AccountDetailConstants.deleteLoadingMsg,
    );
    try {
      await ref
          .read(pushAuthNotifierProvider.notifier)
          .unregisterDevice(account.id);
      if (mounted) {
        _showAlert(
          AlertType.success,
          AccountDetailConstants.deleteSuccessTitle,
          AccountDetailConstants.deleteSuccessMsg,
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
      }
    } on AsgardeoDeviceNotFoundException {
      if (!mounted) return;
      _hideAlert();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmationDialog(
          title: AccountDetailConstants.deviceNotFoundTitle,
          message: AccountDetailConstants.deviceNotFoundMsg,
          confirmText: AccountDetailConstants.buttonRemove,
        ),
      );
      if (confirmed == true && mounted) {
        await ref
            .read(pushAuthNotifierProvider.notifier)
            .removeLocalAccount(account.id);
        if (mounted) {
          _showAlert(
            AlertType.success,
            AccountDetailConstants.deleteSuccessTitle,
            AccountDetailConstants.deleteSuccessMsg,
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.pop();
          });
        }
      }
    } on AsgardeoException catch (e) {
      _handleSdkException(
        e,
        fallbackTitle: AccountDetailConstants.deleteErrorTitle,
        fallbackMsg: AccountDetailConstants.deleteErrorMsg,
      );
    }
  }

  Future<void> _updateToken(PushAuthAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: AccountDetailConstants.updateTokenDialogTitle,
        message: AccountDetailConstants.updateTokenDialogMsg,
        confirmText: AccountDetailConstants.buttonUpdate,
      ),
    );
    if (confirmed != true || !mounted) return;

    _showAlert(
      AlertType.loading,
      AccountDetailConstants.updateTokenLoadingTitle,
      AccountDetailConstants.updateTokenLoadingMsg,
    );
    try {
      final newToken = await MessagingService.instance.refreshDeviceToken();
      if (newToken == null) throw Exception('Failed to get device token');
      await ref
          .read(pushAuthNotifierProvider.notifier)
          .editDevice(account.id, deviceToken: newToken);
      if (mounted) {
        _showAlert(
          AlertType.success,
          AccountDetailConstants.updateTokenSuccessTitle,
          AccountDetailConstants.updateTokenSuccessMsg,
        );
        Future.delayed(const Duration(seconds: 2), _hideAlert);
      }
    } on AsgardeoException catch (e) {
      _handleSdkException(
        e,
        fallbackTitle: AccountDetailConstants.updateTokenErrorTitle,
        fallbackMsg: AccountDetailConstants.updateTokenErrorMsg,
      );
    }
  }

  Future<void> _updateName(PushAuthAccount account) async {
    final nameController = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: AccountDetailConstants.updateNameDialogTitle,
        textFieldHint: AccountDetailConstants.updateNameHint,
        textFieldController: nameController,
        confirmText: AccountDetailConstants.buttonUpdate,
      ),
    );
    if (newName == null || newName.trim().isEmpty || !mounted) return;

    _showAlert(
      AlertType.loading,
      AccountDetailConstants.updateNameLoadingTitle,
      AccountDetailConstants.updateNameLoadingMsg,
    );
    try {
      await ref
          .read(pushAuthNotifierProvider.notifier)
          .editDevice(account.id, name: newName.trim());
      if (mounted) {
        _showAlert(
          AlertType.success,
          AccountDetailConstants.updateNameSuccessTitle,
          AccountDetailConstants.updateNameSuccessMsg,
        );
        Future.delayed(const Duration(seconds: 2), _hideAlert);
      }
    } on AsgardeoException catch (e) {
      _handleSdkException(
        e,
        fallbackTitle: AccountDetailConstants.updateNameErrorTitle,
        fallbackMsg: AccountDetailConstants.updateNameErrorMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConfig.instance.theme;
    final account = _account;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AccountDetailConstants.notFoundTitle)),
        body: const Center(child: Text(AccountDetailConstants.notFoundMsg)),
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
            actions: [
              AccountActionMenu(
                onUpdateToken: () => unawaited(_updateToken(account)),
                onUpdateName: () => unawaited(_updateName(account)),
                onDelete: () => unawaited(_deletePushDevice(account)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AccountDetailConstants.bodyPadding),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AccountHeader(account: account),
                  const SizedBox(height: AccountDetailConstants.headerSpacing),
                  PushAuthHistoryList(accountId: account.id),
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
                  _alertType == AlertType.error
                      ? AccountDetailConstants.buttonOk
                      : null,
              onPrimaryPress: _hideAlert,
              autoDismissTimeout:
                  _alertType == AlertType.success ? 2000 : null,
            ),
          ),
      ],
    );
  }
}
