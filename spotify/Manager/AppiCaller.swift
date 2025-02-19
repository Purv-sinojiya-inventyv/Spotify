import Foundation

final class APICaller {
    static let shared = APICaller()
    private init() {}

    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1/me"
    }

    enum APIError: Error {
        case failedToGetData
    }

    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        AuthManager.shared.withValidToken { token in
            print("🔑 Access Token:", token) // Debugging

            guard let url = URL(string: Constants.baseAPIURL) else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Request Error:", error.localizedDescription)
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status Code:", httpResponse.statusCode)
                    print("📌 Headers:", httpResponse.allHeaderFields)

                    if httpResponse.statusCode == 403 {
                        print("🚨 ERROR: 403 Forbidden (Invalid Token or Missing Scopes)")
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(userProfile))
                } catch {
                    print("🚨 JSON Parsing Error:", error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
