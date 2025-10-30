//
//  WebViewWithURLTracking.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/22.
//

import SwiftUI
import WebKit

struct WebViewWithURLTracking: UIViewRepresentable {
    
    let url: URL
    @Binding var isLoading: Bool
    var onRedirect: ((URL, WebViewWithURLTracking.RedirectType) -> Void)? = nil
    var onPageLoad: ((URL) -> Void)? = nil
    
    enum RedirectType {
        case serverRedirect    // HTTP 服务器重定向 (301, 302, 303)
        case clientRedirect    // 客户端重定向 (JavaScript, meta refresh)
        case navigation        // 其他导航类型
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 只有在URL改变时才重新加载
        if uiView.url != url {
            
            print("\n updateUIView::::----->\(uiView.url?.absoluteString)\n\n")
            
            let request = URLRequest(url: url)
            
            let urlStr = uiView.url?.absoluteString ?? ""
            
            if urlStr.contains("apikey") && urlStr.contains("username") {
                 
                
                onRedirect?(URL(string: urlStr)!, .navigation)
            }
             
            
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWithURLTracking
        private var isFirstLoad = true
        
        init(_ parent: WebViewWithURLTracking) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate Methods
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            if let url = webView.url {
                
                let urlStr = url.absoluteString
                if urlStr.contains("apikey") && urlStr.contains("username") {
                      
                    parent.onPageLoad?(url)
                }
                
                
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        // 服务器重定向监听（最可靠的方法）
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            if let currentURL = webView.url {
                print("🔁 服务器重定向: \(currentURL.absoluteString)")
                parent.onRedirect?(currentURL, .serverRedirect)
            }
        }
        
        // 决策导航策略 - 监听其他类型的重定向
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            
            
            
            
            // 只处理主框架的导航请求，避免资源文件触发重定向回调
            guard navigationAction.targetFrame?.isMainFrame == true else {
                decisionHandler(.allow)
                return
            }
            
            let requestURL = navigationAction.request.url
            
            // 检测客户端重定向（JavaScript、meta refresh等）
            if navigationAction.navigationType == .other {
                if let url = requestURL, !isResourceRequest(navigationAction.request) {
                    print("🔄 客户端重定向: \(url.absoluteString)")
                    
                    
                    print("""
                    Navigation: \(navigationAction.navigationType)
                    URL: \(navigationAction.request.url?.absoluteString ?? "nil")
                    Main frame: \(navigationAction.targetFrame?.isMainFrame ?? false)
                    Source frame: \(navigationAction.sourceFrame.isMainFrame)
                    """)
                    
                    parent.onRedirect?(url, .clientRedirect)
                }
            } else {
                // 其他导航类型（链接点击、表单提交等）
                if let url = requestURL {
                    print("➡️ 导航请求: \(url.absoluteString)")
                    parent.onRedirect?(url, .navigation)
                }
            }
            
            decisionHandler(.allow)
        }
        
        // 判断是否为资源请求
        private func isResourceRequest(_ request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            // 排除常见的资源文件扩展名
            let resourceExtensions = ["css", "js", "png", "jpg", "jpeg", "gif", "svg", "ico", "woff", "ttf", "webp", "mp4", "mp3"]
            if resourceExtensions.contains(url.pathExtension.lowercased()) {
                return true
            }
            
            // 排除常见的资源路径
            let resourcePaths = ["/static/", "/assets/", "/images/", "/css/", "/js/", "/fonts/", "/media/"]
            let absoluteString = url.absoluteString.lowercased()
            return resourcePaths.contains { absoluteString.contains($0.lowercased()) }
        }
    }
}




// MARK: - 独立的缓存管理工具
class WebCacheManager {
    static let shared = WebCacheManager()
    
    private init() {}
    
    /// 清除所有Web缓存
    func clearAllWebCache(completion: (() -> Void)? = nil) {
        clearURLCache()
//        clearWKWebsiteDataStore(completion: completion)
        clearCookies()
    }
    
    /// 清除URLCache
    func clearURLCache() {
        URLCache.shared.removeAllCachedResponses()  
        print("✅ URLCache 清除完成")
    }
    
    /// 清除WKWebsiteDataStore缓存
    func clearWKWebsiteDataStore(completion: (() -> Void)? = nil) {
        let dataTypes = Set([
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ])
        
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            print("✅ WKWebsiteDataStore 清除完成")
            completion?()
        }
    }
    
    /// 清除Cookies
    func clearCookies() {
        // 清除HTTPCookieStorage
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        // 清除WKHTTPCookieStore
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
            }
            print("✅ Cookies 清除完成")
        }
    }
    
    /// 清除特定网站的缓存
    func clearCacheForDomain(_ domain: String) {
        let dataTypes = Set([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: dataTypes) { records in
            let recordsToDelete = records.filter { $0.displayName.contains(domain) }
            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, for: recordsToDelete) {
                print("✅ 域名 \(domain) 的缓存清除完成")
            }
        }
    }
}
