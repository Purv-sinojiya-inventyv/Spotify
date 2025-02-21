import Foundation

final class APICaller {
    static let shared = APICaller()
    private init() {}

    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }

    enum APIError: Error {
        case failedToGetData
        case invalidRequest
    }

    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        AuthManager.shared.withValidToken { token in
            print("🔑 Access Token:", token) // Debugging

            guard let url = URL(string: Constants.baseAPIURL + "/me") else { return }
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

    // ✅ Moved getNewReleases outside of getCurrentUserProfile
    public func getNewReleases(completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            guard let request = request else {
                completion(.failure(APIError.invalidRequest)) // Handle possible nil request
                return
            }

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(json)
                    completion(.success("Success")) // Placeholder, replace with actual model parsing
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    // ✅ Added a createRequest function if missing
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }

        AuthManager.shared.withValidToken { token in
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            completion(request)
        }
    }
}

// ✅ Added HTTPMethod Enum
enum HTTPMethod: String {
    case GET
    case POST
}
