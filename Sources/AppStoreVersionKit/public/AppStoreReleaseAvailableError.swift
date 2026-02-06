import Foundation

public enum AppStoreReleaseAvailableError: Error, LocalizedError, Equatable {
    case invalidURL
    case noResults
    @available(*, deprecated, renamed: "noAppInformationAvailable")
    case noNewVersionAvailable
    case networkError(Error)
    case decodingError(Error)
    case general(Error)
    case noAppInformationAvailable
    
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .noResults:
            return "No app results found"
        case .noNewVersionAvailable:
            return "No new version available"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .general(let error):
            return "General error: \(error.localizedDescription)"
        case .noAppInformationAvailable:
            return "No app information available"
        }
    }
    
    public static func == (lhs: AppStoreReleaseAvailableError, rhs: AppStoreReleaseAvailableError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.noResults, .noResults),
            (.noNewVersionAvailable, .noNewVersionAvailable),
            (.noAppInformationAvailable, .noAppInformationAvailable):
            return true
        case (.networkError(let a), .networkError(let b)):
            return a.localizedDescription == b.localizedDescription
        case (.decodingError(let a), .decodingError(let b)):
            return a.localizedDescription == b.localizedDescription
        case (.general(let a), .general(let b)):
            return a.localizedDescription == b.localizedDescription
        default:
            return false
        }
    }
}
