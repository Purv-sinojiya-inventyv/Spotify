import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private var refreshingToken = false

    struct Constants {
        static let clientID = "f1372c7c34d34dd9bb1a55d825cd3421"
        static let clientSecret = "199fad203b1f41529bd949297805d4b1"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.youtube.com"
        static let scope = "user-read-private user-read-email user-library-read user-top-read"
    }

    private init() {}

    public var signInUrl: URL? {
        let url = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: url)
    }

    var isSignedIn: Bool {
        return accessToken != nil
    }

    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }

    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }

    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }

    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        let fiveMinutes: TimeInterval = 60*59
        return Date().addingTimeInterval(fiveMinutes) >= expirationDate
    }

    public func exchangeToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.tokenAPIURL) else {
            completion(false)
            return
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "client_id", value: Constants.clientID),
            URLQueryItem(name: "client_secret", value: Constants.clientSecret),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Token Exchange Error:", error.localizedDescription)
                completion(false)
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("🚨 Invalid Token Exchange Response")
                completion(false)
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(AuthResponse.self, from: data)
                    self?.cacheToken(result: result)
                    completion(true)
                } catch {
                    print("🚨 JSON Parsing Error:", error.localizedDescription)
                    completion(false)
                }
            }
        }
        task.resume()
    }

    private var onRefreshBlock = [((String) -> Void)]()

    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlock.append(completion)
            return
        }

        if shouldRefreshToken {
            refreshAccessTokenIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                } else {
                    print("🚨 Failed to refresh token")
                }
            }
        } else if let token = accessToken {
            completion(token)
        } else {
            print("🚨 No valid access token available")
        }
    }

    public func refreshAccessTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard !refreshingToken else { return }
        guard shouldRefreshToken else {
            completion(true)
            return
        }
        guard let refreshToken = self.refreshToken else {
            completion(false)
            return
        }
        guard let url = URL(string: Constants.tokenAPIURL) else {
            completion(false)
            return
        }

        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: Constants.clientID),
            URLQueryItem(name: "client_secret", value: Constants.clientSecret),
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.refreshingToken = false
            if let error = error {
                print("❌ Refresh Token Error:", error.localizedDescription)
                completion(false)
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("🚨 Invalid Refresh Token Response")
                completion(false)
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(AuthResponse.self, from: data)
                    self?.cacheToken(result: result)
                    completion(true)
                } catch {
                    print("🚨 JSON Parsing Error:", error.localizedDescription)
                    completion(false)
                }
            }
        }
        task.resume()
    }

    public func cacheToken(result: AuthResponse) {
        UserDefaults.standard.set(result.accessToken, forKey: "access_token")
        if let refreshToken = result.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: "expirationDate")
    }

    public func removeCacheToken() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "expirationDate")
    }
}
