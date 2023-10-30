//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation


public struct DeezerAPI {
    public var clientId = ""
    public var clientSecret = ""
    public var redirect_uri = ""
    public var permissions = ""
    
    public let authorizeUrl = "https://connect.deezer.com/oauth/auth.php"
    public let authentificationURL = "https://connect.deezer.com/oauth/access_token.php"
    
    ///- <<---- Flow ---->>\\
    ///1. if no login entered ConnectView
    ///2. AutoConnect
    ///3. Query anything
    ///4. if token expires, it will back to Autoconnect automatically
    public init(clientId: String, clientSecret: String, redirect_uri: String, permissions: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirect_uri = redirect_uri
        self.permissions = permissions
    }
    
    
    //<<---- Accessor ---->>\\
    
    public func setState(_ state: String){
        UserDefaults.standard.set(state, forKey: "DeezerAPI_state")
    }
    public func setAccessToken(_ accesstoken: String){
        UserDefaults.standard.set(accesstoken, forKey: "DeezerAPI_accessToken")
    }
    public func setToken(_ token: String){
        UserDefaults.standard.set(token, forKey: "DeezerAPI_token")
    }

    
//        case start
//        case tokenFound
//        case connected
//        case fail
    public func getState() -> String {
        if let state = UserDefaults.standard.string(forKey: "DeezerAPI_state") {
            return state
        } else {
            return "start"
        }
    }
    public func getAccessToken() -> String {
        if let accessToken = UserDefaults.standard.string(forKey: "DeezerAPI_accessToken") {
            return accessToken
        } else {
            print("Deezer: No access Token retrieved")
            self.setState("start")
            return ""
        }
    }
    public func getToken() -> String {
        if let token = UserDefaults.standard.string(forKey: "DeezerAPI_token") {
            return token
        } else {
            return ""
        }
    }
    
    
    ///Return true if user is connected
    public func isConnected() -> Bool {
        return getState() == "connected"
    }
    
    
}
