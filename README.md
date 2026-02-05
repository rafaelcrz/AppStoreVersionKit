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

> **Important:** `checkForUpdates` returns `Result.success(let release)` only when the version you pass (`currentVersion`) is **lower** than the version found on the App Store. If the App Store version is equal or older, the result is `.failure(AppStoreReleaseAvailableError.noNewVersionAvailable)`.

### Basic Check

The simplest usage is to check if a new version is available:

```swift
import AppStoreVersionKit

let appStoreChecker = AppStoreReleaseAvailable()

let result = await appStoreChecker.checkForUpdates(
    bundleId: "com.yourapp.bundleid",
    currentVersion: "1.0.0",
    country: "us"
)

switch result {
case .success(let availableRelease):
    if let version = availableRelease.version {
        print("New version available: \(version)")
        print("Release Notes: \(availableRelease.releaseNotes ?? "N/A")")
        print("App Name: \(availableRelease.appName ?? "N/A")")
    }
case .failure(let error):
    print("Error checking for updates: \(error.localizedDescription)")
}
```

### Using the Default View (SwiftUI)

The package provides a pre-configured view that you can use directly:

```swift
import SwiftUI
import AppStoreVersionKit

struct ContentView: View {
    @State private var availableRelease: AppStoreReleaseAvailableResponse.AvailableRelease?
    @State private var showUpdateView = false
    
    var body: some View {
        VStack {
            // Your content here
        }
        .sheet(isPresented: $showUpdateView) {
            if let release = availableRelease {
                AppStoreReleaseAvailableView(
                    title: "New Version Available",
                    availableVersion: release.version ?? "",
                    appName: release.appName ?? "App",
                    releaseNotes: release.releaseNotes ?? "",
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
            await checkForUpdates()
        }
    }
    
    private func checkForUpdates() async {
        let checker = AppStoreReleaseAvailable()
        let result = await checker.checkForUpdates(
            bundleId: Bundle.main.bundleIdentifier ?? "",
            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            country: "us"
        )
        
        switch result {
        case .success(let release):
            availableRelease = release
            showUpdateView = true
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

### Custom View

You can create your own completely custom view using the returned data:

```swift
import SwiftUI
import AppStoreVersionKit

struct CustomUpdateView: View {
    let release: AppStoreReleaseAvailableResponse.AvailableRelease
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Update Available")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version \(release.version ?? "")")
                .font(.headline)
            
            if let notes = release.releaseNotes {
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

For maximum flexibility, you can use the generic view with your own components:

```swift
AppStoreReleaseAvailableView(
    title: "New Version Available",
    availableVersion: release.version ?? "",
    appName: release.appName ?? "App",
    releaseNotes: release.releaseNotes ?? "",
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
    
    public func checkForUpdates(
        bundleId: String,
        currentVersion: String,
        country: String
    ) async -> Result<AppStoreReleaseAvailableResponse.AvailableRelease, Error>
}
```

#### Parameters

- `bundleId`: Your app's Bundle Identifier (e.g., "com.example.app")
- `currentVersion`: The current app version (e.g., "1.0.0")
- `country`: The country code for the App Store (e.g., "us", "br")

### AppStoreReleaseAvailableResponse.AvailableRelease

Structure containing information about the available version:

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

Optional SwiftUI view to display information about the available update.

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
        let result = await checker.checkForUpdates(
            bundleId: bundleId,
            currentVersion: currentVersion,
            country: "us"
        )
        
        switch result {
        case .success(let release):
            // Display notification or update view
            print("New version \(release.version ?? "") available!")
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
        
        // Perform check...
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
