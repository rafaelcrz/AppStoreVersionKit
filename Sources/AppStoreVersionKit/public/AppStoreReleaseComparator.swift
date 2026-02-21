import Foundation

/// Type of version update (semantic versioning).
public enum SemanticVersionType: Equatable {
    case major
    case minor
    case patch
}

/// Result of comparing the current version with the available version.
public enum VersionComparisonResult: Equatable {
    /// No new version available (current >= available).
    case noNewVersionAvailable
    /// A new version is available and the update type (major, minor, or patch).
    case newVersionAvailable(SemanticVersionType)
}

public enum AppStoreReleaseComparator {

    /// Compares the current version with the available version and returns whether a new version exists and its type (major, minor, or patch).
    /// - Parameters:
    ///   - current: Current version (e.g. "1.0.0", "1", "1.0")
    ///   - available: Available version (e.g. "1.0.0", "2.1.0")
    /// - Returns: `.noNewVersionAvailable` when there is no new version; `.newVersionAvailable(.major/.minor/.patch)` otherwise.
    public static func compare(current: String, available: String) -> VersionComparisonResult {
        let currentComponents = parseVersion(current)
        let availableComponents = parseVersion(available)

        let (cMajor, cMinor, cPatch) = normalizedTriple(from: currentComponents)
        let (aMajor, aMinor, aPatch) = normalizedTriple(from: availableComponents)

        if aMajor > cMajor {
            return .newVersionAvailable(.major)
        }
        if aMajor < cMajor {
            return .noNewVersionAvailable
        }

        if aMinor > cMinor {
            return .newVersionAvailable(.minor)
        }
        if aMinor < cMinor {
            return .noNewVersionAvailable
        }

        if aPatch > cPatch {
            return .newVersionAvailable(.patch)
        }

        return .noNewVersionAvailable
    }

    public static func isNewVersionAvailable(current: String, available: String) -> Bool {
        switch compare(current: current, available: available) {
        case .newVersionAvailable:
            return true
        case .noNewVersionAvailable:
            return false
        }
    }

    // MARK: - Private

    private static func parseVersion(_ version: String) -> [Int] {
        version
            .split(separator: ".", omittingEmptySubsequences: false)
            .prefix(3)
            .map { segment in
                let numericPart = segment.prefix(while: { $0.isNumber })
                return Int(String(numericPart)) ?? 0
            }
    }

    private static func normalizedTriple(from components: [Int]) -> (major: Int, minor: Int, patch: Int) {
        let major = components.indices.contains(0) ? components[0] : 0
        let minor = components.indices.contains(1) ? components[1] : 0
        let patch = components.indices.contains(2) ? components[2] : 0
        return (major, minor, patch)
    }
}
