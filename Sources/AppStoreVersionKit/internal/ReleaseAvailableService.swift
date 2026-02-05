//
//  File.swift
//  AppStoreVersionKit
//
//  Created by Rafael Felipe de Souza Ramos on 04/02/26.
//

import Foundation

typealias Response = Result<
    AppStoreReleaseAvailableResponse.AvailableRelease,
    AppStoreReleaseAvailableError
>

enum ReleaseApi {
    case lookup(country: String, bundleId: String, time: Double)
    
    var url: URL? {
        switch self {
        case .lookup(country: let country, bundleId: let bundleId, time: let time):
            return URL(string: "https://itunes.apple.com/\(country)/lookup?bundleId=\(bundleId)&t=\(time)")
        }
    }
}


final class ReleaseAvailableService {
    func fetchAvailableRelease(bundleId: String, currentVersion: String, country: String) async throws -> Response {
        let time: Double = CFAbsoluteTimeGetCurrent()
        
        guard let url = ReleaseApi.lookup(country: country, bundleId: bundleId, time: time).url else {
            return .failure(.invalidURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return .failure(.networkError(URLError(.badServerResponse)))
        }
        
        do {
            let appStoreResponse = try JSONDecoder().decode(AppStoreReleaseAvailableResponse.self, from: data)
            
            guard !appStoreResponse.results.isEmpty else {
                return .failure(.noResults)
            }
            
            guard let releaseResult = appStoreResponse.results.first else {
                return .failure(.noNewVersionAvailable)
            }
            
            return .success(releaseResult)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}
