//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import Alamofire
import SwiftUI


public struct DeezerAPI {
    
    public var isShowingView = false
    
    public var clientId = ""
    public var clientSecret = ""
    public var redirect_uri = ""
    public var permissions = ""
    
    public let authorizeUrl = "https://connect.deezer.com/oauth/auth.php"
    public let authentificationURL = "https://connect.deezer.com/oauth/access_token.php"
    
    private var accessToken: _DeezerValue_<String> = _DeezerValue_("")
    private var token: _DeezerValue_<String> = _DeezerValue_("")
    private var state: _DeezerValue_<ConnectState> = _DeezerValue_(.start)

    public init(clientId: String, clientSecret: String, redirect_uri: String, permissions: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirect_uri = redirect_uri
        self.permissions = permissions
    }
    
    
    public func setaccessToken(_ accessToken: String){
        self.accessToken.value = accessToken
    }
    public func setToken(_ token: String){
        self.token.value = token
    }
    public func setState(_ state: ConnectState){
        self.state.value = state
    }
    public func getState() -> ConnectState{
        return self.state.value
    }
    
    
    
    //<<---- Data ---->>\\
    
    public func makedataURL(request: String) -> URL? {
        let queryItems = [URLQueryItem(name: "access_token", value: self.accessToken.value)]
        var urlComps = URLComponents(string: request)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    
    //https://api.deezer.com/user/me?access_token=
    public func getUser(completed: @escaping (DeezerUser?) -> Void) {
        AF.request(makedataURL(request: "https://api.deezer.com/user/me")!, method: .get).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    
                    do {
                        _ = try decoder.decode(DeezerError.self, from: data)
                        print("deezer: Not Connected")
                        
                        //reconnect
                        self.state.value = .start
                    } catch {
                        let deezerUser = try decoder.decode(DeezerUser.self, from: data)
                        print(deezerUser.email)
                        completed(deezerUser)
                    }
                    
                } catch {
                    print("deezer: Cannot getUser - \(error)")
                }
            case .failure(_):
                print("deezer: Cannot getUser")
            }
        }
        completed(nil)
    }

    
    
    
    //<<---- Login ---->>\\
    
    //1.Connect on makeAuthorizationURL -> setToken
    //2.get_accessToken via makeAuthentificationURL
    
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
                          URLQueryItem(name: "code", value: self.token.value)]
        var urlComps = URLComponents(string: self.authentificationURL)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    public func get_accessToken(completed: @escaping (String?) -> Void) {
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
                    completed(nil)
                }
            case .failure(_):
                completed(nil)
            }
        }
    }
    


}
