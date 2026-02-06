import XCTest
@testable import AppStoreVersionKit

final class ReleaseApiTests: XCTestCase {

    func test_lookup_url_returnsNonNil() {
        let api = ReleaseApi.lookup(country: "us", bundleId: "com.example.app", time: 123.456)
        XCTAssertNotNil(api.url)
    }

    func test_lookup_url_containsBasePath() {
        let api = ReleaseApi.lookup(country: "us", bundleId: "com.example.app", time: 1.0)
        let url = api.url!
        XCTAssertTrue(url.absoluteString.contains("https://itunes.apple.com/"))
        XCTAssertTrue(url.absoluteString.contains("/lookup"))
    }

    func test_lookup_url_containsCountry() {
        let api = ReleaseApi.lookup(country: "br", bundleId: "com.test.app", time: 0)
        let url = api.url!
        XCTAssertTrue(url.absoluteString.contains("itunes.apple.com/br/"))
    }

    func test_lookup_url_containsBundleIdQueryParameter() {
        let api = ReleaseApi.lookup(country: "us", bundleId: "com.example.myapp", time: 999.0)
        let url = api.url!
        XCTAssertTrue(url.absoluteString.contains("bundleId=com.example.myapp"))
    }

    func test_lookup_url_containsTimeQueryParameter() {
        let api = ReleaseApi.lookup(country: "us", bundleId: "com.app", time: 12345.678)
        let url = api.url!
        XCTAssertTrue(url.absoluteString.contains("t=12345.678"))
    }

    func test_lookup_url_fullFormat() {
        let api = ReleaseApi.lookup(country: "gb", bundleId: "com.company.App", time: 1.5)
        let url = api.url!
        XCTAssertEqual(
            url.absoluteString,
            "https://itunes.apple.com/gb/lookup?bundleId=com.company.App&t=1.5"
        )
    }

    func test_lookup_url_withSpecialCharactersInBundleId_isEncodedOrPreserved() {
        let api = ReleaseApi.lookup(country: "us", bundleId: "com.app.my-app", time: 0)
        let url = api.url!
        XCTAssertTrue(url.absoluteString.contains("bundleId=com.app.my-app"))
    }
}
