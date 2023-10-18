//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import SwiftUI
import Alamofire


public struct DeezerAPI {
    
    public var isShowingView = false
    
    public var clientId = ""
    public var clientSecret = ""
    public var redirect_uri = ""
    public var permissions = ""
    
    public let authorizeUrl = "https://connect.deezer.com/oauth/auth.php"
    public let authentificationURL = "https://connect.deezer.com/oauth/access_token.php"
    
    private(set) var accessToken: _DeezerValue_<String> = _DeezerValue_("")
    private(set) var token: _DeezerValue_<String> = _DeezerValue_("")
    private(set) var state: _DeezerValue_<ConnectState> = _DeezerValue_(.start)

    
    
    ///- <<---- Easy Flow ---->>\\
    ///1. if no login entered ConnectView
    ///2. AutoConnect
    ///3. Query anything
    ///4. if token expires, it will back to Autoconnect automatically
    ///- <<---- Hard Flow ---->>\\
    ///1. makeAuthorizationURL -> retrieve the token -> setToken
    ///2. makeAuthentificationURL -> retrieve the accessToken
    ///3. Query anything
    ///4. if token expires, you'll have to redo 1 and 2
    public init(clientId: String, clientSecret: String, redirect_uri: String, permissions: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirect_uri = redirect_uri
        self.permissions = permissions
    }
    
    
    //<<---- Accessor ---->>\\
    
    public func setToken(_ token: String){
        self.token.value = token
    }
    public func setState(_ state: ConnectState){
        self.state.value = state
    }
    public func getState() -> ConnectState{
        return self.state.value
    }
    
    
    public func getAccessToken() -> String {
        return self.accessToken.value
    }
    public func getToken() -> String {
        return self.token.value
    }
    
    
    ///Return true if user is connected
    public func isConnected() -> Bool {
        return self.state.value == .connected
    }
    
}
