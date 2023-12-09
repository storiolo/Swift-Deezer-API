//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation



//Error
struct DeezerError: Codable {
    let error: ErrorDetails
}
struct ErrorDetails: Codable {
    let type: String
    let message: String
    let code: Int
}


//<<---- DATA ---->>\\
public struct DeezerDataUser: Decodable {
    public let data: [DeezerUser]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}

public struct DeezerUser: Decodable {
    public let id: Int?
    public let name: String?
    public let lastName: String?
    public let firstName: String?
    public let email: String?
    public let status: Int?
    public let birthday: String?
    public let inscriptionDate: String?
    public let gender: String?
    public let link: String?
    public let picture: String?
    public let pictureSmall: String?
    public let pictureMedium: String?
    public let pictureBig: String?
    public let pictureXL: String?
    public let country: String?
    public let lang: String?
    public let isKid: Bool?
    public let explicitContentLevel: String?
    public let explicitContentLevelsAvailable: [String]?
    public let tracklist: String?
    public let type: String?
}
public struct DeezerDataPlaylist: Decodable {
    public let data: [DeezerPlaylist]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}
public struct DeezerPlaylist: Decodable {
    public let id: Int?
    public let title: String?
    public let duration: Int?
    public let isPublic: Bool?
    public let isLovedTrack: Bool?
    public let collaborative: Bool?
    public let numberOfTracks: Int?
    public let fans: Int?
    public let link: String?
    public let picture: String?
    public let pictureSmall: String?
    public let pictureMedium: String?
    public let pictureBig: String?
    public let pictureXL: String?
    public let checksum: String?
    public let tracklist: String?
    public let creationDate: String?
    public let md5Image: String?
    public let pictureType: String?
    public let timeAdd: Int?
    public let timeMod: Int?
    public let creator: DeezerCreator?
    public let type: String?
    public let tracks: DeezerDataTrack?
}
public struct DeezerCreator: Decodable {
    public let id: Int?
    public let name: String?
    public let tracklist: String?
    public let type: String?
}
public struct DeezerDataArtist: Codable {
    public let data: [DeezerArtist]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}
public struct DeezerArtist: Codable {
    public let id: Int?
    public let name: String?
    public let picture: String?
    public let picture_small: String?
    public let picture_medium: String?
    public let picture_big: String?
    public let picture_xl: String?
    public let tracklist: String?
    public let type: String?
    public let link: String?
    public let share: String?
    public let nb_album: Int?
    public let nb_fan: Int?
    public let radio: Bool?
}
public struct DeezerDataAlbum: Decodable {
    public let data: [DeezerAlbum]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}
public struct DeezerAlbum: Codable {
    public let id: Int?
    public let title: String?
    public let upc: String?
    public let link: String?
    public let share: String?
    public let cover: String?
    public let cover_small: String?
    public let cover_medium: String?
    public let cover_big: String?
    public let cover_xl: String?
    public let md5_image: String?
    public let genre_id: Int?
    public let genres: DeezerDataGenre?
    public let label: String?
    public let nb_tracks: Int?
    public let duration: Int?
    public let fans: Int?
    public let release_date: String?
    public let record_type: String?
    public let available: Bool?
    public let tracklist: String?
    public let explicit_lyrics: Bool?
    public let explicit_content_lyrics: Int?
    public let explicit_content_cover: Int?
    public let contributors: DeezerDataArtist?
    public let artist: DeezerArtist?
    public let type: String?
    public let tracks: DeezerDataTrack?
}
public struct DeezerDataTrack: Codable {
    public let data: [DeezerTrack]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}
public struct DeezerTrack: Codable {
    public let id: Int?
    public let readable: Bool?
    public let title: String?
    public let title_short: String?
    public let title_version: String?
    public let link: String?
    public let duration: Int?
    public let rank: Int?
    public let explicit_lyrics: Bool?
    public let explicit_content_lyrics: Int?
    public let preview: String?
    public let md5_image: String?
    public let artist: DeezerArtist?
    public let album: DeezerAlbum?
    public let type: String?
}

public struct DeezerDataGenre: Codable {
    public let data: [DeezerGenre]?
    public let total: Int?
    public let checksum: String?
    public let next: String?
}
public struct DeezerGenre: Codable {
    public let id: Int?
    public let name: String?
    public let picture: String?
    public let type: String?
}


//<<---- OUTPUTS ---->>\\
public struct DeezerCreatePlaylist: Codable {
    public let id: Int?
}
