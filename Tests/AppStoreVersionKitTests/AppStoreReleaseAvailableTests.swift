import XCTest
@testable import AppStoreVersionKit

final class AppStoreReleaseAvailableTests: XCTestCase {

    private var spy: ReleaseAvailableServiceSpy!
    private var sut: AppStoreReleaseAvailable!

    override func setUp() {
        super.setUp()
        spy = ReleaseAvailableServiceSpy()
        sut = AppStoreReleaseAvailable(service: spy)
    }

    override func tearDown() {
        spy = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - checkAvailableRelease - Parameters

    func test_checkAvailableRelease_passesBundleIdToService() async {
        spy.resultToReturn = .failure(.noResults)

        _ = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        XCTAssertEqual(spy.fetchAvailableReleaseCallCount, 1)
        XCTAssertEqual(spy.lastBundleId, "com.example.app")
    }

    func test_checkAvailableRelease_passesCurrentVersionToService() async {
        spy.resultToReturn = .failure(.noResults)

        _ = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "2.3.1",
            country: "us"
        )

        XCTAssertEqual(spy.lastCurrentVersion, "2.3.1")
    }

    func test_checkAvailableRelease_passesCountryToService() async {
        spy.resultToReturn = .failure(.noResults)

        _ = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "br"
        )

        XCTAssertEqual(spy.lastCountry, "br")
    }

    func test_checkAvailableRelease_passesAllParametersToService() async {
        spy.resultToReturn = .failure(.invalidURL)

        _ = await sut.checkAvailableRelease(
            bundleId: "com.test.MyApp",
            currentVersion: "1.0.0",
            country: "gb"
        )

        XCTAssertEqual(spy.lastBundleId, "com.test.MyApp")
        XCTAssertEqual(spy.lastCurrentVersion, "1.0.0")
        XCTAssertEqual(spy.lastCountry, "gb")
    }

    // MARK: - checkAvailableRelease - Result success

    func test_checkAvailableRelease_whenServiceReturnsNewVersion_returnsSuccessWithRelease() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "1.0.1",
            releaseNotes: "Bug fixes",
            appName: "MyApp"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        switch result {
        case .success(let release):
            XCTAssertEqual(release.releaseInfo.version, "1.0.1")
            XCTAssertEqual(release.releaseInfo.releaseNotes, "Bug fixes")
            XCTAssertEqual(release.releaseInfo.appName, "MyApp")
            XCTAssertEqual(release.versionComparison, .newVersionAvailable(.patch))
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }

    func test_checkAvailableRelease_whenServiceReturnsNewMinorVersion_returnsCorrectComparison() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "1.1.0",
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .success(let release) = result else {
            XCTFail("Expected success")
            return
        }
        XCTAssertEqual(release.versionComparison, .newVersionAvailable(.minor))
    }

    func test_checkAvailableRelease_whenServiceReturnsNewMajorVersion_returnsCorrectComparison() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "2.0.0",
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .success(let release) = result else {
            XCTFail("Expected success")
            return
        }
        XCTAssertEqual(release.versionComparison, .newVersionAvailable(.major))
    }

    func test_checkAvailableRelease_whenServiceReturnsSameVersion_returnsNoNewVersionAvailable() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "1.0.0",
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .success(let release) = result else {
            XCTFail("Expected success with noNewVersionAvailable comparison")
            return
        }
        XCTAssertEqual(release.versionComparison, .noNewVersionAvailable)
    }

    // MARK: - checkAvailableRelease - Result failure

    func test_checkAvailableRelease_whenServiceReturnsNoVersion_returnsFailure() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: nil,
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result,
              let appStoreError = error as? AppStoreReleaseAvailableError else {
            XCTFail("Expected failure with noNewVersionAvailable")
            return
        }
        XCTAssertEqual(appStoreError, .noAppInformationAvailable)
    }

    func test_checkAvailableRelease_whenServiceFails_returnsServiceError() async {
        spy.resultToReturn = .failure(.noResults)

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result,
              let appStoreError = error as? AppStoreReleaseAvailableError else {
            XCTFail("Expected failure with noResults")
            return
        }
        XCTAssertEqual(appStoreError, .noResults)
    }

    func test_checkAvailableRelease_whenServiceReturnsNetworkError_returnsNetworkError() async {
        spy.resultToReturn = .failure(.networkError(URLError(.notConnectedToInternet)))

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result,
              case .networkError = (error as? AppStoreReleaseAvailableError) else {
            XCTFail("Expected networkError")
            return
        }
    }

    func test_checkAvailableRelease_whenServiceThrows_returnsThrownError() async {
        let thrownError = URLError(.timedOut)
        spy.throwsToBeReturned = thrownError

        let result = await sut.checkAvailableRelease(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result else {
            XCTFail("Expected failure when service throws")
            return
        }
        XCTAssertEqual((error as NSError).code, URLError.timedOut.rawValue)
    }

    // MARK: - checkForUpdates (deprecated) - Parameters and result

    func test_checkForUpdates_passesParametersToService() async {
        spy.resultToReturn = .failure(.noResults)

        _ = await sut.checkForUpdates(
            bundleId: "com.deprecated.app",
            currentVersion: "1.0.0",
            country: "jp"
        )

        XCTAssertEqual(spy.lastBundleId, "com.deprecated.app")
        XCTAssertEqual(spy.lastCurrentVersion, "1.0.0")
        XCTAssertEqual(spy.lastCountry, "jp")
    }

    func test_checkForUpdates_whenServiceReturnsNewerVersion_returnsSuccess() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "1.0.1",
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkForUpdates(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .success(let release) = result else {
            XCTFail("Expected success")
            return
        }
        XCTAssertEqual(release.version, "1.0.1")
    }

    func test_checkForUpdates_whenServiceReturnsSameOrOlderVersion_returnsNoNewVersionAvailable() async {
        let releaseInfo = AppStoreReleaseAvailableResponse.AvailableRelease(
            version: "1.0.0",
            releaseNotes: nil,
            appName: "App"
        )
        spy.resultToReturn = .success(releaseInfo)

        let result = await sut.checkForUpdates(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result,
              let appStoreError = error as? AppStoreReleaseAvailableError else {
            XCTFail("Expected failure noNewVersionAvailable")
            return
        }
        XCTAssertEqual(appStoreError, .noNewVersionAvailable)
    }

    func test_checkForUpdates_whenServiceThrows_returnsThrownError() async {
        let thrownError = URLError(.networkConnectionLost)
        spy.throwsToBeReturned = thrownError

        let result = await sut.checkForUpdates(
            bundleId: "com.example.app",
            currentVersion: "1.0.0",
            country: "us"
        )

        guard case .failure(let error) = result else {
            XCTFail("Expected failure when service throws")
            return
        }
        XCTAssertTrue((error as NSError).code == URLError.networkConnectionLost.rawValue)
    }
}
