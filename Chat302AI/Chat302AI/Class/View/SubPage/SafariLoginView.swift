import SwiftUI
import SafariServices
import WebKit

struct SafariWithURLTracking: UIViewControllerRepresentable {
    let url: URL
    @Binding var currentURL: URL?
    
    
    
    static func clearSafariCache() {
        // 1. 清除 URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // 2. 清除所有 Cookie
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        
        print("Safari缓存和Cookie已清除")
    }
    
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.delegate = context.coordinator
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 不需要更新
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariWithURLTracking
        
        init(_ parent: SafariWithURLTracking) {
            self.parent = parent
        }
        
        // iOS 14+ 的重定向捕获
        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            if #available(iOS 14.0, *) {
                DispatchQueue.main.async {
                    self.parent.currentURL = URL
                    print("重定向到: \(URL.absoluteString)")
                }
            }
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("SafariViewController关闭")
        }
    }
}

// 扩展：为移动端提供更好的预览功能
extension SafariWithURLTracking {
    // 可以添加额外的配置选项
    func mobileOptimized() -> some View {
        self
    }
}
