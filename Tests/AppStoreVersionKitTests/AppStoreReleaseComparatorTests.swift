import XCTest
@testable import AppStoreVersionKit

final class AppStoreReleaseComparatorTests: XCTestCase {
    func testNoNewVersionWhenEqual() {
        let sut: VersionComparisonResult = AppStoreReleaseComparator.compare(current: "1.0.0", available: "1.0.0")
        XCTAssertEqual(sut, .noNewVersionAvailable)
    }

    func testNoNewVersionWhenAvailableIsLower() {
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "2.0.0", available: "1.0.0"), .noNewVersionAvailable)
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1.1.0", available: "1.0.0"), .noNewVersionAvailable)
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1.0.1", available: "1.0.0"), .noNewVersionAvailable)
    }

    func testNewVersionPatch() {
        XCTAssertEqual(
            AppStoreReleaseComparator.compare(current: "1.0.0", available: "1.0.1"),
            .newVersionAvailable(.patch)
        )
    }

    func testNewVersionMinor() {
        XCTAssertEqual(
            AppStoreReleaseComparator.compare(current: "1.0.0", available: "1.1.0"),
            .newVersionAvailable(.minor)
        )
    }

    func testNewVersionMajor() {
        XCTAssertEqual(
            AppStoreReleaseComparator.compare(current: "1.0.0", available: "2.0.0"),
            .newVersionAvailable(.major)
        )
    }

    func testShortFormatSingleDigit() {
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1", available: "1.0.0"), .noNewVersionAvailable)
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1", available: "1.0.1"), .newVersionAvailable(.patch))
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1", available: "2"), .newVersionAvailable(.major))
    }

    func testShortFormatMajorMinor() {
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1.0", available: "1.0.0"), .noNewVersionAvailable)
        XCTAssertEqual(AppStoreReleaseComparator.compare(current: "1.0", available: "1.1.0"), .newVersionAvailable(.minor))
    }

    func testNumericComparison() {
        XCTAssertEqual(
            AppStoreReleaseComparator.compare(current: "1.9", available: "1.10"),
            .newVersionAvailable(.minor)
        )
    }

    func testIsNewVersionAvailableTrue() {
        XCTAssertTrue(AppStoreReleaseComparator.isNewVersionAvailable(current: "1.0.0", available: "1.0.1"))
        XCTAssertTrue(AppStoreReleaseComparator.isNewVersionAvailable(current: "1.0.0", available: "1.1.0"))
        XCTAssertTrue(AppStoreReleaseComparator.isNewVersionAvailable(current: "1.0.0", available: "2.0.0"))
    }

    func testIsNewVersionAvailableFalse() {
        XCTAssertFalse(AppStoreReleaseComparator.isNewVersionAvailable(current: "1.0.0", available: "1.0.0"))
        XCTAssertFalse(AppStoreReleaseComparator.isNewVersionAvailable(current: "2.0.0", available: "1.0.0"))
    }
}
