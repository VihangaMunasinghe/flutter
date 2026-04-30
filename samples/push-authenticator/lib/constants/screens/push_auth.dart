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

/// Constants for the push authentication screen.
class PushAuthConstants {
  const PushAuthConstants._();

  // Layout
  static const double bodyPadding = 24;
  static const double cardPadding = 16;

  // Card header
  static const String cardTitle = 'Login Request';
  static const String cardSubtitle = 'Verify this login attempt to continue';

  // Section titles
  static const String sectionApp = 'Application Details';
  static const String sectionDevice = 'Device Details';
  static const String sectionSecurity = 'Security Verification';

  // Info row labels
  static const String labelOrg = 'Organization:';
  static const String labelApp = 'Application:';
  static const String labelUsername = 'Username:';
  static const String labelIp = 'IP Address:';
  static const String labelBrowser = 'Browser:';
  static const String labelOs = 'OS:';

  // Security notice text
  static const String noticeNumberChallenge =
      'If this login attempt is legitimate, tap '
      'the number displayed on your login screen to approve.';
  static const String noticeApprove =
      'If this login attempt is legitimate, '
      'tap the approve button below.';

  // Button labels
  static const String approveLabel = 'Approve';
  static const String denyLabel = 'Deny';

  // Response alerts
  static const String sendingTitle = 'Sending Response';
  static const String sendingMsg =
      'Please wait while we send your response...';
  static const String approvedTitle = 'Approved';
  static const String deniedTitle = 'Denied';
  static const String responseSuccessMsg =
      'Your response has been sent successfully.';
  static const String responseErrorTitle = 'Error';
  static const String responseErrorMsg =
      'Failed to send your response. Please try again.';

  // Specific error messages
  static const String accountNotFoundMsg =
      'The account associated with this request was not found.';
  static const String networkErrorMsg =
      'Could not reach the server. '
      'Please check your connection and try again.';

  // Not-found state
  static const String notFoundTitle = 'Push Authentication';
  static const String notFoundMsg = 'Push authentication request not found.';
}
