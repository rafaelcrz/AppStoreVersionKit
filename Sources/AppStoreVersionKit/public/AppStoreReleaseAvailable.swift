import Foundation

public class AppStoreReleaseAvailable {
    private let service: ReleaseAvailableService = .init()
    
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
}
