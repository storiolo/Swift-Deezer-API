//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import Alamofire


#if canImport(UIKit)
import UIKit
#endif



extension DeezerAPI {
    
    static let base_url = "https://api.deezer.com/"
    
    ///construct query url
    ///
    ///post is optional
    ///example:
    ///- request_url?access_token=XXXX&post=value
    func makedataURL(request: String, post: String? = nil) -> URL? {
        //add post if exist
        let url: String
        if let post = post {
            url = request + "&" + post + "access_token=" + accessToken.value
        } else {
            url = request + "&access_token=" + accessToken.value
        }
        
        return URL(string: url)!
    }
    
    
    ///Query data
    ///- type is the data output requested, see struct file and find your wonderland
    ///- post is optionnal, if the query require more input, eg. see post Methods
    ///- completed will return the query
    func query<T: Decodable>(_ type: T.Type, url: String, post: String? = nil, completed: @escaping (T?) -> Void) {
        Task {
            //If not in connected repeat until it is
            while self.state.value != .connected {}
            
            //verify url has not been already made (next method don't need to construct it)
            let dataURL: URL
            if url.contains("https://") {
                dataURL = URL(string: url)!
            } else {
                dataURL = makedataURL(request: DeezerAPI.base_url + url, post: post)!
            }
            
            AF.request(dataURL, method: .get).responseData { response in
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
    public func getAlbum(album_id: Int, completed: @escaping (DeezerAlbum?) -> Void) {
        self.query(DeezerAlbum.self, url: "album/"+String(album_id), completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLAYLIST_ID/tracks
    ///getTracks will get 25 first tracks of the playlist
    ///you'll have to do Next Method
    public func getTracks(playlist_id: Int, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "playlist/"+String(playlist_id)+"/tracks", completed: completed)
    }
    
    ///getAllTracks will get all tracks of the playlist
    ///
    ///index is the index starting point, don't fill it if you want all tracks
    public func getAllTracks(playlist_id: Int, index: Int = 0, completed: @escaping (DeezerDataTrack?) -> Void) {
        var concatenatedTracks: [DeezerTrack] = []
        
        func recursiveGetAllTracks(index: Int) {
            self.query(DeezerDataTrack.self, url: "playlist/\(playlist_id)/tracks", post: "index=\(index)") { tracks in
                if let tracks = tracks {
                    concatenatedTracks.append(contentsOf: tracks.data ?? [])
                    
                    if let _ = tracks.next {
                        recursiveGetAllTracks(index: index + 25)
                    } else {
                        completed(DeezerDataTrack(data: concatenatedTracks,
                                                  total: tracks.total,
                                                  checksum: tracks.checksum,
                                                  next: nil))
                    }
                } else {
                    completed(nil)
                }
            }
        }
        
        recursiveGetAllTracks(index: index)
    }

    
    
    
    
    
    //https://api.deezer.com/artist/ARTIST_ID
    public func getArtist(artist_id: Int, completed: @escaping (DeezerArtist?) -> Void) {
        self.query(DeezerArtist.self, url: "artist/"+String(artist_id), completed: completed)
    }
    
    
    //https://api.deezer.com/user/me/history
    public func getHistory(completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "user/me/history", completed: completed)
    }
    
    
    
    
    //<<---- post Method ---->>\\
    
    
    //https://api.deezer.com/user/me/playlists?title=
    public func createPlaylist(title: String, completed: @escaping (DeezerCreatePlaylist?) -> Void) {
        self.query(DeezerCreatePlaylist.self, url: "user/me/playlists", post: "title="+title, completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLATLIST_ID/tracks?songs=id1,id2...
    ///return true/false
    public func addTracksToPlaylist(playlist_id: Int, tracks_id: [Int], completed: @escaping (Bool?) -> Void) {
        let tracks_idString = tracks_id.map { String($0) }.joined(separator: ",")
        self.query(Bool.self, url: "playlist/"+String(playlist_id)+"/tracks", post: "songs="+tracks_idString, completed: completed)
    }
    
    
    //https://api.deezer.com/user/me/tracks?track_id=
    ///return true/false
    public func addTrackToFavorite(track_id: Int, completed: @escaping (Bool?) -> Void) {
        self.query(Bool.self, url: "user/me/tracks", post: "track_id="+String(track_id), completed: completed)
    }
    
    
    
    //<<---- Next Method ---->>\\
    
    //https://api.deezer.com/LAST_GET_METHOD?index=
    public func getNext<T: Decodable>(_ type: T.Type, urlNext: String, completed: @escaping (T?) -> Void) {
        self.query(type, url: "user/me/tracks", completed: completed)
    }
    
    
    
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
    
    
    
    //<<---- Image Method ---->>\\
    
    public func getImageAlbum(coverURL: String, completion: @escaping (UIImage?) -> Void) {
        #if canImport(UIKit)
            AF.request(URL(string: coverURL)!).responseData { response in
                switch response.result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        print("deezer: Image data cannot been downloaded")
                        completion(nil)
                    }
                case .failure(let error):
                    print("deezer: Image data cannot been downloaded - \(error)")
                    completion(nil)
                }
            }
        #else
            print("deezer: UIKit is not imported")
            completion(nil)
        #endif
    }
    
}
