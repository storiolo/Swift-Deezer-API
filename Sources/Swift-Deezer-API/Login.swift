//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import Alamofire

extension DeezerAPI {
    //<<---- Login ---->>\\
    
    ///construct authotization URL
    ///https://connect.deezer.com/oauth/auth.php?app_id=YOUR_APP_ID&redirect_uri=YOUR_REDIRECT_URI&perms=PERMISSIONS
    public func makeAuthorizationURL() -> URL? {
        let queryItems = [URLQueryItem(name: "app_id", value: self.clientId),
                          URLQueryItem(name: "redirect_uri", value: self.redirect_uri),
                          URLQueryItem(name: "perms", value: self.permissions)]
        var urlComps = URLComponents(string: self.authorizeUrl)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    ///construct authentification URL
    ///https://connect.deezer.com/oauth/access_token.php?app_id=YOUR_APP_ID&secret=YOUR_APP_SECRET&code=TOKEN
    public func makeAuthentificationURL() -> URL? {

        let queryItems = [URLQueryItem(name: "app_id", value: self.clientId),
                          URLQueryItem(name: "secret", value: self.clientSecret),
                          URLQueryItem(name: "code", value: self.getToken())]
        var urlComps = URLComponents(string: self.authentificationURL)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
}
