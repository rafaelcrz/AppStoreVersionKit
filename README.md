<p align="center">
    <h1 align="center">
        AppStoreVersionKit
    </h1>
</p>

<p align="center">
    A Swift Package to easily check if a new version is available on the App Store.
    <br/>
    Designed from the ground up to be fully customizable to your needs.
</p>

<p align="center">
   <a href="https://swiftpackageindex.com">
    <img src="https://img.shields.io/badge/Swift-6.2-orange.svg" alt="Swift Version">
   </a>
   <a href="https://swiftpackageindex.com">
    <img src="https://img.shields.io/badge/Platform-iOS%2016%2B%20%7C%20macOS%2014%2B-lightgrey" alt="Platforms">
   </a>
</p>

## Features

- [x] Easy App Store version checking 🚀
- [x] Support for SwiftUI and UIKit 🧑‍🎨
- [x] Runs on iOS and macOS 📱 🖥
- [x] Optional pre-configured view or fully customizable ✅
- [x] Simple integration with iTunes/App Store API 🔧

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rafaelcrz/AppStoreVersionKit.git", from: "1.0.0")
]
```

Or navigate to your Xcode project then select `Swift Packages`, click the "+" icon and search for `AppStoreVersionKit`.

## Usage

> **Important:** `checkAvailableRelease` returns `Result.success(let release)` with an `AppStoreRelease` that includes both the release info and a semantic version comparison. The `versionComparison` tells you if a new version is available and whether it is a major, minor, or patch update. If the App Store returns no version info or the request fails, the result is `.failure` with an appropriate error.

### Basic Check

The simplest usage is to check if a new version is available:

```swift
import AppStoreVersionKit

let appStoreChecker = AppStoreReleaseAvailable()

let result = await appStoreChecker.checkAvailableRelease(
    bundleId: "com.yourapp.bundleid",
    currentVersion: "1.0.0",
    country: "us"
)

switch result {
case .success(let release):
    let info = release.releaseInfo
    if let version = info.version {
        print("Version from App Store: \(version)")
        print("Release Notes: \(info.releaseNotes ?? "N/A")")
        print("App Name: \(info.appName ?? "N/A")")
    }
    switch release.versionComparison {
    case .newVersionAvailable(let updateType):
        print("New version available: \(updateType) update")
    case .noNewVersionAvailable:
        print("App is up to date")
    }
case .failure(let error):
    print("Error checking for updates: \(error.localizedDescription)")
}
```

### Using the Default View (SwiftUI)

The package provides a pre-configured view that you can use directly. Show the update view **only when** the result is success **and** `versionComparison` is `.newVersionAvailable` (so the user only sees the sheet when there is actually a newer version):

```swift
import SwiftUI
import AppStoreVersionKit

struct ContentView: View {
    @State private var availableRelease: AppStoreRelease?
    @State private var showUpdateView = false
    
    var body: some View {
        VStack {
            // Your content here
        }
        .sheet(isPresented: $showUpdateView) {
            if let release = availableRelease {
                AppStoreReleaseAvailableView(
                    title: "New Version Available",
                    availableVersion: release.releaseInfo.version ?? "",
                    appName: release.releaseInfo.appName ?? "App",
                    releaseNotes: release.releaseInfo.releaseNotes ?? "",
                    buttonTitle: "Update",
                    onButtonTap: {
                        // Open App Store
                        if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
        }
        .task {
            await checkAvailableRelease()
        }
    }
    
    private func checkAvailableRelease() async {
        let checker = AppStoreReleaseAvailable()
        let result = await checker.checkAvailableRelease(
            bundleId: Bundle.main.bundleIdentifier ?? "",
            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            country: "us"
        )
        
        switch result {
        case .success(let release):
            if case .newVersionAvailable = release.versionComparison {
                availableRelease = release
                showUpdateView = true
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

### Custom View

You can create your own completely custom view using the returned data. Only present it when `release.versionComparison` is `.newVersionAvailable`. Use `release.releaseInfo` for the same fields as before; the comparison also tells you if it's a major, minor, or patch update.

```swift
import SwiftUI
import AppStoreVersionKit

struct CustomUpdateView: View {
    let release: AppStoreRelease
    
    var body: some View {
        let info = release.releaseInfo
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Update Available")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version \(info.version ?? "")")
                .font(.headline)
            
            if let notes = info.releaseNotes {
                Text(notes)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button("Update Now") {
                // Your custom action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Fully Customizable View

For maximum flexibility, you can use the generic view with your own components. As with the default view, present it only when the check returns success and `versionComparison` is `.newVersionAvailable`.

```swift
AppStoreReleaseAvailableView(
    title: "New Version Available",
    availableVersion: release.releaseInfo.version ?? "",
    appName: release.releaseInfo.appName ?? "App",
    releaseNotes: release.releaseInfo.releaseNotes ?? "",
    icon: {
        AsyncImage(url: URL(string: "https://example.com/app-icon.png")) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Image(systemName: "app.badge.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.blue)
        }
    },
    button: {
        HStack {
            Image(systemName: "arrow.down.circle.fill")
            Text("Download Update")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .onTapGesture {
            // Open App Store
        }
    }
)
```

## API Reference

### AppStoreReleaseAvailable

The main class for checking available updates on the App Store.

```swift
public class AppStoreReleaseAvailable {
    public init()
    
    public func checkAvailableRelease(
        bundleId: String,
        currentVersion: String,
        country: String
    ) async -> Result<AppStoreRelease, Error>
}
```

#### Parameters

- `bundleId`: Your app's Bundle Identifier (e.g., "com.example.app")
- `currentVersion`: The current app version (e.g., "1.0.0"). Supports semantic-style versions like "1.0.0", "1.0", or "1".
- `country`: The country code for the App Store (e.g., "us", "br")

### AppStoreRelease

Returned on success from `checkAvailableRelease`. Contains the release metadata and a semantic version comparison.

```swift
public struct AppStoreRelease {
    public let releaseInfo: AppStoreReleaseAvailableResponse.AvailableRelease
    public let versionComparison: VersionComparisonResult
}
```

- `releaseInfo`: Version string, release notes, and app name from the App Store.
- `versionComparison`: Either `.noNewVersionAvailable` or `.newVersionAvailable(VersionUpdateType)` where `VersionUpdateType` is `.major`, `.minor`, or `.patch`.

### AppStoreReleaseAvailableResponse.AvailableRelease

Structure containing information about the available version (also exposed as `release.releaseInfo`):

```swift
public struct AvailableRelease: Codable {
    public let version: String?
    public let releaseNotes: String?
    public let appName: String?
}
```

### AppStoreReleaseAvailableError

Enum representing possible errors:

```swift
public enum AppStoreReleaseAvailableError: Error, LocalizedError {
    case invalidURL
    case noResults
    case noNewVersionAvailable
    case networkError(Error)
    case decodingError(Error)
    case general(Error)
}
```

### AppStoreReleaseAvailableView

Optional SwiftUI view to display information about the available update. Show this view only when `checkAvailableRelease` returns `.success(release)` and `release.versionComparison` is `.newVersionAvailable`.

#### Convenience Initializer (Default)

```swift
public init(
    title: String,
    availableVersion: String,
    appName: String,
    releaseNotes: String,
    buttonTitle: String = "Update",
    onButtonTap: @escaping () -> Void
)
```

#### Initializer with Custom Icon

```swift
public init(
    title: String,
    availableVersion: String,
    appName: String,
    releaseNotes: String,
    @ViewBuilder icon: @escaping () -> IconView,
    buttonTitle: String = "Update",
    onButtonTap: @escaping () -> Void
)
```

#### Fully Customizable Initializer

```swift
public init(
    title: String,
    availableVersion: String,
    appName: String,
    releaseNotes: String,
    @ViewBuilder icon: @escaping () -> IconView,
    @ViewBuilder button: @escaping () -> ButtonView
)
```

## Usage Examples

### Automatic Check on App Launch

```swift
import SwiftUI
import AppStoreVersionKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await checkForAppStoreUpdates()
                }
        }
    }
    
    private func checkForAppStoreUpdates() async {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        let checker = AppStoreReleaseAvailable()
        let result = await checker.checkAvailableRelease(
            bundleId: bundleId,
            currentVersion: currentVersion,
            country: "us"
        )
        
        switch result {
        case .success(let release):
            if case .newVersionAvailable = release.versionComparison {
                // Display notification or update view only when there is a new version
                print("New version \(release.releaseInfo.version ?? "") available!")
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

### Integration with UserDefaults to Avoid Excessive Checks

```swift
class UpdateChecker {
    private let checker = AppStoreReleaseAvailable()
    private let lastCheckKey = "lastUpdateCheck"
    private let checkInterval: TimeInterval = 86400 // 24 hours
    
    func checkIfNeeded() async {
        let lastCheck = UserDefaults.standard.double(forKey: lastCheckKey)
        let now = Date().timeIntervalSince1970
        
        guard now - lastCheck > checkInterval else {
            return // Too soon to check again
        }
        
        UserDefaults.standard.set(now, forKey: lastCheckKey)
        
        let result = await checker.checkAvailableRelease(
            bundleId: Bundle.main.bundleIdentifier ?? "",
            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            country: "us"
        )
        // Handle result...
    }
}
```

## Requirements

- iOS 16.0+ / macOS 14.0+
- Swift 6.2+
- Xcode 15.0+

## License

This project is available under the MIT license. See the LICENSE file for more details.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.
