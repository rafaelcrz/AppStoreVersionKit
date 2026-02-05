import Foundation

public enum AppStoreReleaseAvailableError: Error, LocalizedError {
    case invalidURL
    case noResults
    case noNewVersionAvailable
    case networkError(Error)
    case decodingError(Error)
    case general(Error)
    
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
        }
    }
}
