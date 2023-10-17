//
//  Created by Nicolas Storiolo on 17/10/2023.
//

import Foundation

public enum ConnectState: String {
    case start
    case tokenFound
    case connected
    case fail
}
class _DeezerValue_<T> {
  var value: T
  init(_ value: T) { self.value = value }
}




//Error
struct DeezerError: Codable {
    let error: ErrorDetails
}
struct ErrorDetails: Codable {
    let type: String
    let message: String
    let code: Int
}


//User
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

