import Foundation
struct AuthResponse: Codable{
  let accessToken: String
  let expiresIn: Int
  let refreshToken: String?
  let scope: String
  let tokenType: String
}
