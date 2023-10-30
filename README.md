# DeezerAPI
A Swift library for the Deezer API

## Supported Platforms

* Swift 5.3+
* iOS 13+
* macOS 10.15+
* tvOS 13+
* watchOS 6+
* Linux

## Installation

1. In Xcode, open the project that you want to add this package to.
2. From the menu bar, select File > Swift Packages > Add Package Dependency...
3. Paste the url for this repository into the search field.
5. Select the `Deezer API` Library.
4. Follow the prompts for adding the package.

## Quick Start

To get started, go to the [Deezer Developer Dashboard][1] and create an app. You will receive a client id and client secret. Then, add a redirect URI. Usually, this should be a custom URL scheme that redirects to a location in your app.

The next step is permissions for your app. [Deezer Permissions][2], choose one or multiple permissions which fit with what you'll do in your project

You can create an instance of Deezer API by initializing it:
```swift
import DeezerAPI

@State var deezer: DeezerAPI = DeezerAPI(clientId: "YOUR_APP_ID",
                                         clientSecret: "YOUR_SECRET_ID",
                                         redirect_uri: "YOUR_REDIRECT_ID",
                                         permissions: "basic_access,manage_library,listening_history")
```

Note: Of course you can choose whatever you want for permissions


## Basic Flow explanation

Below is the flow to connect to deezer API, **this swift package will do it**.
1. Get the Token on this url (log if it is not)
    - https://connect.deezer.com/oauth/auth.php?app_id=YOUR_APP_ID&redirect_uri=YOUR_REDIRECT_URI&perms=PERMISSIONS
    - **makeAuthorizationURL()** return the constructed url
2. Get the Access Token on this url
    - https://connect.deezer.com/oauth/access_token.php?app_id=YOUR_APP_ID&secret=YOUR_APP_SECRET&code=TOKEN
    - **makeAuthentificationURL()** return the constructed url
3. You are connected and you can do any request. **However**, someday your access token will expire and you'll have to redo flow.


## Loggin

If you never logged to Deezer in your app, you'll have to enter your credential on the deezer authentification url.
You can use **ConnectView** to display a WebView to let user connect. Below is an example:

```swift
Button(action: {
    if !deezer.isConnected() {
        deezer.isShowingView = true
    }
}) {
    if !deezer.isConnected() {
        Text("Login to Deezer")
    } else {
        Text("Connected")
    }
}
.sheet(isPresented: $deezer.isShowingView) {
    DeezerAPI.ConnectView(deezer: $deezer)
}
```

Note: **isShowingView** will be set to false when the user has connected


## Create a connection

If user logged into your app, use **AutoConnect** in a view, it will create automatically a connection to retrieve Token and AccessToken.
Whenever you'll do a query and accessToken expire, it will update and do your query.

```swift
var body: some View {
    DeezerAPI.AutoConnect(deezer: deezer)
}
```

## Do your request

You can now do any request, here is an example:
```swift
deezer.getUser(){ deezerUser in
    if let name = deezerUser?.name {
        print(name)
    }
}
```




[1]: https://developers.deezer.com/myapps
[2]: https://developers.deezer.com/api/permissions
