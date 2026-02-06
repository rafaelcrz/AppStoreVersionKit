# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- **Unit tests**: New test suites for release availability and version comparison
- **New API**: `checkAvailableRelease(bundleId:currentVersion:country:)` returning `AppStoreRelease` with release info and semantic version comparison (major/minor/patch)
- **Version comparison**: Public types `SemanticVersionType` (major, minor, patch) and `VersionComparisonResult`
- **CI/CD**: GitHub Actions workflow for build and test on iOS and macOS, with Xcode version selection for Swift 6 compatibility

### Changed

- **Deprecated**: `checkForUpdates(bundleId:currentVersion:country:)` in favor of `checkAvailableRelease`
- **Documentation**: README updated to document `checkAvailableRelease` and its usage

### Fixed

- (none)

### Reverted

- (none)
