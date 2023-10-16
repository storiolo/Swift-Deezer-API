#if os(iOS)

import Foundation
import Alamofire
import WebKit
import SwiftUI


public struct DeezerAPI {
    
    public var isShowingView = false
    public var clientId = ""
    public var clientSecret = ""
    public var redirect_uri = ""
    public var permissions = ""
    public let authorizeUrl = "https://connect.deezer.com/oauth/auth.php"
    public let authentificationURL = "https://connect.deezer.com/oauth/access_token.php"
    
    
    private var accessToken = ""
    private var token = ""
    

    public init(clientId: String, clientSecret: String, redirect_uri: String, permissions: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirect_uri = redirect_uri
        self.permissions = permissions
    }

    
    
    
    //<<---- Login ---->>\\
    
    //https://connect.deezer.com/oauth/auth.php?app_id=YOUR_APP_ID&redirect_uri=YOUR_REDIRECT_URI&perms=PERMISSIONS
    public func makeAuthorizationURL() -> URL? {
        let queryItems = [URLQueryItem(name: "app_id", value: self.clientId),
                          URLQueryItem(name: "redirect_uri", value: self.redirect_uri),
                          URLQueryItem(name: "perms", value: self.permissions)]
        var urlComps = URLComponents(string: self.authorizeUrl)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    //https://connect.deezer.com/oauth/access_token.php?app_id=YOU_APP_ID&secret=YOU_APP_SECRET&code=TOKEN
    public func makeAuthentificationURL() -> URL? {

        let queryItems = [URLQueryItem(name: "app_id", value: self.clientId),
                          URLQueryItem(name: "secret", value: self.clientSecret),
                          URLQueryItem(name: "code", value: self.token)]
        var urlComps = URLComponents(string: self.authentificationURL)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    
    public func setToken(token_: String){
//        self.token = token_
    }
    
    public func get_Token(completed: @escaping () -> Void) {
        AF.request(makeAuthorizationURL()!, method: .get).responseString { response in
            switch response.result {
            case .success(let data):
                print(data)
                completed()
            case .failure(_):
                print("deezer: Access Token not found in response.")
                completed()
            }
        }
    }
    
    
    public func get_accessToken(completed: @escaping (String) -> Void) {
        AF.request(makeAuthentificationURL()!, method: .get).responseString { response in
            switch response.result {
            case .success(let data):
                if let accessTokenRange = data.range(of: "access_token=") {
                    let accessTokenStart = accessTokenRange.upperBound
                    let accessTokenEnd: String.Index
                    if let range = data.range(of: "&", options: [], range: accessTokenStart ..< data.endIndex) {
                        accessTokenEnd = range.lowerBound
                    } else {
                        accessTokenEnd = data.endIndex
                    }
                    print("deezer: Access Token loaded")
                    completed(String(data[accessTokenStart..<accessTokenEnd]))
                } else {
                    print("deezer: Access Token not found in response.")
                    completed("")
                }
            case .failure(_):
                print("deezer: Access Token not found in response.")
                completed("")
            }
        }
    }
    


}

#endif
