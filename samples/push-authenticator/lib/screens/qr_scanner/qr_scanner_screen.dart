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
import 'package:asgardeo_push_authenticator/constants/screens/qr_scanner.dart';
import 'package:asgardeo_push_authenticator/providers/app_provider.dart';
import 'package:asgardeo_push_authenticator/providers/push_auth_provider.dart';
import 'package:asgardeo_push_authenticator/screens/qr_scanner/widgets/scan_back_button.dart';
import 'package:asgardeo_push_authenticator/screens/qr_scanner/widgets/scan_frame_painter.dart';
import 'package:asgardeo_push_authenticator/screens/qr_scanner/widgets/scan_instructions.dart';
import 'package:asgardeo_push_authenticator/utils/qr_validator.dart';
import 'package:asgardeo_push_authenticator/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner with overlay frame.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _scanned = false;
  bool _isAlertVisible = false;
  AlertType _alertType = AlertType.loading;
  String _alertTitle = '';
  String _alertMessage = '';
  String? _pendingAccountId;

  void _showAlert(AlertType type, String title, String message) {
    setState(() {
      _isAlertVisible = true;
      _alertType = type;
      _alertTitle = title;
      _alertMessage = message;
    });
  }

  void _showRegistrationError(Object e) {
    final message = switch (e) {
      AsgardeoDeviceAlreadyRegisteredException() =>
        QrScannerConstants.alreadyRegisteredMsg,
      AsgardeoNetworkException() => QrScannerConstants.networkErrorMsg,
      AsgardeoRegistrationException() => QrScannerConstants.serverRejectedMsg,
      AsgardeoValidationException() => QrScannerConstants.invalidDataMsg,
      _ => QrScannerConstants.genericErrorMsg,
    };
    _showAlert(AlertType.error, QrScannerConstants.errorTitle, message);
  }

  void _hideAlertAndNavigate() {
    setState(() => _isAlertVisible = false);
    if (_pendingAccountId != null) {
      context.go('/account/$_pendingAccountId');
    } else {
      context.pop();
    }
  }

  void _hideAlertAndPop() {
    setState(() => _isAlertVisible = false);
    context.pop();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _scanned = true;
    final result = validateQRData(barcode.rawValue!);

    if (result == null) {
      _showAlert(
        AlertType.error,
        QrScannerConstants.invalidQrTitle,
        QrScannerConstants.invalidQrMsg,
      );
      setState(() => _scanned = false);
      return;
    }

    _showAlert(
      AlertType.loading,
      QrScannerConstants.processingTitle,
      QrScannerConstants.processingMsg,
    );

    try {
      final accountId = await ref
          .read(pushAuthNotifierProvider.notifier)
          .registerDevice(result);
      if (mounted) {
        _pendingAccountId = accountId;
        _showAlert(
          AlertType.success,
          QrScannerConstants.successTitle,
          QrScannerConstants.successMsg,
        );
      }
    } on Object catch (e) {
      if (mounted) _showRegistrationError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              MobileScanner(onDetect: _onDetect),
              const ScanOverlay(),
              ScanBackButton(onTap: () => context.pop()),
              const ScanInstructions(),
            ],
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
              onPrimaryPress: _alertType == AlertType.success
                  ? _hideAlertAndNavigate
                  : _hideAlertAndPop,
              autoDismissTimeout:
                  _alertType == AlertType.success ? 2000 : null,
            ),
          ),
      ],
    );
  }
}
