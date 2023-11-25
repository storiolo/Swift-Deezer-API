//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation
import Alamofire

#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
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
        var url: String = request
        if let post = post {
            url = url + "&" + post.replacingOccurrences(of: " ", with: "+")
        }
        
        if self.getState() == "connected" {
            url = url + "&access_token=" + self.getAccessToken()
        }
        return URL(string: url)!
    }
    
    
    ///Query data
    ///- type is the data output requested, see struct file and find your wonderland
    ///- post is optionnal, if the query require more input, eg. see post Methods
    ///- completed will return the query
    func query<T: Decodable>(_ type: T.Type, url: String, post: String? = nil, completed: @escaping (T?) -> Void) {
        Task {
            if !self.isDisconnected(){
                while !isConnected() {}
            }
            
            //verify url has not been already made (next method don't need to construct it)
            let dataURL: URL
            if url.contains("https://") {
                dataURL = URL(string: url)!
            } else {
                dataURL = makedataURL(request: DeezerAPI.base_url + url, post: post)!
            }
            
            if self.debug {
                print(dataURL)
            }
            
            AF.request(dataURL, method: .get).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        
                        do {
                            let error = try decoder.decode(DeezerError.self, from: data)
                            if error.error.type == "OAuthException" {
                                print("deezer: Not Connected")
                                
                                //reconnect
                                if self.isDisconnected() {
                                    self.alert.showAlert(title: "Please Connect to Deezer")
                                    completed(nil)
                                } else {
                                    self.setState("start")
                                    //redo it
                                    self.query(T.self, url: url, post: post, completed: completed)
                                }
                            } else {
                                print("deezer: Query error")
                                completed(nil)
                            }
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
    public func getaUser(user_id: String, completed: @escaping (DeezerUser?) -> Void) {
        self.query(DeezerUser.self, url: "user/"+user_id, completed: completed)
    }
    
    //https://api.deezer.com/track/TRACK_ID
    public func getTrack(track_id: String, completed: @escaping (DeezerTrack?) -> Void) {
        self.query(DeezerTrack.self, url: "track/"+track_id, completed: completed)
    }
    
    //https://api.deezer.com/user/me/followings
    public func getFollowing(completed: @escaping (DeezerDataUser?) -> Void) {
        self.query(DeezerDataUser.self, url: "user/me/followings", completed: completed)
    }
    
    //https://api.deezer.com/user/me/playlists
    public func getUserPlaylists(completed: @escaping (DeezerDataPlaylist?) -> Void) {
        self.query(DeezerDataPlaylist.self, url: "user/me/playlists", completed: completed)
    }
    public func getAllUserPlaylists(index: Int = 0, completed: @escaping (DeezerDataPlaylist?) -> Void) {
        var concatenatedTracks: [DeezerPlaylist] = []
        
        func recursiveGetAllTracks(index: Int) {
            self.query(DeezerDataPlaylist.self, url: "user/me/playlists", post: "index=\(index)") { playlists in
                if let playlists = playlists {
                    concatenatedTracks.append(contentsOf: playlists.data ?? [])
                    
                    if let _ = playlists.next {
                        recursiveGetAllTracks(index: index + 25)
                    } else {
                        completed(DeezerDataPlaylist(data: concatenatedTracks,
                                                     total: playlists.total,
                                                     checksum: playlists.checksum,
                                                     next: nil))
                    }
                } else {
                    completed(nil)
                }
            }
        }
        
        recursiveGetAllTracks(index: index)
    }
    public func getPlaylistsOfUser(user_id: String, completed: @escaping (DeezerDataPlaylist?) -> Void) {
        self.query(DeezerDataPlaylist.self, url: "user/"+user_id+"/playlists", completed: completed)
    }
    public func getAllPlaylistsOfUser(user_id: String, index: Int = 0, completed: @escaping (DeezerDataPlaylist?) -> Void) {
        var concatenatedTracks: [DeezerPlaylist] = []
        
        func recursiveGetAllTracks(index: Int) {
            self.query(DeezerDataPlaylist.self, url: "user/"+user_id+"/playlists", post: "index=\(index)") { playlists in
                if let playlists = playlists {
                    concatenatedTracks.append(contentsOf: playlists.data ?? [])
                    
                    if let _ = playlists.next {
                        recursiveGetAllTracks(index: index + 25)
                    } else {
                        completed(DeezerDataPlaylist(data: concatenatedTracks,
                                                     total: playlists.total,
                                                     checksum: playlists.checksum,
                                                     next: nil))
                    }
                } else {
                    completed(nil)
                }
            }
        }
        
        recursiveGetAllTracks(index: index)
    }
    
    //https://api.deezer.com/playlist/PLAYLIST_ID
    public func getPlaylist(playlist_id: String, completed: @escaping (DeezerPlaylist?) -> Void) {
        self.query(DeezerPlaylist.self, url: "playlist/"+playlist_id, completed: completed)
    }
    
    
    
    //https://api.deezer.com/album/ALBUM_ID
    public func getAlbum(album_id: String, completed: @escaping (DeezerAlbum?) -> Void) {
        self.query(DeezerAlbum.self, url: "album/"+album_id, completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLAYLIST_ID/tracks
    ///getTracks will get 25 first tracks of the playlist
    ///you'll have to do Next Method
    public func getTracks(playlist_id: String, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "playlist/"+playlist_id+"/tracks", completed: completed)
    }
    public func getAllTracks(playlist_id: String, index: Int = 0, completed: @escaping (DeezerDataTrack?) -> Void) {
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
    
    
    //https://api.deezer.com/user/me/personal_songs
    public func getUserTracks(completed: @escaping (DeezerDataTrack?) -> Void) {
        self.getUserPlaylists(){ results in
            if let results = results?.data {
                for result in results {
                    if result.title == "Loved tracks" {
                        if let id = result.id {
                            self.getTracks(playlist_id: String(id)){ tracks in
                                completed(tracks)
                            }
                        }
                    }
                }
            }
        }
    }
    public func getAllUserTracks(index: Int = 0, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.getUserPlaylists(){ results in
            if let results = results?.data {
                for result in results {
                    if result.title == "Loved tracks" {
                        if let id = result.id {
                            self.getAllTracks(playlist_id: String(id)){ tracks in
                                completed(tracks)
                            }
                        }
                    }
                }
            }
        }
    }

    //https://api.deezer.com/genre
    public func getGenres(genre_id: String, completed: @escaping (DeezerDataGenre?) -> Void) {
        self.query(DeezerDataGenre.self, url: "genre/"+genre_id, completed: completed)
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
    public func createPlaylist(title: String, completed: @escaping (DeezerCreatePlaylist?) -> Void) {
        self.query(DeezerCreatePlaylist.self, url: "user/me/playlists", post: "title="+title, completed: completed)
    }
    
    
    //https://api.deezer.com/playlist/PLATLIST_ID/tracks?songs=id1,id2...
    ///return true/false
    public func addTracksToPlaylist(playlist_id: String, tracks_id: [String], completed: @escaping (Bool?) -> Void) {
        let tracks_idString = tracks_id.joined(separator: ",")
        self.query(Bool.self, url: "playlist/"+playlist_id+"/tracks", post: "songs="+tracks_idString, completed: completed)
    }
    
    
    //https://api.deezer.com/user/me/tracks?track_id=
    ///return true/false
    public func addTrackToFavorite(track_id: String, completed: @escaping (Bool?) -> Void) {
        self.query(Bool.self, url: "user/me/tracks", post: "track_id="+track_id, completed: completed)
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
        self.query(DeezerDataAlbum.self, url: "search/album", post: "q="+search, completed: completed)
    }
    public func SearchArtist(search: String, completed: @escaping (DeezerDataArtist?) -> Void) {
        self.query(DeezerDataArtist.self, url: "search/artist", post: "q="+search, completed: completed)
    }
    public func SearchPlaylist(search: String, max: Int, completed: @escaping (DeezerDataPlaylist?) -> Void) {
        self.query(DeezerDataPlaylist.self, url: "search/playlist", post: "q="+search+"&limit="+String(max), completed: completed)
    }
    public func SearchTrack(search: String, completed: @escaping (DeezerDataTrack?) -> Void) {
        self.query(DeezerDataTrack.self, url: "search/track", post: "q="+search, completed: completed)
    }
    public func SearchUser(search: String, completed: @escaping (DeezerDataUser?) -> Void) {
        self.query(DeezerDataUser.self, url: "search/user", post: "q="+search, completed: completed)
    }
    
    
    //<<---- Image Method ---->>\\
    #if (canImport(AppKit) || canImport(UIKit)) && canImport(SwiftUI)
    public func getImageAlbum(coverURL: String, completion: @escaping (Image?) -> Void) {
        AF.request(URL(string: coverURL)!).responseData { response in
            switch response.result {
            case .success(let data):
                #if canImport(AppKit) || canImport(UIKit)
                    if let image = PlatformImage(data: data) {
                        #if canImport(UIKit)
                            completion(Image(uiImage: image))
                        #elseif canImport(AppKit)
                            completion(Image(nsImage: image))
                        #else
                            print("deezer: Image data cannot be converted to Image")
                            completion(nil)
                        #endif
                    } else {
                        print("deezer: Image data cannot be converted to Image")
                        completion(nil)
                    }
                #else
                    print("deezer: Image data cannot been downloaded")
                    completion(nil)
                #endif
            case .failure(let error):
                print("deezer: Image data cannot been downloaded - \(error)")
                completion(nil)
            }
        }
    }
    #endif
    
}
