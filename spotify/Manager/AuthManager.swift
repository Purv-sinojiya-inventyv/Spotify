import Foundation

final class AuthManager{
  static var shared = AuthManager()
    private var refreshingToken = false
  struct Constants{
    static let clientID = "b81d03a9d9da4ce6933dfd145c81be1a"
    static let clientSecret = "9ed293c2d82c48668ec012f5cd27b973"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "https://www.youtube.com"
    static let scope = "user-read-private user-read-email playlist-modify-public playlist-read-private playlist-modify-private user-follow-read user-follow-modify user-library-modify user-library-read"
  }
  private init() {}
  public var signInUrl: URL? {
    let url = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
    return URL(string: url)
  }
  var isSignedIn: Bool {
      print("yes signin")
    return accessToken != nil
  }
  private var accessToken: String? {
      print("access the token")
    return UserDefaults.standard.string(forKey: "access_token")
  }
  private var refreshToken: String? {
      print("refresh token")
    return UserDefaults.standard.string(forKey: "refresh_token")
  }
  private var tokenExpirationDate: Date? {
    return UserDefaults.standard.object(forKey: "expirationDate") as? Date
  }
  private var shouldRefreshToken: Bool {
    guard let expirationDate = tokenExpirationDate else{
      return false
    }
    let currentDate = Date()
    let fiveMinutes:TimeInterval = 300
    return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
  }
  public func exchangeToken(
    code: String,
    completion: @escaping (Bool)->Void
  ){
    guard let url = URL(string: Constants.tokenAPIURL) else{
      completion(false)
      return
    }
    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "grant_type", value: "authorization_code"),
      URLQueryItem(name: "code", value: code),
      URLQueryItem(name: "client_id", value: Constants.clientID),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
    ]
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let basicToken = Constants.clientID+":"+Constants.clientSecret
    let data = basicToken.data(using: .utf8)
    guard let base64String = data?.base64EncodedString() else{
      completion(false)
      return
    }
    request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
    request.httpBody = components.query?.data(using: .utf8)
      let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
      if let _ = error {
        completion(false)
        return
      }
      guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else{
        completion(false)
        return
      }
      if let data = data {
        do {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          let result = try decoder.decode(AuthResponse.self, from: data)
            self?.onRefreshBlock.forEach{$0(result.accessToken)}
            self?.onRefreshBlock.removeAll()
          self?.cacheToken(result: result)
          completion(true)
        }catch{
          print(error.localizedDescription)
          completion(false)
        }
      }
    }
    task.resume()
  }
    private var onRefreshBlock = [((String)->Void)]()
    
public func withValidToken(completion:@escaping(String) -> Void)
    {
        
        guard !refreshingToken else{
            onRefreshBlock.append(completion)
            return
        }
        if shouldRefreshToken {
            refreshAccessTokenIfNeeded { [weak self] success in
                if let token = self?.accessToken,success {
                        completion(token)
                    }
                }
            }
        else if let token = accessToken{
            completion(token)
        }
    }
  public func refreshAccessTokenIfNeeded(completion: @escaping (Bool)->Void){
      guard !refreshingToken else{
          return
      }
      
    guard shouldRefreshToken else {
      completion(true)
      return
    }
    guard let refreshToken = self.refreshToken else{
      completion(false)
      return
    }
    guard let url = URL(string: Constants.tokenAPIURL) else{
      completion(false)
      return
    }
      refreshingToken = true
    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "grant_type", value: "refresh_token"),
      URLQueryItem(name: "refresh_token", value: refreshToken),
      URLQueryItem(name: "client_id", value: Constants.clientID),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
    ]
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let basicToken = Constants.clientID+":"+Constants.clientSecret
    let data = basicToken.data(using: .utf8)
    guard let base64String = data?.base64EncodedString() else{
      completion(false)
      return
    }
    request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
    request.httpBody = components.query?.data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
        self?.refreshingToken = false
      if let _ = error {
        completion(false)
        return
      }
      guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else{
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
        }catch{
          print(error.localizedDescription)
          completion(false)
        }
      }
    }
    task.resume()
  }
  public func cacheToken(result: AuthResponse){
    UserDefaults.standard.set(result.accessToken, forKey: "access_token")
    if let refreshToken = self.refreshToken{
      UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
    }
    UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: "expirationDate")
  }
  public func removeCacheToken(){
    UserDefaults.standard.removeObject(forKey: "access_token")
    UserDefaults.standard.removeObject(forKey: "refresh_token")
    UserDefaults.standard.removeObject(forKey: "expirationDate")
  }
}
