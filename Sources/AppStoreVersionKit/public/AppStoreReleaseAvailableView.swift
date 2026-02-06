import Foundation
import SwiftUI

public struct AppStoreReleaseAvailableView<IconView: View, ButtonView: View>: View {
    private let iconSize: Double = 44
    private let title: String
    private let availableVersion: String
    private let releaseNotes: String
    private let trackName: String
    private let icon: () -> IconView
    private let button: () -> ButtonView

    public init(
        title: String,
        availableVersion: String,
        appName: String,
        releaseNotes: String,
        @ViewBuilder icon: @escaping () -> IconView,
        @ViewBuilder button: @escaping () -> ButtonView
    ) {
        self.title = title
        self.availableVersion = availableVersion
        self.releaseNotes = releaseNotes
        self.trackName = appName
        self.icon = icon
        self.button = button
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .fontWeight(.bold)

            HStack {
                icon()
                    .frame(width: iconSize, height: iconSize)
                VStack(alignment: .leading) {
                    Text(availableVersion)
                        .fontWeight(.bold)
                    Text(trackName)
                }
            }

            if !releaseNotes.isEmpty {
                Text(releaseNotes)
            }

            button()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.red)
    }
}

// MARK: - Convenience initializer (default icon + button)
extension AppStoreReleaseAvailableView where IconView == EmptyView, ButtonView == AnyView {
    public init(
        title: String,
        availableVersion: String,
        appName: String,
        releaseNotes: String,
        buttonTitle: String = "Update",
        onButtonTap: @escaping () -> Void
    ) {
        self.init(
            title: title,
            availableVersion: availableVersion,
            appName: appName,
            releaseNotes: releaseNotes,
            icon: { EmptyView() },
            button: {
                AnyView(_DefaultUpdateButton(
                    buttonTitle: buttonTitle,
                    onButtonTap: onButtonTap
                ))
            }
        )
    }
}

// MARK: - Convenience initializer (custom icon + default button)
extension AppStoreReleaseAvailableView where ButtonView == AnyView {
    public init(
        title: String,
        availableVersion: String,
        appName: String,
        releaseNotes: String,
        @ViewBuilder icon: @escaping () -> IconView,
        buttonTitle: String = "Update",
        onButtonTap: @escaping () -> Void
    ) {
        self.init(
            title: title,
            availableVersion: availableVersion,
            appName: appName,
            releaseNotes: releaseNotes,
            icon: icon,
            button: {
                AnyView(_DefaultUpdateButton(
                    buttonTitle: buttonTitle,
                    onButtonTap: onButtonTap
                ))
            }
        )
    }
}

internal struct _DefaultUpdateButton: View {
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        Group {
            Button(action: onButtonTap) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .fontWeight(.bold)
                    .font(.callout)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview("Default (convenience)") {
    AppStoreReleaseAvailableView(
        title: "Available Version",
        availableVersion: "1.0.0",
        appName: "App Name",
        releaseNotes: "Release Notes",
        buttonTitle: "Update",
        onButtonTap: {}
    )
}

#Preview("Custom icon + button") {
    AppStoreReleaseAvailableView(
        title: "Available Version",
        availableVersion: "1.0.0",
        appName: "App Name",
        releaseNotes: "Release Notes",
        icon: {
            Image(systemName: "app.badge.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.blue)
        },
        button: {
            Button("Ir para App Store", action: {})
                .buttonStyle(.borderedProminent)
        }
    )
}
