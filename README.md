<p align="center" style="color: #343a40">
  <img src="./docs/assets/images/banner.png" alt="Asgardeo Logo">
</p>

<p align="center" style="font-size: 1.2rem;font-weight: bold;">
  <a href="https://asgardeo.io">Asgardeo</a> . <a href="https://wso2.com/asgardeo/docs/sdks">Documentation</a> . <a href="./CHANGELOG.md">Changelog</a>
</p>

<div align="center">
  <a href="https://stackoverflow.com/questions/tagged/wso2is"><img src="https://img.shields.io/badge/Ask%20for%20help%20on-Stackoverflow-orange.svg" alt="Ask for help on Stackoverflow"></a>
  <a href="https://discord.gg/wso2"><img src="https://img.shields.io/badge/Join%20us%20on-Discord-%23e01563.svg" alt="Join us on Discord"></a>
  <a href="https://twitter.com/intent/follow?screen_name=wso2"><img src="https://img.shields.io/twitter/follow/wso2.svg?style=social&label=Follow" alt="Twitter"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License"></a>
  <a href="https://github.com/asgardeo/flutter/actions/workflows/release.yml"><img src="https://github.com/asgardeo/flutter/actions/workflows/release.yml/badge.svg" alt="🚀 Release"></a>
</div>

<br>

<p align="center" style="font-size: 1.2rem;">
  Build secure, push-notification-based authentication into your Flutter apps with Asgardeo's Flutter SDKs.
</p>

## 🚀 Get started with Asgardeo

Follow these simple steps to get started with Asgardeo:

1. Create an account in Asgardeo 👉
   [Sign Up](https://asgardeo.io/signup?visitor_id=685a48bc57b3b5.46411343&utm_source=site&utm_medium=organic)

2. Refer to our **Quick Start Guides** and get started in minutes.

- [Flutter Quick Start](https://wso2.com/asgardeo/docs/quick-starts/flutter/)

## Packages

| Package | Description |
| --- | --- |
| [![asgardeo_push_auth](https://img.shields.io/pub/v/asgardeo_push_auth?color=%2302569B&label=asgardeo_push_auth&logo=flutter)](./packages/push-authentication/) | Push-notification-based authentication SDK for Asgardeo / WSO2 Identity Server. RSA-2048 key signing, device registration, push approve/deny, and auth history. |

### Sample Apps

| App | Description |
| --- | --- |
| [`asgardeo_push_auth_example`](./packages/push-authentication/example/) | Minimal example demonstrating SDK usage. |
| [`asgardeo_push_authenticator`](./samples/push-authenticator/) | Full sample authenticator app — Riverpod, GoRouter, Firebase Messaging (Android/FCM) + APNs (iOS), `mobile_scanner`. |

## Repository structure

This is a [Dart Workspace](https://dart.dev/tools/pub/workspaces) (Dart 3.11+) orchestrated by [Melos](https://melos.invertase.dev/) 7+. All Melos configuration lives under the `melos:` key in the **root `pubspec.yaml`** — there is no separate `melos.yaml`. Every member declares `resolution: workspace`, so dependencies resolve through one shared `pubspec.lock` at the root.

```
flutter/
├── pubspec.yaml                  # workspace root + Melos config
├── pubspec.lock                  # single shared lockfile
├── analysis_options.yaml         # shared lint base
├── .github/workflows/            # CI/CD pipelines
├── packages/
│   └── push-authentication/      # asgardeo_push_auth SDK
│       └── example/              # SDK example app
└── samples/
    └── push-authenticator/       # asgardeo_push_authenticator sample app
```

## Contribute

Please read [Contributing Guide](CONTRIBUTING.md) for details on how to contribute to Asgardeo Flutter SDKs. Refer to
[General Contribution Guidelines](http://wso2.github.io/) for details on our code of conduct, and the process for
submitting pull requests to us.

### Contributors ❤️

Hats off to all the people who have contributed to this project, including those who created issues and participated in
discussions. 🙌

<a href="https://github.com/asgardeo/flutter/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=asgardeo/flutter" />
</a>

### Reporting issues

We encourage you to report issues, improvements, and feature requests creating
[Github Issues](https://github.com/asgardeo/flutter/issues).

**Important**: Please be advised that security issues MUST be reported to
<a href="mailto:security@wso2.com">security@wso2.com</a>, not as GitHub issues, in order to reach the proper audience.
We strongly advise following the WSO2 Security Vulnerability Reporting Guidelines when reporting the security issues.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
