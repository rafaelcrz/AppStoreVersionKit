import Foundation

public struct AppStoreReleaseAvailableResponse: Codable {
    public let results: [AvailableRelease]
    
    public struct AvailableRelease: Codable {
        public let version: String?
        public let releaseNotes: String?
        public let trackName: String?
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            version = try container.decodeIfPresent(String.self, forKey: .version)
            releaseNotes = try container.decodeIfPresent(String.self, forKey: .releaseNotes)
            trackName = try container.decodeIfPresent(String.self, forKey: .trackName)
        }
    }
}
