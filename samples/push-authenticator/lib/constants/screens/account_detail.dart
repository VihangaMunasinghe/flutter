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

/// Constants for the account detail screen.
class AccountDetailConstants {
  const AccountDetailConstants._();

  // Layout
  static const double bodyPadding = 24;
  static const double avatarSize = 56;
  static const double orgIconSize = 14;
  static const double headerSpacing = 32;

  // Menu action keys
  static const String menuUpdateToken = 'update_token';
  static const String menuUpdateName = 'update_name';
  static const String menuDeletePush = 'delete_push';

  // Menu item labels
  static const String labelUpdateToken = 'Update Token';
  static const String labelUpdateName = 'Update Name';
  static const String labelDeletePush = 'Delete Push Device';

  // Delete device flow
  static const String deleteLoadingTitle = 'Unregistering';
  static const String deleteLoadingMsg = 'Removing push device...';
  static const String deleteSuccessTitle = 'Removed';
  static const String deleteSuccessMsg = 'Push device removed.';
  static const String deleteErrorTitle = 'Error';
  static const String deleteErrorMsg = 'Failed to remove push device.';

  // Update token flow
  static const String updateTokenDialogTitle = 'Update Token';
  static const String updateTokenDialogMsg =
      'Update the push notification token for this device?';
  static const String updateTokenLoadingTitle = 'Updating';
  static const String updateTokenLoadingMsg = 'Updating device token...';
  static const String updateTokenSuccessTitle = 'Updated';
  static const String updateTokenSuccessMsg = 'Device token updated.';
  static const String updateTokenErrorTitle = 'Error';
  static const String updateTokenErrorMsg = 'Failed to update device token.';

  // Update name flow
  static const String updateNameDialogTitle = 'Update Device Name';
  static const String updateNameHint = 'Enter new device name';
  static const String updateNameLoadingTitle = 'Updating';
  static const String updateNameLoadingMsg = 'Updating device name...';
  static const String updateNameSuccessTitle = 'Updated';
  static const String updateNameSuccessMsg = 'Device name updated.';
  static const String updateNameErrorTitle = 'Error';
  static const String updateNameErrorMsg = 'Failed to update device name.';

  // Dialog shared buttons
  static const String buttonCancel = 'Cancel';
  static const String buttonUpdate = 'Update';
  static const String buttonOk = 'OK';

  // Device not found (server-side removal)
  static const String deviceNotFoundTitle = 'Device Not Found';
  static const String deviceNotFoundMsg =
      'This device is no longer registered on the server. '
      'Would you like to remove the local account data?';
  static const String deviceNotFoundInfoMsg =
      'This device is no longer registered on the server.';
  static const String buttonRemove = 'Remove';

  // Network error
  static const String networkErrorTitle = 'Network Error';
  static const String networkErrorMsg =
      'Could not reach the server. '
      'Please check your connection and try again.';

  // Not-found state
  static const String notFoundTitle = 'Account';
  static const String notFoundMsg = 'Account not found.';
}
