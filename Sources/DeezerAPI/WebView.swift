#if os(iOS)

import SwiftUI
import WebKit



struct WebView: UIViewRepresentable {
    @Binding var isShowing: Bool
    @Binding var deezer: DeezerAPI
    var url: URL

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

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let redirect_url = URL(string: parent.deezer.redirect_uri) {
                if let url = navigationAction.request.url, url.host == redirect_url.host && url.path.hasPrefix(redirect_url.path) {
                    if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                        for item in queryItems {
                            if item.name == "code" {
                                if let code = item.value {
//                                    parent.deezer.setToken(token: code)
                                    parent.isShowing = false
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
#endif
