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
import 'package:asgardeo_push_auth_example/mock_http_manager.dart';
import 'package:flutter/material.dart';

// ─── Brand & palette ─────────────────────────────────────────────────────────
const _kBrandOrange = Color(0xFFFF7300);
const _kOrangeBg = Color(0xFFFFF3E0);
const _kGreen = Color(0xFF4CAF50);
const _kGreenBg = Color(0xFFE8F5E9);
const _kRed = Color(0xFFE53935);
const _kRedBg = Color(0xFFFFEBEE);
const _kGray = Color(0xFF56585E);
const _kGrayBg = Color(0xFFF0F1F3);

// ─── Dummy data ─────────────────────────────────────────────────────────────
//
// In a real app:
//   • _kQrJson  — raw JSON from scanning the Asgardeo console QR code.
//   • _kFcmToken — push token from FirebaseMessaging.instance.getToken().
//
// The mock HTTP manager returns fake success responses, so no real server
// is needed. The SDK's crypto operations (key pair generation, signing)
// still run on the real platform.

const _kQrJson = '{"deviceId":"mock-device-001","challenge":"bW9jaw==",'
    '"username":"alice@example.com","host":"mock.asgardeo.io",'
    '"tenantDomain":"mock-org"}';

const _kFcmToken = 'mock-fcm-token-12345';

// In a real app, _kBaseUrl is your Asgardeo server URL and _kAccessToken is
// a valid OAuth2 Bearer token obtained via the standard OIDC auth flow.
const _kBaseUrl = 'https://mock.asgardeo.io';
const _kAccessToken = 'mock-access-token-12345';

// Dummy push notification payload — deviceId must match the registered device.
const _kPushPayload = <String, dynamic>{
  'pushId': 'mock-push-001',
  'challenge': 'mock-challenge',
  'deviceId': 'mock-device-001',
  'applicationName': 'Mock App',
  'username': 'alice@example.com',
  'tenantDomain': 'mock-org',
  'userStoreDomain': 'PRIMARY',
  'notificationScenario': 'PUSH_AUTHENTICATION',
  'relativePath': '/t/mock-org',
  'ipAddress': '192.168.1.100',
  'browser': 'Chrome 120',
  'deviceOS': 'macOS 14',
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Initialize the SDK ──────────────────────────────────────────────────
  //
  // In a real app, omit `mockHttpManager` — the SDK uses the built-in HTTP 
  // client or else you can provide your own implementation.
  // All other builder parameters are optional; defaults are shown here.
  (AsgardeoPushAuthBuilder()
        ..httpManager = MockHttpManager() // Remove for production.
        ..logLevel = LogLevel.debug
        ..maxHistoryRecords = 50)
      .build();

  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asgardeo Push Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _kBrandOrange),
      ),
      home: const _ExamplePage(),
    );
  }
}

class _ExamplePage extends StatefulWidget {
  const _ExamplePage();

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  final AsgardeoPushAuth _sdk = AsgardeoPushAuth.instance;

  String _status = 'Tap a row to run an SDK operation.';
  bool _loading = false;

  // Stored after registerDevice — used by subsequent operations.
  String? _accountId;

  // Stored after parsePushNotification — used by approve / deny.
  PushAuthRequest? _pushRequest;

  void _setStatus(String msg) => setState(() {
        _status = msg;
        _loading = false;
      });

  void _setLoading() => setState(() => _loading = true);

  // ─── 1a. Register device (QR) ───────────────────────────────────────────
  //
  // Parses the QR code JSON, generates a key pair, signs the challenge,
  // and sends a registration request to the Asgardeo server.
  Future<void> _register() async {
    _setLoading();
    try {
      final accountId = await _sdk.registerDevice(
        _kQrJson,
        _kFcmToken,
        AmazonSNSPushProvider(AmazonSNSPlatform.fcm),
      );
      _accountId = accountId;
      _setStatus('Registered. Account ID: $accountId');
    } on AsgardeoValidationException catch (e) {
      _setStatus('Validation error: ${e.message}');
    } on AsgardeoDeviceAlreadyRegisteredException catch (e) {
      _setStatus('Account already registered: ${e.message}');
    } on AsgardeoRegistrationException catch (e) {
      _setStatus('Registration failed: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    }
  }

  // ─── 1b. Register device (token) ────────────────────────────────────────
  //
  // Fetches the registration payload from the server's discovery-data
  // endpoint using an OAuth2 access token, then completes device
  // registration without scanning a QR code.
  Future<void> _registerWithToken() async {
    _setLoading();
    try {
      final accountId = await _sdk.registerDeviceWithToken(
        _kBaseUrl,
        _kAccessToken,
        _kFcmToken,
        AmazonSNSPushProvider(AmazonSNSPlatform.fcm),
      );
      _accountId = accountId;
      _setStatus('Registered with token. Account ID: $accountId');
    } on AsgardeoValidationException catch (e) {
      _setStatus('Validation error: ${e.message}');
    } on AsgardeoDeviceAlreadyRegisteredException catch (e) {
      _setStatus('Account already registered: ${e.message}');
    } on AsgardeoRegistrationException catch (e) {
      _setStatus('Registration failed: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    }
  }

  // ─── 2. Parse push notification ─────────────────────────────────────────
  //
  // Converts the raw FCM / APNs payload into a typed PushAuthRequest.
  // No network call — pure local parsing.
  void _parsePush() {
    final request = _sdk.parsePushNotification(_kPushPayload);
    if (request == null) {
      _setStatus('Unrecognised push payload structure.');
      return;
    }
    _pushRequest = request;
    _setStatus(
      'Parsed push request.\n'
      'App: ${request.applicationName}\n'
      'User: ${request.username}\n'
      'IP: ${request.ipAddress}\n'
      'Number challenge: ${request.numberChallenge ?? "none"}',
    );
  }

  // ─── 3. Approve ─────────────────────────────────────────────────────────
  //
  // Signs the challenge with the stored private key and sends an APPROVED
  // response. For number-challenge flows, pass the selected number.
  Future<void> _approve() async {
    final request = _pushRequest;
    if (request == null) {
      _setStatus('Parse a push notification first (step 2).');
      return;
    }
    _setLoading();
    try {
      await _sdk.sendAuthResponse(request, PushAuthResponseStatus.approved);
      _setStatus('Approved. Response sent successfully.');
    } on AsgardeoAccountNotFoundException catch (e) {
      _setStatus('Account not found: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    } on AsgardeoAuthResponseException catch (e) {
      _setStatus('Auth response error: ${e.message}');
    }
  }

  // ─── 4. Deny ────────────────────────────────────────────────────────────
  Future<void> _deny() async {
    final request = _pushRequest;
    if (request == null) {
      _setStatus('Parse a push notification first (step 2).');
      return;
    }
    _setLoading();
    try {
      await _sdk.sendAuthResponse(request, PushAuthResponseStatus.denied);
      _setStatus('Denied. Response sent successfully.');
    } on AsgardeoAccountNotFoundException catch (e) {
      _setStatus('Account not found: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    } on AsgardeoAuthResponseException catch (e) {
      _setStatus('Auth response error: ${e.message}');
    }
  }

  // ─── 5. Update push token ────────────────────────────────────────────────
  //
  // Call when the FCM / APNs token is refreshed by the platform.
  Future<void> _updateToken() async {
    final accountId = _accountId;
    if (accountId == null) {
      _setStatus('Register a device first (step 1).');
      return;
    }
    _setLoading();
    try {
      await _sdk.updateDevice(accountId, pushToken: 'new-mock-fcm-token-99999');
      _setStatus('Push token updated.');
    } on AsgardeoDeviceNotFoundException catch (e) {
      _setStatus('Device not found on server: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    }
  }

  // ─── 6. Rename device ────────────────────────────────────────────────────
  //
  // Updates the display name of the device on the Asgardeo server.
  Future<void> _rename() async {
    final accountId = _accountId;
    if (accountId == null) {
      _setStatus('Register a device first (step 1).');
      return;
    }
    _setLoading();
    try {
      await _sdk.updateDevice(accountId, name: "Alice's iPhone");
      _setStatus('Device renamed.');
    } on AsgardeoDeviceNotFoundException catch (e) {
      _setStatus('Device not found on server: ${e.message}');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    }
  }

  // ─── 7. List accounts ────────────────────────────────────────────────────
  //
  // Returns all accounts stored in local storage.
  Future<void> _listAccounts() async {
    final accounts = await _sdk.getAccounts();
    if (accounts.isEmpty) {
      _setStatus('No accounts registered yet.');
      return;
    }
    final summary = accounts
        .map((a) => '• ${a.username} (${a.organizationName ?? a.tenantDomain})')
        .join('\n');
    _setStatus('Accounts (${accounts.length}):\n$summary');
  }

  // ─── 8. View auth history ────────────────────────────────────────────────
  //
  // Returns the auth history for the current account from local storage.
  Future<void> _viewHistory() async {
    final accountId = _accountId;
    if (accountId == null) {
      _setStatus('Register a device first (step 1).');
      return;
    }
    final records = await _sdk.getAuthHistory(accountId);
    if (records.isEmpty) {
      _setStatus('No auth history yet. Approve or deny a request first.');
      return;
    }
    final summary = records
        .map((r) => '• ${r.applicationName} — ${r.status}')
        .join('\n');
    _setStatus('History (${records.length}):\n$summary');
  }

  // ─── 9. Unregister device ────────────────────────────────────────────────
  //
  // Contacts the server to remove the device, then deletes the local
  // account, key pair, and history.
  Future<void> _unregister() async {
    final accountId = _accountId;
    if (accountId == null) {
      _setStatus('Register a device first (step 1).');
      return;
    }
    _setLoading();
    try {
      await _sdk.unregisterDevice(accountId);
      _accountId = null;
      _setStatus('Device unregistered and local data removed.');
    } on AsgardeoDeviceNotFoundException {
      // Server no longer knows this device — remove local data only.
      await _sdk.removeLocalAccount(accountId);
      _accountId = null;
      _setStatus('Device not found on server. Local data removed.');
    } on AsgardeoNetworkException catch (e) {
      _setStatus('Network error: ${e.message}');
    } on AsgardeoUnregistrationException catch (e) {
      _setStatus('Unregistration failed: ${e.message}');
    }
  }

  // ─── 10. Remove local account ────────────────────────────────────────────
  //
  // Deletes the local account, key pair, and history without contacting
  // the server. Use when the device was already removed server-side.
  Future<void> _removeLocal() async {
    final accountId = _accountId;
    if (accountId == null) {
      _setStatus('Register a device first (step 1).');
      return;
    }
    _setLoading();
    try {
      await _sdk.removeLocalAccount(accountId);
      _accountId = null;
      _setStatus('Local account data removed (server not contacted).');
    } on AsgardeoException catch (e) {
      _setStatus('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Image.asset('assets/images/logo.png', height: 20),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _Section(
                  header: '1. Device Registration',
                  items: [
                    _ActionItem(
                      'Register device (QR)',
                      _register,
                      icon: Icons.app_registration_rounded,
                    ),
                    _ActionItem(
                      'Register with token',
                      _registerWithToken,
                      icon: Icons.token_outlined,
                    ),
                  ],
                ),
                _Section(
                  header: '2. Push Notification',
                  items: [
                    _ActionItem(
                      'Parse push notification',
                      _parsePush,
                      icon: Icons.notifications_active_outlined,
                    ),
                  ],
                ),
                _Section(
                  header: '3. Auth Response',
                  items: [
                    _ActionItem(
                      'Approve',
                      _approve,
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: _kGreen,
                      iconBg: _kGreenBg,
                    ),
                    _ActionItem(
                      'Deny',
                      _deny,
                      icon: Icons.cancel_outlined,
                      iconColor: _kRed,
                      iconBg: _kRedBg,
                    ),
                  ],
                ),
                _Section(
                  header: '4. Device Management',
                  items: [
                    _ActionItem(
                      'Update push token',
                      _updateToken,
                      icon: Icons.sync_rounded,
                      iconColor: _kGray,
                      iconBg: _kGrayBg,
                    ),
                    _ActionItem(
                      'Rename device',
                      _rename,
                      icon: Icons.edit_outlined,
                      iconColor: _kGray,
                      iconBg: _kGrayBg,
                    ),
                    _ActionItem(
                      'Unregister device',
                      _unregister,
                      icon: Icons.phonelink_erase_outlined,
                      iconColor: _kRed,
                      iconBg: _kRedBg,
                    ),
                    _ActionItem(
                      'Remove local data only',
                      _removeLocal,
                      icon: Icons.delete_sweep_outlined,
                      iconColor: _kRed,
                      iconBg: _kRedBg,
                    ),
                  ],
                ),
                _Section(
                  header: '5. Local Queries',
                  items: [
                    _ActionItem(
                      'List accounts',
                      _listAccounts,
                      icon: Icons.manage_accounts_outlined,
                      iconColor: _kGray,
                      iconBg: _kGrayBg,
                    ),
                    _ActionItem(
                      'View auth history',
                      _viewHistory,
                      icon: Icons.history_rounded,
                      iconColor: _kGray,
                      iconBg: _kGrayBg,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ─── Status panel ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _kBrandOrange, width: 2),
              ),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SelectableText(
                    _status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF56585E),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Section ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.header, required this.items});

  final String header;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 20, bottom: 6),
          child: Text(
            header.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF868C99),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFD1D9E6)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 60, endIndent: 0),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Action item ─────────────────────────────────────────────────────────────

class _ActionItem extends StatelessWidget {
  const _ActionItem(
    this.label,
    this.onPressed, {
    required this.icon,
    this.iconColor = _kBrandOrange,
    this.iconBg = _kOrangeBg,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF17181A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBEC3CC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
