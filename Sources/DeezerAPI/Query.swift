//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation

import Alamofire

extension DeezerAPI {
    
    static let base_url = "https://api.deezer.com/"
    
    //url?access_token=
    public func makedataURL(request: String, post: String? = nil) -> URL? {
        let queryItems = [URLQueryItem(name: "access_token", value: self.accessToken.value)]
        var urlComps = URLComponents(string: request)!
        urlComps.queryItems = queryItems
        var url = urlComps.url!
        
        if let post = post {
            url = URL(string: "&"+post, relativeTo: url)!
        }
        return url
    }
    
    
    ///Query data
    ///- type is the data output requested, see struct file and find your wonderland
    ///- post is optionnal, if the query require more input, eg. see post Methods
    ///- completed will return the query
    public func query<T: Decodable>(_ type: T.Type, url: String, post: String? = nil, completed: @escaping (T?) -> Void) {
        Task {
            //If not in connected repeat until it is
            while self.state.value != .connected {}
            
            AF.request(makedataURL(request: DeezerAPI.base_url+url)!, method: .get).responseData { response in
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
                            self.query(T.self, url: url, completed: completed)
                        } catch {
                            let data = try decoder.decode(T.self, from: data)
                            completed(data)
                        }
                        
                    } catch {
                        print("deezer: \(error)")
                        completed(nil)
                    }
                case .failure(let error):
                    print("deezer: \(error)")
                    completed(nil)
                }
            }
        }
    }
    
    
    
    //<<---- get Method ---->>\\
    
    //https://api.deezer.com/user/me
    public func getUser(completed: @escaping (DeezerUser?) -> Void) {
        self.query(DeezerUser.self, url: "user/me", completed: completed)
    }
    
    //https://api.deezer.com/user/me/playlists
    public func getUserPlaylists(completed: @escaping (DeezerDataPlaylist?) -> Void) {
        self.query(DeezerDataPlaylist.self, url: "user/me/playlists", completed: completed)
    }
    
    //https://api.deezer.com/album/ALBUM_ID
    public func getAlbum(album_id: String, completed: @escaping (DeezerAlbum?) -> Void) {
        self.query(DeezerAlbum.self, url: "album/"+album_id, completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLAYLIST_ID/tracks
    public func getTracks(playlist_id: String, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "playlist/"+playlist_id+"/tracks", completed: completed)
    }
    
    
    
    
    
    //https://api.deezer.com/artist/ARTIST_ID
    public func getArtist(artist_id: String, completed: @escaping (DeezerArtist?) -> Void) {
        self.query(DeezerArtist.self, url: "artist/"+artist_id, completed: completed)
    }
    
    
    //https://api.deezer.com/user/me/history
    public func getHistory(completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "user/me/history", completed: completed)
    }
    
    
    
    
    //<<---- post Method ---->>\\
    
    
    //https://api.deezer.com/user/me/playlists?title=
    //return playlist id
    public func createPlaylist(title: String, completed: @escaping (DeezerCreatePlaylist?) -> Void) {
        self.query(DeezerCreatePlaylist.self, url: "user/me/playlists", post: "title="+title, completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLATLIST_ID/tracks?songs=id1,id2...
    //return true/false
    public func addTracksToPlaylist(playlist_id: String, tracks_id: [String], completed: @escaping (Bool?) -> Void) {
        self.query(Bool.self, url: "playlist/"+playlist_id+"/tracks", post: "songs="+tracks_id.joined(separator: ","), completed: completed)
    }
    
    
    //https://api.deezer.com/user/me/tracks?track_id=
    //return true/false
    public func addTrackToFavorite(track_id: String, completed: @escaping (Bool?) -> Void) {
        self.query(Bool.self, url: "user/me/tracks", post: "track_id="+track_id, completed: completed)
    }
    
    
    
    //<<---- Next Method ---->>\\
    
    //https://api.deezer.com/LAST_GET_METHOD?index=
    //get Next
    
    
    
    //<<---- Search Method ---->>\\
    
    //https://api.deezer.com/search/album?q=
    //https://api.deezer.com/search/artist?q=
    //https://api.deezer.com/search/playlist?q=
    //https://api.deezer.com/search/track?q=
    public func SearchAlbum(search: String, completed: @escaping (DeezerDataAlbum?) -> Void) {
        self.query(DeezerDataAlbum.self, url: "search/album", post: "q"+search, completed: completed)
    }
    public func SearchArtist(search: String, completed: @escaping (DeezerDataArtist?) -> Void) {
        self.query(DeezerDataArtist.self, url: "search/artist", post: "q"+search, completed: completed)
    }
    public func SearchPlaylist(search: String, completed: @escaping (DeezerDataPlaylist?) -> Void) {
        self.query(DeezerDataPlaylist.self, url: "search/playlist", post: "q"+search, completed: completed)
    }
    public func SearchTrack(search: String, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "search/track", post: "q"+search, completed: completed)
    }
    
}
