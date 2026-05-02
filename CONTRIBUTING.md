# Contributing to Asgardeo Flutter SDKs

This guide walks you through setting up the development environment and other important information for contributing to Asgardeo Flutter SDKs.

## Table of Contents

- [Prerequisite Software](#prerequisite-software)
- [Development Tools](#development-tools)
- [Setting up the Source Code](#setting-up-the-source-code)
- [Setting up the Development Environment](#setting-up-the-development-environment)
- [Daily Workflow](#daily-workflow)
- [Commit Message Guidelines](#commit-message-guidelines)
  - [Types](#types)
  - [Scope](#scope)
  - [Example Commit Message](#example-commit-message)
  - [Revert commits](#revert-commits)
- [Contributing](#contributing)
  - [Releases](#releases)
    - [How Versioning Works](#how-versioning-works)
    - [For Maintainers](#for-maintainers)
      - [Release Process](#release-process)
      - [Release Automation](#release-automation)
      - [Pub.dev OIDC Prerequisites](#pubdev-oidc-prerequisites)
      - [Triple-Lock Invariant](#triple-lock-invariant)

## Prerequisite Software

To build and write code, make sure you have the following set of tools on your local environment:

- [Git](https://git-scm.com/downloads) - Open source distributed version control system. For install instructions, refer [this](https://www.atlassian.com/git/tutorials/install-git).
- [Flutter SDK](https://docs.flutter.dev/get-started/install) - Latest stable channel. Includes the Dart SDK (`v3.11 or higher`).
- [Xcode](https://developer.apple.com/xcode/) (iOS builds, macOS only) and [Android Studio](https://developer.android.com/studio) or the Android command-line tools (Android builds).

## Development Tools

| Extension | Description | VS Code Marketplace |
|-----------|-------------|---------------------|
| Flutter | Official Flutter extension — debugger, hot-reload, widget inspector. | [Install](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) |
| Dart | Official Dart extension — analyzer, formatter, refactoring. | [Install](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) |
| Pubspec Assist | Adds dependencies to `pubspec.yaml` from a search prompt. | [Install](https://marketplace.visualstudio.com/items?itemName=jeroen-meijer.pubspec-assist) |
| Code Spell Checker | A basic spell checker that works well with code and documents. | [Install](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) |

## Setting up the Source Code

1. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the repository.
2. Clone your fork to the local machine.

Replace `<github username>` with your own username.

```shell
git clone https://github.com/<github username>/flutter.git
```

3. Set the original repo as the upstream remote.

```shell
git remote add upstream https://github.com/asgardeo/flutter.git
```

## Setting up the Development Environment

This repository is a [Dart Workspace](https://dart.dev/tools/pub/workspaces) orchestrated by [Melos](https://melos.invertase.dev/) 7+. All Melos configuration lives under the `melos:` key in the **root `pubspec.yaml`** — there is no separate `melos.yaml`. A single shared `pubspec.lock` covers every member.

1. Install workspace dependencies (this also installs Melos as a dev_dependency):

```bash
dart pub get
```

2. Bootstrap the workspace:

```bash
dart run melos bootstrap
```

> [!IMPORTANT]
> Always invoke Melos via `dart run melos`. Never `dart pub global activate melos` — that introduces version drift between your machine and CI. The version of Melos used is locked in `pubspec.lock`.

Optional ergonomic alias (add to `~/.zshrc` or `~/.bashrc`):

```bash
alias melos="dart run melos"
```

## Daily Workflow

| Task | Command |
| --- | --- |
| Bootstrap (after pulling new deps) | `dart run melos bootstrap` |
| Static analysis | `dart run melos run analyze` |
| Format (write) | `dart run melos run format` |
| Format check (CI) | `dart run melos run format:check` |
| Test all packages | `dart run melos run test` |
| Test changed packages + dependents | `dart run melos run test:diff` |
| Test with coverage | `dart run melos run test:coverage` |
| Sample debug APK | `dart run melos run build:apk` |
| Sample debug iOS | `dart run melos run build:ios` |
| Publish dry-run (SDK only) | `dart run melos run publish:dry` |
| Show outdated deps | `dart run melos run outdated` |
| Clean build artifacts | `dart run melos run clean` |

## Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) as the commit message convention. **Conventional Commits drive automated version bumps and CHANGELOG entries** — `melos version` reads the commit history since the last release and computes the next version per package.

Please refer to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) documentation for more information.

> [!IMPORTANT]
>
> 1. Use the imperative, present tense: "change" not "changed" nor "changes".
> 2. Don't capitalize the first letter.
> 3. No dot (.) at the end.

### Types

Must be one of the following:

- **chore**: Housekeeping tasks that don't require to be highlighted in the changelog
- **feat**: A new feature (drives a **minor** version bump)
- **fix**: A bug fix (drives a **patch** version bump)
- **feat!** or footer `BREAKING CHANGE:`: A breaking change (drives a **major** version bump)
- **ci**: Changes to CI configuration files and scripts (examples: GitHub Actions, Melos scripts)
- **build**: Changes that affect the build system or external dependencies (example scopes: pubspec, gradle, podfile)
- **docs**: Documentation only changes
- **perf**: A code change that improves performance
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **test**: Adding missing tests or correcting existing tests

### Scope

The scope should be the name (or short alias) of the package affected, as perceived by the person reading the changelog generated from commit messages.

The following is the list of supported scopes:

- `push-auth` - Changes to the [`asgardeo_push_auth`](./packages/push-authentication/) package.
- `authenticator` - Changes to the [`asgardeo_push_authenticator`](./samples/push-authenticator/) sample app.
- `example` - Changes to the SDK [`example`](./packages/push-authentication/example/) app.
- `workspace` - Changes to the workspace root (`pubspec.yaml`, `analysis_options.yaml`, `.gitignore`).
- `ci` - Used as a type, not a scope.

> [!NOTE]
> If the change affects multiple packages, just use the type without a scope, e.g., `fix: ...`.

### Example Commit Message

Each commit message consists of a **header**, a **body**, and a **footer**.

```
<type>(<scope>): <short summary>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

```
# Add a new feature to the SDK package.
feat(push-auth): add biometric policy enforcement on registration

# Fix a bug in the sample app.
fix(authenticator): handle QR scanner permission-denied state gracefully

# Update CI workflows.
ci: enable affected-only sample build smoke jobs

# Bump shared dev dependencies at the workspace root.
build(workspace): bump melos to 7.5.x and very_good_analysis to 10.x
```

### Revert commits

If the commit reverts a previous commit, it should begin with `revert:`, followed by the header of the reverted commit.

The content of the commit message body should contain:

- Information about the SHA of the commit being reverted in the following format: `This reverts commit <SHA>`.
- A clear description of the reason for reverting the commit message.

## Contributing

### Releases

This project uses [Melos](https://melos.invertase.dev/) for version management and release automation, driven by Conventional Commits.

#### How Versioning Works

You **do not** create or commit changeset files. `melos version` reads the Conventional-Commits history since the last release and computes the next version for each package automatically:

- ✅ `feat: …` → minor bump in the affected package(s)
- ✅ `fix: …` → patch bump
- ✅ `feat!: …` or `BREAKING CHANGE:` footer → major bump
- ❌ `chore:`, `docs:`, `refactor:`, `test:`, `ci:` → no version bump

> [!IMPORTANT]
> Use a scope (e.g. `feat(push-auth): …`) wherever possible. Scoped commits attach to the right package's CHANGELOG; unscoped commits with a release-worthy type apply to all touched packages.

To preview what `melos version` would produce locally (no commits, no tags):

```bash
dart run melos version --dry-run
```

#### For Maintainers

This section contains information relevant to project maintainers who handle the actual release process.

##### Release Process

The release process is fully automated and gated by maintainer review:

1. **Prerequisites for releases**

- Maintainer permissions on the repository
- pub.dev publish permissions for the `asgardeo_push_auth` package (one-time OIDC setup — see below)
- All PRs intended for the release have been merged to `main` with Conventional-Commit messages

2. **Automatic release-PR workflow**

- When PRs are merged to `main`, the `🦋 Release PR` workflow runs `dart run melos version`, force-pushes the result to the `chore/automated-release` branch, and creates or updates a release PR titled `chore(release): bump versions`.
- The release PR includes per-package version bumps and generated `CHANGELOG.md` entries linked to the originating commits.
- Maintainers review the release PR (CHANGELOG diffs, version bumps).
- Merging the release PR triggers `🚀 Release`, which generates per-package Git tags (`<package>-v<version>`) and runs `dart run melos publish` (which fires `command.publish.hooks.pre` for `analyze` + `test` first, then publishes to pub.dev via OIDC, in topological order).

> [!WARNING]
> **Never push commits directly to the `chore/automated-release` branch.** The `🛡️ Enforce Bot-Only Release PR` workflow will fail the PR. To fix a problem in an upcoming release, merge a corrective PR to `main`; the bot regenerates the release PR.

##### Release Automation

The project includes automated release infrastructure across four GitHub Actions workflows:

| Workflow | Trigger | Role |
| --- | --- | --- |
| `🦋 Release PR` ([`release-pr.yml`](./.github/workflows/release-pr.yml)) | `push: main` | Computes Conventional-Commits-driven bumps, regenerates the bot's release branch, opens or updates the release PR via the `gh` CLI. |
| `🛡️ Enforce Bot-Only Release PR` ([`enforce-bot-pr.yml`](./.github/workflows/enforce-bot-pr.yml)) | `pull_request: branches: [main]` | Fails the PR if any commit on `chore/automated-release` was authored by someone other than `github-actions[bot]`. |
| `🚀 Release` ([`release.yml`](./.github/workflows/release.yml)) | `pull_request: closed` | Triple-Lock-gated publish: tags packages, runs `dart run melos publish` via pub.dev OIDC. |
| `👷 PR Builder` ([`pr-builder.yml`](./.github/workflows/pr-builder.yml)) | `pull_request: main` | Format check, analyze, tests with coverage, sample build smoke (gated on affected paths), publish dry-run. |

##### Pub.dev OIDC Prerequisites

Before the first run of `🚀 Release`, an org admin must perform these one-time manual steps **on pub.dev**:

1. Sign in to [pub.dev](https://pub.dev) as a verified publisher of `asgardeo_push_auth`.
2. Open the package's **Admin → Automated publishing** page.
3. Enable **GitHub Actions publishing** with:
   - **Repository**: `asgardeo/flutter`
   - **Tag pattern**: `asgardeo_push_auth-v{{version}}`
4. Save.

A `PUB_CREDENTIALS` secret is **not** used and **not** needed — OIDC mints short-lived tokens per run via the workflow's `id-token: write` permission.

##### Triple-Lock Invariant

The `🚀 Release` workflow only fires when **all three** conditions hold:

```
github.event.pull_request.merged == true                                  AND
github.event.pull_request.head.ref == 'chore/automated-release'           AND
github.event.pull_request.user.login == 'github-actions[bot]'
```

This prevents a malicious actor from triggering a publish by opening a fork PR on a branch named `chore/automated-release`. Any change to this invariant must be treated as a security-sensitive review. Pair it with branch protection on `main` requiring `🛡️ Enforce Bot-Only Release PR` as a status check, with no bypass for `chore/automated-release`-headed PRs.
