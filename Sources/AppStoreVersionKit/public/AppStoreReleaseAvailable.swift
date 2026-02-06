import Foundation

public class AppStoreReleaseAvailable {
    private let service: ReleaseAvailableServiceType
    
    internal init (service: ReleaseAvailableServiceType) {
        self.service = service
    }
    
    public init() {
        service = ReleaseAvailableService()
    }
    
    @available(*, deprecated, renamed: "checkAvailableRelease(bundleId:currentVersion:country:)")
    public func checkForUpdates(
        bundleId: String,
        currentVersion: String,
        country: String
    ) async -> Result<AppStoreReleaseAvailableResponse.AvailableRelease, Error>  {
        do {
            switch try await service.fetchAvailableRelease(bundleId: bundleId, currentVersion: currentVersion, country: country) {
            case .success(let availableRelease):
                if let verion = availableRelease.version, verion > currentVersion {
                    return .success(availableRelease)
                } else {
                    return .failure(AppStoreReleaseAvailableError.noNewVersionAvailable)
                }
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
    
    /// Checks the App Store for the latest release and compares it with the current app version.
    ///
    /// Fetches app metadata from the iTunes Lookup API and returns an `AppStoreRelease` containing
    /// the release info (version, release notes, app name) and a semantic version comparison result
    /// (whether a new version is available and whether it is a major, minor, or patch update).
    ///
    /// - Parameters:
    ///   - bundleId: The app’s bundle identifier (e.g. `"com.example.MyApp"`). Must match the App Store listing.
    ///   - currentVersion: The current app version for comparison. Supports semantic-style versions such as `"1.0.0"`, `"1.0"`, or `"1"`.
    ///   - country: The two-letter country code for the App Store storefront (e.g. `"us"`, `"br"`, `"gb"`). Affects localized metadata.
    /// - Returns: On success, an `AppStoreRelease` with `releaseInfo` and `versionComparison`. On failure, an `Error` (e.g. no new version, network error, invalid URL, or decoding error).
    public func checkAvailableRelease(
        bundleId: String,
        currentVersion: String,
        country: String
    ) async -> Result<AppStoreRelease, Error> {
        do {
            switch try await service.fetchAvailableRelease(bundleId: bundleId, currentVersion: currentVersion, country: country) {
            case .success(let availableRelease):
                if let availableVersion = availableRelease.version {
                    let versionComparison = AppStoreReleaseComparator.compare(current: currentVersion, available: availableVersion)
                    return .success(.init(releaseInfo: availableRelease, versionComparison: versionComparison))
                }
                
                return .failure(AppStoreReleaseAvailableError.noAppInformationAvailable)
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
}
