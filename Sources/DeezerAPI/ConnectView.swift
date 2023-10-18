//
//  Created by Nicolas Storiolo on 17/10/2023.
//

#if os(iOS)

import SwiftUI
import WebKit

extension DeezerAPI {
    
    ///ConnectView is used to display page to connect
    public struct ConnectView: View {
        @Binding var deezer: DeezerAPI
        
        public init(deezer: Binding<DeezerAPI>) {
            self._deezer = deezer
        }
        
        public var body: some View {
            if let url = deezer.makeAuthorizationURL(){
                WebView(deezer: $deezer, url: url, autoclick: false)
            }
        }
    }
    
    ///AutoConnect is used to autoConnect when user has already connected to Deezer ;
    ///it will do the connect flow automatically
    public struct AutoConnect: View {
        @Binding var deezer: DeezerAPI
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        @State var state: ConnectState = .start
        
        public init(deezer: Binding<DeezerAPI>) {
            self._deezer = deezer
        }
        
        
        public var body: some View {
            VStack {
                if self.state == .start {
                    if let url = deezer.makeAuthorizationURL(){
                        WebView(deezer: $deezer, url: url, autoclick: true)
                            .frame(width: 0, height: 0) //hide to user
                    }
                }
                
            }
//            .onChange(of: self.state) { newState in}
            .onReceive(timer) { _ in
                self.state = deezer.getState()
                if self.state == .tokenFound {
                    deezer.get_accessToken(){ success in
                        if success {
                            deezer.setState(.connected)
                            print("deezer: connected")
                        } else {
                            deezer.setState(.fail)
                            print("deezer: did not found accessToken")
                        }
                    }
                }
            }
        }
    }
    
    struct WebView: UIViewRepresentable {
        @Binding var deezer: DeezerAPI
        var url: URL
        var autoclick: Bool
        
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            let request = URLRequest(url: self.url)
            uiView.load(request)
        }
        
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
                    
                    //Check if url is the original one
                    webView.evaluateJavaScript("window.location.href", completionHandler: { (result, error) in
                        if let url = result as? String, url == self.parent.url.absoluteString {
                            
                            //AutoClick NOW!
                            let javascript = "document.getElementsByName('continue')[0].click();"
                            webView.evaluateJavaScript(javascript) { (result, error) in
                                if let _ = error {
                                    print("deezer: No Token Found")
                                    self.parent.deezer.setState(.fail)
                                    self.parent.deezer.isShowingView = false
                                }
                            }

                        }
                    })
                }
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
                                        self.parent.deezer.setState(.tokenFound)
                                        parent.deezer.isShowingView = false
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
#endif
