//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation

import Alamofire

extension DeezerAPI {
    
    public func makedataURL(request: String) -> URL? {
        let queryItems = [URLQueryItem(name: "access_token", value: self.accessToken.value)]
        var urlComps = URLComponents(string: request)!
        urlComps.queryItems = queryItems
        return urlComps.url!
    }
    
    public func query<T>(_ type: T.Type, url: String, completed: @escaping (DeezerUser?) -> Void) where T : Decodable {
        Task {
            //If not in connected repeat until it is
            while self.state.value != .connected {}
            
            AF.request(makedataURL(request: url)!, method: .get).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        
                        do {
                            _ = try decoder.decode(DeezerError.self, from: data)
                            print("deezer: Not Connected")
                            
                            //reconnect
                            self.state.value = .start
                            
                            //redo it
                            self.getUser(completed: completed)
                        } catch {
                            let data = try decoder.decode(DeezerUser.self, from: data)
                            completed(data)
                        }
                        
                    } catch {
                        print("deezer: Cannot getUser - \(error)")
                        completed(nil)
                    }
                case .failure(_):
                    print("deezer: Cannot getUser")
                    completed(nil)
                }
            }
        }
    }
    
    
    
    //https://api.deezer.com/user/me?access_token=
    public func getUser(completed: @escaping (DeezerUser?) -> Void) {
        self.query(DeezerUser.self, url: "https://api.deezer.com/user/me", completed: completed)
    }
    
}
