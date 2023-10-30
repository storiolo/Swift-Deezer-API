//
//  Created by Nicolas Storiolo on 17/10/2023.
//
import SwiftUI
import WebKit

#if os(iOS) || os(watchOS) || os(tvOS)
    typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#endif


extension DeezerAPI {
    
    ///ConnectView is used to display page to connect
    public struct ConnectView: View {
        var deezer: DeezerAPI
        @Binding var isShowingView: Bool
        
        public init(deezer: DeezerAPI, isShowingView: Binding<Bool>) {
            self.deezer = deezer
            self._isShowingView = isShowingView
        }
        
        public var body: some View {
            if let url = deezer.makeAuthorizationURL(){
                WebView(deezer: deezer, url: url, autoclick: false, isShowingView: $isShowingView)
            }
        }
    }
    
    ///AutoConnect is used to autoConnect when user has already connected to Deezer ;
    ///it will do the connect flow automatically
    public struct AutoConnect: View {
        var deezer: DeezerAPI
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        @State var state: String = "connected"
        
        public init(deezer: DeezerAPI) {
            self.deezer = deezer
            if deezer.getState() == "connected" {
                print("Deezer: is connected")
            }
        }

        public var body: some View {
            VStack {
                if self.state == "start" {
                    if let url = deezer.makeAuthorizationURL(){
                        WebView(deezer: deezer, url: url, autoclick: true, isShowingView: Binding.constant(false))
                    }
                }
                if self.state == "tokenFound" {
                    if let url = deezer.makeAuthentificationURL(){
                        WebView(deezer: deezer, url: url, autoclick: false, isShowingView: Binding.constant(false))
                    }
                }
            }
            .frame(width: 0, height: 0) //hide to user
            .onReceive(timer) { _ in
                self.state = deezer.getState()
            }
        }
    }
    
    
    
    
    struct WebView: ViewRepresentable {
        var deezer: DeezerAPI
        var url: URL
        var autoclick: Bool
        @Binding var isShowingView: Bool
        
        
        #if os(iOS) || os(watchOS) || os(tvOS)
            func makeUIView(context: Context) -> WKWebView {
                let webView = WKWebView()
                webView.navigationDelegate = context.coordinator
                return webView
            }
            func updateUIView(_ uiView: WKWebView, context: Context) {
                let request = URLRequest(url: self.url)
                uiView.load(request)
            }
        #elseif os(macOS)
            func makeNSView(context: Context) -> WKWebView {
                let webView = WKWebView()
                webView.navigationDelegate = context.coordinator
                return webView
            }
            func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
                let request = URLRequest(url: self.url)
                nsView.load(request)
            }
        #endif
        
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var parent: WebView
            
            init(_ parent: WebView) {
                self.parent = parent
            }
            
            
            //Auto Click
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                if parent.autoclick {
                    //Check if url is the Token Url
                    webView.evaluateJavaScript("window.location.href", completionHandler: { (result, error) in
                        if let url = result as? String, URL(string: url) == self.parent.deezer.makeAuthorizationURL() {
                            
                            //AutoClick NOW!
                            let javascript = "document.getElementsByName('continue')[0].click();"
                            webView.evaluateJavaScript(javascript) { (result, error) in
                                if let _ = error {
                                    print("deezer: No Token Found")
                                    self.parent.deezer.setState("fail")
                                }
                            }

                        }
                    })
                }
                
                
                //Check if url is the access Token Url
                webView.evaluateJavaScript("window.location.href", completionHandler: { (result, error) in
                    if let url = result as? String, URL(string: url) == self.parent.deezer.makeAuthentificationURL() {
                        
                        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
                            if let data = result as? String {
                                if let accessTokenRange = data.range(of: "access_token=") {
                                    let accessTokenStart = accessTokenRange.upperBound
                                    let accessTokenEnd: String.Index
                                    if let range = data.range(of: "&", options: [], range: accessTokenStart ..< data.endIndex) {
                                        accessTokenEnd = range.lowerBound
                                    } else {
                                        accessTokenEnd = data.endIndex
                                    }
                                    
                                    let accToken = String(data[accessTokenStart..<accessTokenEnd])
                                    self.parent.deezer.setAccessToken(accToken)
                                    self.parent.deezer.setState("connected")
                                    print("deezer: Access Token loaded")
                                } else {
                                    print("deezer: No Access Token Found")
                                    self.parent.deezer.setState("fail")
                                }
                            }
                        }
                    }
                })
                
            }
            
            //Get the Token
            func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                if let redirect_url = URL(string: parent.deezer.redirect_uri) {
                    if let url = navigationAction.request.url, url.host == redirect_url.host && url.path.hasPrefix(redirect_url.path) {
                        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                            for item in queryItems {
                                if item.name == "code" {
                                    if let code = item.value {
                                        print("deezer: Found Token")
                                        self.parent.deezer.setToken(code)
                                        self.parent.deezer.setState("tokenFound")
                                        
                                        //if it is from Connect View
                                        parent.isShowingView = false
                                    }
                                }
                            }
                        }
                    }
                }
                
                decisionHandler(.allow)
            }
            
            
        }
    }
}
