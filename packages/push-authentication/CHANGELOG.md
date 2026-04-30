# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0

- Initial release of `asgardeo_push_auth`.
- Push-notification-based authentication for Asgardeo / WSO2 Identity Server.
- RSA-2048 key pair generation and request signing.
- Device registration, update, and unregistration.
- Auth history tracking.
- Biometric-backed (`BiometricCryptoEngine`) and software-backed (`SecureCryptoEngine`) crypto engines.
- Pluggable interfaces for crypto, storage, HTTP, logging, and device-info.
