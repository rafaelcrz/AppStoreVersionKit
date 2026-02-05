import Foundation

public struct AppStoreReleaseAvailableResponse: Codable {
    public let results: [AvailableRelease]
    
    public struct AvailableRelease: Codable {
        public let version: String?
        public let releaseNotes: String?
        public let appName: String?
        
        enum CodingKeys: String, CodingKey {
            case version
            case releaseNotes
            case appName = "trackName"
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            version = try container.decodeIfPresent(String.self, forKey: .version)
            releaseNotes = try container.decodeIfPresent(String.self, forKey: .releaseNotes)
            appName = try container.decodeIfPresent(String.self, forKey: .appName)
        }
    }
}
