import Foundation
@testable import AppStoreVersionKit

/// Spy for `ReleaseAvailableServiceType` to capture parameters and inject results in unit tests.
final class ReleaseAvailableServiceSpy: ReleaseAvailableServiceType {

    typealias Response = Result<
        AppStoreReleaseAvailableResponse.AvailableRelease,
        AppStoreReleaseAvailableError
    >

    private(set) var fetchAvailableReleaseCallCount = 0
    private(set) var lastBundleId: String?
    private(set) var lastCurrentVersion: String?
    private(set) var lastCountry: String?

    var resultToReturn: Response = .failure(.noNewVersionAvailable)
    /// When non-nil, the spy throws this error instead of returning `resultToReturn`.
    var throwsToBeReturned: Error?

    func fetchAvailableRelease(bundleId: String, currentVersion: String, country: String) async throws -> Response {
        fetchAvailableReleaseCallCount += 1
        lastBundleId = bundleId
        lastCurrentVersion = currentVersion
        lastCountry = country
        if let error = throwsToBeReturned {
            throw error
        }
        return resultToReturn
    }
}
