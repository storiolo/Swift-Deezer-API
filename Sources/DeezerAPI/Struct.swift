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
    let id: Int?
    let name: String?
    let lastName: String?
    let firstName: String?
    let email: String?
    let status: Int?
    let birthday: String?
    let inscriptionDate: String?
    let gender: String?
    let link: String?
    let picture: String?
    let pictureSmall: String?
    let pictureMedium: String?
    let pictureBig: String?
    let pictureXL: String?
    let country: String?
    let lang: String?
    let isKid: Bool?
    let explicitContentLevel: String?
    let explicitContentLevelsAvailable: [String]?
    let tracklist: String?
    let type: String?
}
