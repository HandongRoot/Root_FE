import Foundation

class TokenManager {
  static let shared = TokenManager()

  private let appGroupId = "group.com.moim.ShareExtension"
  private let accessTokenKey = "accessToken"

  private init() {}

  func getAccessToken() -> String? {
    guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
      print("App Group UserDefaults 접근 실패")
      return nil
    }

    let token = userDefaults.string(forKey: accessTokenKey)
    if token == nil {
      print("accessToken이 없음")
    }
    return token
  }
}