//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import Alamofire

extension DeezerAPI {
    
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
