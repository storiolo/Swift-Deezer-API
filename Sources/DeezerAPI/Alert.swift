//
//
//  Created by Nicolas Storiolo on 10/11/2023.
//

import Foundation

public class DeezerAlert: ObservableObject {
    @Published public var isAlertPresented = false
    public var alertTitle = ""
    public var alertMessage = ""
    
    public func showAlert(title: String) {
        alertTitle = title
        isAlertPresented = true
    }
}
