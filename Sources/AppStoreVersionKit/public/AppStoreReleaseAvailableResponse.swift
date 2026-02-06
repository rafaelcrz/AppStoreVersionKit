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
        
        public init(version: String?, releaseNotes: String?, appName: String?) {
            self.version = version
            self.releaseNotes = releaseNotes
            self.appName = appName
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            version = try container.decodeIfPresent(String.self, forKey: .version)
            releaseNotes = try container.decodeIfPresent(String.self, forKey: .releaseNotes)
            appName = try container.decodeIfPresent(String.self, forKey: .appName)
        }
    }
}

public struct AppStoreRelease {
    public let releaseInfo: AppStoreReleaseAvailableResponse.AvailableRelease
    public let versionComparison: VersionComparisonResult
}
