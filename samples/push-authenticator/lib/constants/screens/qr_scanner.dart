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

import 'package:flutter/material.dart';

/// Constants for the QR scanner screen.
class QrScannerConstants {
  const QrScannerConstants._();

  // Layout
  static const double frameSize = 250;
  static const double backButtonTop = 50;
  static const double backButtonLeft = 20;
  static const double instructionsBottom = 80;
  static const double backButtonRadius = 20;
  static const Color overlayColor = Color(0x80000000);

  // Strings
  static const String instruction = 'Point your camera at the QR code';
  static const String invalidQrTitle = 'Invalid QR Code';
  static const String invalidQrMsg =
      'The scanned QR code is not a valid Asgardeo code.';
  static const String processingTitle = 'Processing';
  static const String processingMsg = 'Registering account...';
  static const String successTitle = 'Success';
  static const String successMsg = 'Push device registered successfully.';
  static const String errorTitle = 'Registration Failed';
  static const String networkErrorMsg =
      'Could not reach the server. '
      'Please check your connection and try again.';
  static const String alreadyRegisteredMsg =
      'An account is already registered. '
      'Remove the existing account before re-registering.';
  static const String serverRejectedMsg =
      'Registration was rejected by the server.';
  static const String invalidDataMsg = 'Invalid QR code data.';
  static const String genericErrorMsg =
      'Registration failed. Please try again.';
}
